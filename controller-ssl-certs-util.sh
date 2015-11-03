#!/bin/bash
#--------------------------------------------------------------------------------------------------
# A Linux script to help working with SSL certificates. It's not a total replacement for keytool.
# Think of this as the Basic interface to keystores and keytool is the Advanced one.
#
# Generate new certs, import them, list keystore contents and disable the HTTP port.
#
# Version: 0.4
#
#--------------------------------------------------------------------------------------------------

# Edit the following parameter to suit your environment
CONTROLLER_HOME=/opt/AppDynamics/Controller

################################################
# Do not edit below this line

CONTROLLER_KEYTOOL_HOME=$CONTROLLER_HOME/jre/bin
CONTROLLER_CONFIG_HOME=$CONTROLLER_HOME/appserver/glassfish/domains/domain1/config
CONTROLLER_SIGNED_CERT_ALIAS_NAME="s1as"
CONTROLLER_KEYSTORE_NAME="keystore.jks"
CONTROLLER_KEYSTORE_PASSWORD="changeit"

#1
generate-csr()
{
	validate

	local DATETIME=`date +%Y%m%d%H%M`
	local KEYSTORE_BACKUP="$CONTROLLER_KEYSTORE_NAME.$DATETIME.bak"
	local CSR="$HOSTNAME-$DATETIME.csr"

	echo "Generating a new Certificate Signing Request..."

	#########################################
	# Backup the keystore
	if [ -f $CONTROLLER_CONFIG_HOME/$CONTROLLER_KEYSTORE_NAME ]; then
		echo "Creating backup keystore $CONTROLLER_CONFIG_HOME/$KEYSTORE_BACKUP"
		cp $CONTROLLER_CONFIG_HOME/$CONTROLLER_KEYSTORE_NAME $CONTROLLER_CONFIG_HOME/$KEYSTORE_BACKUP
	fi

	#########################################
	# Delete the existing $CONTROLLER_SIGNED_CERT_ALIAS_NAME
	echo "Deleting $CONTROLLER_SIGNED_CERT_ALIAS_NAME in $CONTROLLER_CONFIG_HOME/$CONTROLLER_KEYSTORE_NAME "
	$CONTROLLER_KEYTOOL_HOME/keytool -delete -alias $CONTROLLER_SIGNED_CERT_ALIAS_NAME -keystore $CONTROLLER_CONFIG_HOME/$CONTROLLER_KEYSTORE_NAME -storepass $CONTROLLER_KEYSTORE_PASSWORD


	#########################################
	# Generate the keypair
	echo "Generating the new keypair in $CONTROLLER_CONFIG_HOME/$CONTROLLER_KEYSTORE_NAME "
	$CONTROLLER_KEYTOOL_HOME/keytool -genkeypair -alias $CONTROLLER_SIGNED_CERT_ALIAS_NAME -keyalg RSA -keystore $CONTROLLER_CONFIG_HOME/$CONTROLLER_KEYSTORE_NAME -keysize 2048 -validity 1825 -storepass $CONTROLLER_KEYSTORE_PASSWORD


	#########################################
	# Generate the CSR
	echo "Generating the Certificate Signing Request at $CONTROLLER_CONFIG_HOME/$CSR "
	$CONTROLLER_KEYTOOL_HOME/keytool -certreq -alias $CONTROLLER_SIGNED_CERT_ALIAS_NAME -keystore $CONTROLLER_CONFIG_HOME/$CONTROLLER_KEYSTORE_NAME -storepass $CONTROLLER_KEYSTORE_PASSWORD -file $CONTROLLER_CONFIG_HOME/$CSR

	#########################################
	echo " "
	echo "Finished. CSR generated at $CONTROLLER_CONFIG_HOME/$CSR."
	echo "Send this CSR to your Certificate Authority for signing, then import the signed cert. You may need to first import the CA's chain or root cert, depending on your setup. Contact your company's PKI team for guidance. "
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
	$CONTROLLER_KEYTOOL_HOME/keytool -import -trustcacerts -alias $CONTROLLER_SIGNED_CERT_ALIAS_NAME -keystore $CONTROLLER_CONFIG_HOME/$CONTROLLER_KEYSTORE_NAME -storepass $CONTROLLER_KEYSTORE_PASSWORD -file $cert

	echo "Finished"
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
	$CONTROLLER_KEYTOOL_HOME/keytool -import -trustcacerts -alias $alias -keystore $CONTROLLER_CONFIG_HOME/$CONTROLLER_KEYSTORE_NAME -storepass $CONTROLLER_KEYSTORE_PASSWORD -file $cert

	echo "Finished"
}

#4
list()
{
	validate

	$CONTROLLER_KEYTOOL_HOME/keytool -list -keystore $CONTROLLER_CONFIG_HOME/$CONTROLLER_KEYSTORE_NAME -storepass $CONTROLLER_KEYSTORE_PASSWORD | more
}

validate()
{
	local valid=true
	if [ ! -d "$CONTROLLER_HOME" ]; then
		echo "ERROR: Unable to find $CONTROLLER_HOME. Set the variable in this script."
		exit 1
	fi
	if [ ! -d "$CONTROLLER_KEYTOOL_HOME" ]; then
		echo "ERROR: Unable to find $CONTROLLER_KEYTOOL_HOME. Set the variable in this script."
		exit 1
	fi
	if [ ! -d "$CONTROLLER_CONFIG_HOME" ]; then
		echo "ERROR: Unable to find $CONTROLLER_CONFIG_HOME. Set the variable in this script."
		exit 1
	fi
}

main()
{
	echo " "
	echo "This script helps working with SSL certificates, but it's not a total replacement for keytool."
	echo "Think of this as the Basic interface to keystores and keytool is the Advanced one."
	echo "Read the full Controller+SSL docs at "
	echo "https://docs.appdynamics.com/display/latest/Controller+SSL+and+Certificates "
	echo " "
	echo "ATTENTION: This is an *unofficial* script so consider it to be Alpha--not GA."
	echo " "
	echo " "

	while true; do
		echo "[1] Generate a certificate signing request"
		echo "[2] Import a root or intermediate certificate"
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
