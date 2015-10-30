#!/bin/bash
#--------------------------------------------------------------------------------------------------
# A Linux script to help working with SSL certificates. It's not a total replacement for keytool.
# Think of this as the Basic interface to keystores and keytool is the Advanced one.
#
# Generate new certs, import them, and list keystore contents.
#
# Version: 0.4
#
#--------------------------------------------------------------------------------------------------

# Edit the following parameter to suit your environment
EUM_HOME=/opt/AppDynamics/EUM


################################################
# Do not edit below this line

EUM_KEYTOOL_HOME=$EUM_HOME/jre/bin
EUM_CONFIG_HOME=$EUM_HOME/eum-processor/bin
EUM_SIGNED_CERT_ALIAS_NAME="eum-server"
EUM_KEYSTORE_NAME="keystore.jks"
EUM_KEYSTORE_PASSWORD="changeit"

#1
generate-csr()
{
	validate

	local DATETIME=`date +%Y%m%d%H%M`
	local KEYSTORE_BACKUP="$EUM_KEYSTORE_NAME.$DATETIME.bak"
	local CSR="$HOSTNAME-$DATETIME.csr"

	echo "Generating a new Certificate Signing Request..."

	#########################################
	# Backup the keystore
	if [ -f $EUM_CONFIG_HOME/$EUM_KEYSTORE_NAME ]; then
		echo "Creating backup keystore $EUM_CONFIG_HOME/$EUM_KEYSTORE_NAME "
		cp $EUM_CONFIG_HOME/$EUM_KEYSTORE_NAME $EUM_CONFIG_HOME/$KEYSTORE_BACKUP
	fi

	#########################################
	# Create the new keystore
	echo "Creating the new keystore at $EUM_CONFIG_HOME/$EUM_KEYSTORE_NAME"
	$EUM_KEYTOOL_HOME/keytool -genkey -keyalg RSA -validity 3560 -alias $EUM_SIGNED_CERT_ALIAS_NAME -keystore $EUM_CONFIG_HOME/$EUM_KEYSTORE_NAME -storepass $EUM_KEYSTORE_PASSWORD


	#########################################
	# Generate the CSR
	echo "Generating the Certificate Signing Request at $EUM_CONFIG_HOME/$CSR"
	$EUM_KEYTOOL_HOME/keytool -certreq -keystore $EUM_CONFIG_HOME/$EUM_KEYSTORE_NAME -file $EUM_CONFIG_HOME/$CSR -alias $HOSTNAME -storepass $EUM_KEYSTORE_PASSWORD


	#########################################
	echo " "
	echo "Finished. CSR successfully generated at $EUM_CONFIG_HOME/$CSR. "
	echo "Send this CSR to your Certificate Authority for signing.  You may need to first import the CA's chain or root cert, depending on your setup. Contact your company's PKI team for guidance."
}

#2
import-signed-cert()
{
	validate

	echo "Importing a signed certificate..."
	read -rp $'Certificate filename: ' cert

	if [ -z "$cert" ]; then
		echo "Required: certificate file name"
		exit
	fi

	echo "Importing certificate: $cert"
	$EUM_KEYTOOL_HOME/keytool -import -trustcacerts -keystore $EUM_CONFIG_HOME/$EUM_KEYSTORE_NAME -file $cert  -alias $EUM_SIGNED_CERT_ALIAS_NAME -storepass $EUM_KEYSTORE_PASSWORD

	echo " "
	echo "Finished. Now add the following properties to $EUM_CONFIG_HOME/eum.properties and restart the EUM Server."
	echo "processorServer.keyStorePassword=$EUM_KEYSTORE_PASSWORD"
	echo "processorServer.keyStoreFileName=$EUM_KEYSTORE_NAME"
}

#3
import-cert-chain()
{
	validate

	echo "Importing a root or intermediate certificate..."
	read -rp $'Certificate filename: ' cert

	if [ -z "$cert" ]; then
		echo "Required: certificate file name"
		exit
	fi

	local fullfile=$cert
	local filename="${fullfile##*/}"
	local alias=$(echo $filename | cut -f 1 -d '.') #File name without the extension

	echo "Importing $cert into keystore alias $alias"
	$EUM_KEYTOOL_HOME/keytool -import -trustcacerts -alias $alias -keystore $EUM_CONFIG_HOME/$EUM_KEYSTORE_NAME -storepass $EUM_KEYSTORE_PASSWORD -file $cert

	echo "Finished"
}

#4
list()
{
	validate

	$EUM_KEYTOOL_HOME/keytool -list -keystore $EUM_CONFIG_HOME/$EUM_KEYSTORE_NAME -storepass $EUM_KEYSTORE_PASSWORD
}

validate()
{
	local valid=true

	if [ ! -d "$EUM_HOME" ]; then
		echo "ERROR: Unable to find $EUM_HOME. Set this variable in this script."
		exit 1
	fi
	if [ ! -d "$EUM_KEYTOOL_HOME" ]; then
		echo "ERROR: Unable to find $EUM_KEYTOOL_HOME. Set this variable in this script."
		exit 1
	fi
	if [ ! -d "$EUM_CONFIG_HOME" ]; then
		echo "ERROR: Unable to find $EUM_CONFIG_HOME. Set this variable in this script."
		exit 1
	fi
}


main()
{
	echo " "
	echo "This script helps working with SSL certificates, but it's not a total replacement for keytool."
	echo "Think of this as the Basic interface to keystores and keytool is the Advanced one."
	echo "Read the full EUM Server+SSL docs at "
	echo "https://docs.appdynamics.com/display/latest/Install+and+Configure+the+On-Premise+EUM+Server "
	echo " "
	echo "ATTENTION: This is an *unofficial* script so consider it to be Alpha--not GA."
	echo " "
	echo " "

	while true; do
		echo "[1] Generate a certificate signing request"
		echo "[2] Import a root or intermediate cert"
		echo "[3] Import a signed certificate"
		echo "[4] List the contents of the keystore"
		echo "[x] Exit"
	  read -p "Choose an option: " option

		case "$option" in
			1)
				generate-csr
				exit
				;;
			2)
				import-cert-chain
				exit
				;;
			3)
				import-signed-cert
				exit
				;;
			4)
				list
				exit
				;;
			q|quit|x|exit)
				exit
				;;
			*)
				echo " "
				echo " "
				echo "Choose an option or type X to exit: "
				;;
		esac
	done
}

main
