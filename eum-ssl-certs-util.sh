#!/bin/bash
#--------------------------------------------------------------------------------------------------
# A Linux script to help working with SSL certificates. It's not a total replacement for keytool.
# Think of this as the Basic interface to keystores and keytool is the Advanced one.
#
# Generate new certs, import them, and list keystore contents.
#
# Version: 0.8
#
#--------------------------------------------------------------------------------------------------

# Edit the following parameter to suit your environment
EUM_HOME=/opt/AppDynamics/EUM


################################################
# Do not edit below this line
DATETIME=`date +%Y%m%d%H%M`
CSR="./$HOSTNAME-$DATETIME.csr"

SIGNED_CERT_ALIAS_NAME="eum-server"
KEYSTORE_NAME="keystore.jks"
KEYSTORE_PASSWORD="changeit"
CONFIG_HOME=$EUM_HOME/eum-processor/bin
KEYSTORE_PATH=$CONFIG_HOME/$KEYSTORE_NAME
KEYTOOL_HOME=$EUM_HOME/jre/bin
KEYTOOL=$KEYTOOL_HOME/keytool
KEYSTORE_BACKUP="./$KEYSTORE_NAME-$DATETIME.bak"

#1
generate-csr()
{
	echo "Generating a new Certificate Signing Request..."

	#########################################
	# Backup the keystore
	if [ -f $KEYSTORE_PATH ]; then
		echo "Creating backup keystore $KEYSTORE_BACKUP "
		mv $KEYSTORE_PATH $KEYSTORE_BACKUP

		if [ $? -gt 0 ] ; then
		  echo "ERROR: unable to create the backup keystore"
		  exit 1
		fi
	fi

	#########################################
	# Create the new keystore
	echo "Creating the new keystore at $KEYSTORE_PATH"
	$KEYTOOL -genkey -keyalg RSA -validity 3560 -alias $SIGNED_CERT_ALIAS_NAME -keystore $KEYSTORE_PATH -storepass $KEYSTORE_PASSWORD

	if [ $? -gt 0 ] ; then
	  echo "ERROR: unable to generate the keypair"
	  exit 1
	fi

	#########################################
	# Generate the CSR
	echo "Generating the Certificate Signing Request at $CSR"
	$KEYTOOL -certreq -keystore $KEYSTORE_PATH -file $CSR -alias $SIGNED_CERT_ALIAS_NAME -storepass $KEYSTORE_PASSWORD

	if [ $? -gt 0 ] ; then
	  echo "ERROR: unable to generate the CSR"
	  exit 1
	fi

	#########################################
	echo " "
	echo "Finished. CSR successfully generated at $CSR "
	echo "Send this CSR to your Certificate Authority for signing.  You may need to first import the CA's chain or root cert, depending on your setup. Contact your company's PKI team for guidance."
}

#2
import-signed-cert()
{
	echo "Importing a signed certificate..."
	read -rp $'Certificate filename: ' cert

	validate-certificate $cert

	echo "Importing $cert into $KEYSTORE_PATH for alias $SIGNED_CERT_ALIAS_NAME"
	$KEYTOOL -import -trustcacerts -keystore $KEYSTORE_PATH -file $cert -alias $SIGNED_CERT_ALIAS_NAME -storepass $KEYSTORE_PASSWORD

	if [ $? -gt 0 ] ; then
		echo "ERROR: unable to import the certificate"
		exit 1
	fi

	echo " "
	echo "Finished. Now add the following properties to $CONFIG_HOME/eum.properties and restart the EUM Server."
	echo "processorServer.keyStorePassword=$KEYSTORE_PASSWORD"
	echo "processorServer.keyStoreFileName=$KEYSTORE_NAME"
}

#3
import-cert-chain()
{
	echo "Importing a root or intermediate certificate..."
	read -rp $'Certificate filename: ' cert

	validate-certificate $cert

	local fullfile=$cert
	local filename="${fullfile##*/}"
	local alias=$(echo $filename | cut -f 1 -d '.') #File name without the extension

	echo "Importing $cert into $KEYSTORE_PATH for alias $alias"
	$KEYTOOL -import -trustcacerts -keystore $KEYSTORE_PATH -file $cert -alias $alias -storepass $KEYSTORE_PASSWORD

	if [ $? -gt 0 ] ; then
		echo "ERROR: unable to import the certificate"
		exit 1
	fi

	echo "Finished"
}

#4
list()
{
	$KEYTOOL -list -keystore $KEYSTORE_PATH -storepass $KEYSTORE_PASSWORD
}

validate-certificate()
{
	local cert=$1

	if [ -z "$cert" ]; then
		echo "Required: certificate file name"
		exit 1
	fi

	if [[ $cert == *.p12 || $cert == *.P12 ]]; then
		echo "ERROR: This script does not support p12 certificates. Please refer to the official docs."
		echo " "
		echo "https://docs.appdynamics.com/display/latest/Install+and+Configure+the+On-Premise+EUM+Server"
		exit 1
	fi

	if [ ! -f $cert ]; then
	    echo "ERROR: File not found, $1"
			exit 1
	fi
}

validate-install()
{
	if [ ! -d "$EUM_HOME" ]; then
		echo "ERROR: Unable to find $EUM_HOME. Set this variable in this script."
		exit 1
	fi
	if [ ! -d "$KEYTOOL_HOME" ]; then
		echo "ERROR: Unable to find $KEYTOOL_HOME. Set this variable in this script."
		exit 1
	fi
	if [ ! -d "$CONFIG_HOME" ]; then
		echo "ERROR: Unable to find $CONFIG_HOME. Set this variable in this script."
		exit 1
	fi
}

disclaimer-eum()
{
	echo " "
	echo "This script helps working with SSL certificates, but it's not a total replacement for keytool."
	echo "Think of this as the Basic interface to keystores and keytool is the Advanced one."
	echo "Read the full Controller+SSL docs at "
	echo " "
	echo "https://docs.appdynamics.com/display/latest/Controller+SSL+and+Certificates "
	echo " "
	echo "ATTENTION: This is an *unofficial* script; it is not GA. Read the docs above."
	echo " "
	read -p "Press [Enter] to continue..."
	echo " "
}

main-eum()
{
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

disclaimer-eum
validate-install
main-eum
