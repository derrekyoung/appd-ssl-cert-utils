#!/bin/bash
#--------------------------------------------------------------------------------------------------
# A Linux script to help working with SSL certificates in the CONTROLLER. (If you want EUM certs,
# then use the other script.)
# This is not a total replacement for keytool. Think of this as the Basic interface to keystores
# and keytool is the Advanced one.
#
# Generate new certs, import them, and list keystore contents.
#
#--------------------------------------------------------------------------------------------------

# Edit the following parameter to suit your environment
CONTROLLER_HOME=/opt/AppDynamics/Controller



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

SIGNED_CERT_ALIAS_NAME="s1as"
KEYSTORE_NAME="keystore.jks"
KEYSTORE_PASSWORD="changeit"
CONFIG_HOME=$CONTROLLER_HOME/appserver/glassfish/domains/domain1/config
KEYSTORE_PATH=$CONFIG_HOME/$KEYSTORE_NAME
KEYTOOL_HOME=$CONTROLLER_HOME/jre/bin
KEYTOOL=$KEYTOOL_HOME/keytool
KEYSTORE_BACKUP="./$KEYSTORE_NAME-$DATETIME.bak"

controller-generate-csr()
{
	echo "Generating a new Certificate Signing Request..."

	keystore-backup-existing-keystore "$KEYSTORE_PATH" "$KEYSTORE_BACKUP"

	keystore-delete-alias "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL" "$SIGNED_CERT_ALIAS_NAME"

	keystore-create-keypair "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL" "$SIGNED_CERT_ALIAS_NAME"

	keystore-create-csr "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL" "$SIGNED_CERT_ALIAS_NAME" "$CSR"

	echo " "
	echo "Finished. CSR generated at $CSR"
	echo "Send this CSR to your Certificate Authority for signing, then import the signed cert that they return. You may need to first import the CA's chain or root cert, depending on your setup. Contact your company's PKI team for guidance."
}

controller-disclaimer()
{
	echo " "
	echo "This script helps working with SSL certificates, but it's not a total replacement for keytool."
	echo "Think of this as the Basic interface to keystores and keytool is the Advanced one."
	echo "Read the full Controller+SSL docs at "
	echo " "
	echo "https://docs.appdynamics.com/display/latest/Controller+SSL+and+Certificates"
	echo " "
	echo "ATTENTION: This is an *unofficial* script; it is not GA. Read the docs above."
	echo " "
	read -p "Press [Enter] to continue..."
	echo " "
}

controller-main()
{
	while true; do
		echo "[1] Generate a certificate signing request"
		echo "[2] Import a root or intermediate certificate"
		echo "[3] Import a signed certificate"
		echo "[4] List the contents of the keystore"
		echo "[x] Exit"
	  	read -p "Choose an option: " option

		case "$option" in
			1)
				controller-generate-csr
				exit 0
				;;
			2)
				keystore-import-cert-chain "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL"
				exit 0
				;;
			3)
				keystore-import-signed-cert "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL" "$SIGNED_CERT_ALIAS_NAME"
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

controller-disclaimer
validate-dirs $CONTROLLER_HOME $CONFIG_HOME $KEYTOOL_HOME
controller-main
