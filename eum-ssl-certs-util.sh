#!/bin/bash
#--------------------------------------------------------------------------------------------------
# A Linux script to help working with SSL certificates in the EUM Server. (If you want Controller
# certs, then use the other script.)
# This is not a total replacement for keytool. Think of this as the Basic interface to keystores
# and keytool is the Advanced one.
#
# Generate new certs, import them, and list keystore contents.
#
#--------------------------------------------------------------------------------------------------

# Edit the following parameter to suit your environment
EUM_HOME=/opt/AppDynamics/EUM



###################################################################################################
# Do not edit below this line
###################################################################################################

source ./ssl-certs-util-common.sh
if [ ! -f "./ssl-certs-util-common.sh" ]; then
	echo "ERROR: File not found, ssl-certs-util-common.sh. This file must be in the same directory as this script."
	exit 1
fi


DATETIME=$(date +%Y%m%d%H%M)
CSR="./$HOSTNAME-$DATETIME.csr"

SIGNED_CERT_ALIAS_NAME="eum-server"
KEYSTORE_NAME="keystore.jks"
KEYSTORE_PASSWORD="changeit"
CONFIG_HOME=$EUM_HOME/eum-processor/bin
KEYSTORE_PATH=$CONFIG_HOME/$KEYSTORE_NAME
KEYTOOL_HOME=$EUM_HOME/jre/bin
KEYTOOL=$KEYTOOL_HOME/keytool
KEYSTORE_BACKUP="./$KEYSTORE_NAME-$DATETIME.bak"

generate-csr()
{
	echo "Generating a new Certificate Signing Request..."

	keystore-move-existing-keystore "$KEYSTORE_PATH" "$KEYSTORE_BACKUP"

	keystore-create-new-keystore "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL" "$SIGNED_CERT_ALIAS_NAME"

	keystore-create-csr "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL" "$SIGNED_CERT_ALIAS_NAME" "$CSR"

	echo " "
	echo "Finished. CSR successfully generated at $CSR "
	echo "Send this CSR to your Certificate Authority for signing.  You may need to first import the CA's chain or root cert, depending on your setup. Contact your company's PKI team for guidance."
}

import-signed-cert()
{
	keystore-import-signed-cert "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL" "$SIGNED_CERT_ALIAS_NAME"

	echo " "
	echo "Finished. Now add the following properties to $CONFIG_HOME/eum.properties and restart the EUM Server."
	echo "processorServer.keyStorePassword=$KEYSTORE_PASSWORD"
	echo "processorServer.keyStoreFileName=$KEYSTORE_NAME"
}

eum-disclaimer()
{
	echo " "
	echo "This script helps working with SSL certificates, but it's not a total replacement for keytool."
	echo "Think of this as the Basic interface to keystores and keytool is the Advanced one."
	echo "Read the full EUM Server+SSL docs at "
	echo " "
	echo "https://docs.appdynamics.com/display/latest/Secure+the+EUM+Server"
	echo " "
	echo "ATTENTION: This is an *unofficial* script; it is not GA. Read the docs above."
	echo " "
	read -p "Press [Enter] to continue..."
	echo " "
}

eum-main()
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
				exit 0
				;;
			2)
				keystore-import-cert-chain "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL"
				exit 0
				;;
			3)
				import-signed-cert
				exit 0
				;;
			4)
				keystore-list "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL"
				exit 0
				;;
			q|quit|x|exit)
				exit 0
				;;
			*)
				echo " "
				echo " "
				echo "Choose an option or type X to exit: "
				;;
		esac
	done
}

eum-disclaimer
validate-dirs $EUM_HOME $CONFIG_HOME $KEYTOOL_HOME
eum-main
