#!/bin/bash
#--------------------------------------------------------------------------------------------------
# A Linux script to help working with SSL certificates. It's not a total replacement for keytool.
# Think of this as the Basic interface to keystores and keytool is the Advanced one.
#
# Generate new certs, import them, list keystore contents and disable the HTTP port.
#
# Version: 0.8
#
#--------------------------------------------------------------------------------------------------

# Edit the following parameter to suit your environment
CONTROLLER_HOME=/opt/AppDynamics/Controller


################################################
# Do not edit below this line
DATETIME=`date +%Y%m%d%H%M`
CSR="./$HOSTNAME-$DATETIME.csr"

SIGNED_CERT_ALIAS_NAME="s1as"
KEYSTORE_NAME="keystore.jks"
KEYSTORE_PASSWORD="changeit"
CONFIG_HOME=$CONTROLLER_HOME/appserver/glassfish/domains/domain1/config
KEYSTORE_PATH=$CONFIG_HOME/$KEYSTORE_NAME
KEYTOOL_HOME=$CONTROLLER_HOME/jre/bin
KEYTOOL=$KEYTOOL_HOME/keytool
KEYSTORE_BACKUP="./$KEYSTORE_NAME-$DATETIME.bak"

#1
generate-csr()
{
	echo "Generating a new Certificate Signing Request..."

	#########################################
	# Backup the keystore
	if [ -f $KEYSTORE_PATH ]; then
		echo "Creating backup keystore $KEYSTORE_BACKUP"
		cp $KEYSTORE_PATH $KEYSTORE_BACKUP

		if [ $? -gt 0 ] ; then
		  echo "ERROR: unable to create the backup keystore"
		  exit 1
		fi
	fi

	#########################################
	# Delete the existing $SIGNED_CERT_ALIAS_NAME
	echo "Deleting $SIGNED_CERT_ALIAS_NAME in $KEYSTORE_PATH "
	$KEYTOOL -delete -alias $SIGNED_CERT_ALIAS_NAME -keystore $KEYSTORE_PATH -storepass $KEYSTORE_PASSWORD

	if [ $? -gt 0 ] ; then
	  echo "ERROR: unable to delete the alias"
	  exit 1
	fi

	#########################################
	# Generate the keypair
	echo "Generating the new keypair in $KEYSTORE_PATH "
	$KEYTOOL -genkeypair -alias $SIGNED_CERT_ALIAS_NAME -keyalg RSA -keystore $KEYSTORE_PATH -keysize 2048 -validity 1825 -storepass $KEYSTORE_PASSWORD

	if [ $? -gt 0 ] ; then
	  echo "ERROR: unable to generate the keypair"
	  exit 1
	fi


	#########################################
	# Generate the CSR
	echo "Generating the Certificate Signing Request at $CSR "
	$KEYTOOL -certreq -alias $SIGNED_CERT_ALIAS_NAME -keystore $KEYSTORE_PATH -storepass $KEYSTORE_PASSWORD -file $CSR

	if [ $? -gt 0 ] ; then
	  echo "ERROR: unable to generate the CSR"
	  exit 1
	fi

	#########################################
	echo " "
	echo "Finished. CSR generated at $CSR"
	echo "Send this CSR to your Certificate Authority for signing, then import the signed cert. You may need to first import the CA's chain or root cert, depending on your setup. Contact your company's PKI team for guidance. "
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

	echo "Finished"
}

#3
import-cert-chain()
{
	echo "Importing a root or intermediate certificate..."
	read -rp $'Certificate filename: ' cert

	validate-certificate $cert

	local alias=$(get-alias $cert)

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
	$KEYTOOL -list -keystore $KEYSTORE_PATH -storepass $KEYSTORE_PASSWORD | more
}

get-alias()
{
  local fullfile=$1
	local filename="${fullfile##*/}"
	local alias=$(echo $filename | cut -f 1 -d '.') #File name without the extension

  echo "$alias"
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
		echo "https://docs.appdynamics.com/display/latest/Controller+SSL+and+Certificates"
		exit 1
	fi

	if [ ! -f $cert ]; then
	    echo "ERROR: File not found, $1"
			exit 1
	fi
}

validate-install()
{
	if [ ! -d "$CONTROLLER_HOME" ]; then
		echo "ERROR: Unable to find $CONTROLLER_HOME. Set the variable in this script."
		exit 1
	fi
	if [ ! -d "$KEYTOOL_HOME" ]; then
		echo "ERROR: Unable to find $KEYTOOL_HOME. Set the variable in this script."
		exit 1
	fi
	if [ ! -d "$CONFIG_HOME" ]; then
		echo "ERROR: Unable to find $CONFIG_HOME. Set the variable in this script."
		exit 1
	fi
}

disclaimer-controller()
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

main-controller()
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

disclaimer-controller
validate-install
main-controller
