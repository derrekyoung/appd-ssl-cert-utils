#!/bin/bash

#backup keystore
keystore-backup-existing-keystore()
{
    local KEYSTORE_PATH=$1
    local KEYSTORE_BACKUP=$2

    if [ -f "$KEYSTORE_PATH" ]; then
        echo "Creating backup keystore $KEYSTORE_BACKUP "
        cp "$KEYSTORE_PATH" "$KEYSTORE_BACKUP"

        if [ $? -gt 0 ] ; then
            echo "ERROR: unable to create the backup keystore"
            exit 1
        fi
    fi
}

#backup keystore
keystore-move-existing-keystore()
{
    local KEYSTORE_PATH=$1
    local KEYSTORE_BACKUP=$2

    if [ -f "$KEYSTORE_PATH" ]; then
        echo "Moving keystore to backup: $KEYSTORE_BACKUP "
        mv "$KEYSTORE_PATH" "$KEYSTORE_BACKUP"

        if [ $? -gt 0 ] ; then
            echo "ERROR: unable to move the backup keystore"
            exit 1
        fi
    fi
}

# create new keystore
keystore-create-new-keystore()
{
    local KEYSTORE_PATH=$1
    local KEYSTORE_PASSWORD=$2
    local KEYTOOL=$3
    local SIGNED_CERT_ALIAS_NAME=$4

    # Create the new keystore
    echo "Creating the new keystore at $KEYSTORE_PATH"
    $KEYTOOL -genkey -keyalg RSA -validity 3560 -alias "$SIGNED_CERT_ALIAS_NAME" -keystore "$KEYSTORE_PATH" -storepass "$KEYSTORE_PASSWORD"

    if [ $? -gt 0 ] ; then
        echo "ERROR: unable to generate the keypair"
        exit 1
    fi
}

# generate keypair
keystore-create-keypair()
{
    local KEYSTORE_PATH=$1
    local KEYSTORE_PASSWORD=$2
    local KEYTOOL=$3
    local SIGNED_CERT_ALIAS_NAME=$4

    validate-file "$KEYSTORE_PATH"

    # Generate the keypair
    echo "Generating the new keypair in $KEYSTORE_PATH"
    $KEYTOOL -genkeypair -alias "$SIGNED_CERT_ALIAS_NAME" -keyalg RSA -keystore "$KEYSTORE_PATH" -keysize 2048 -validity 1825 -storepass "$KEYSTORE_PASSWORD"

    if [ $? -gt 0 ] ; then
        echo "ERROR: unable to generate the keypair"
        exit 1
    fi
}

# delete alias
keystore-delete-alias()
{
    local KEYSTORE_PATH=$1
    local KEYSTORE_PASSWORD=$2
    local KEYTOOL=$3
    local SIGNED_CERT_ALIAS_NAME=$4

    validate-file "$KEYSTORE_PATH"

    echo "Deleting $SIGNED_CERT_ALIAS_NAME in $KEYSTORE_PATH "
    $KEYTOOL -delete -alias "$SIGNED_CERT_ALIAS_NAME" -keystore "$KEYSTORE_PATH" -storepass "$KEYSTORE_PASSWORD"

    if [ $? -gt 0 ] ; then
        echo "ERROR: unable to delete the alias"
        exit 1
    fi
}

# generate CSR
keystore-create-csr()
{
    local KEYSTORE_PATH=$1
    local KEYSTORE_PASSWORD=$2
    local KEYTOOL=$3
    local SIGNED_CERT_ALIAS_NAME=$4

    validate-file "$KEYSTORE_PATH"

    # Generate the CSR
    echo "Creating the Certificate Signing Request at $CSR"
    $KEYTOOL -certreq -keystore "$KEYSTORE_PATH" -file "$CSR" -alias "$SIGNED_CERT_ALIAS_NAME" -storepass "$KEYSTORE_PASSWORD"

    if [ $? -gt 0 ] ; then
        echo "ERROR: unable to generate the CSR"
        exit 1
    fi
}

# import signed cert
keystore-import-signed-cert()
{
    local KEYSTORE_PATH=$1
    local KEYSTORE_PASSWORD=$2
    local KEYTOOL=$3
    local SIGNED_CERT_ALIAS_NAME=$4
    local cert=$5

    validate-file "$KEYSTORE_PATH"

    if [ -z "$KEYSTORE_PASSWORD" ]; then
        echo "Required: keystore password"
        exit 1
    fi

    if [ -z "$KEYTOOL" ]; then
        echo "Required: keytool path"
        exit 1
    fi

    if [ -z "$SIGNED_CERT_ALIAS_NAME" ]; then
        echo "Required: cert alias name"
        exit 1
    fi


    if [ -z "$cert" ]; then
        read -rp $'Certificate filename: ' cert
    fi

    validate-certificate "$cert"


    echo "Importing $cert into $KEYSTORE_PATH for alias $SIGNED_CERT_ALIAS_NAME"
    $KEYTOOL -import -trustcacerts -keystore "$KEYSTORE_PATH" -file "$cert" -alias "$SIGNED_CERT_ALIAS_NAME" -storepass "$KEYSTORE_PASSWORD"

    if [ $? -gt 0 ] ; then
        echo "ERROR: unable to import the certificate"
        exit 1
    fi
}

# import cert chain
keystore-import-cert-chain()
{
    local KEYSTORE_PATH=$1
    local KEYSTORE_PASSWORD=$2
    local KEYTOOL=$3
    local cert=$4

    validate-file "$KEYSTORE_PATH"

    if [ -z "$KEYSTORE_PASSWORD" ]; then
        echo "Required: keystore password"
        exit 1
    fi

    if [ -z "$KEYTOOL" ]; then
        echo "Required: keytool path"
        exit 1
    fi


    if [ -z "$cert" ]; then
        read -rp $'Certificate filename: ' cert
    fi

    validate-certificate "$cert"


    local alias=$(get-alias-from-cert $cert)

    echo "Importing $cert into $KEYSTORE_PATH for alias $alias"
    $KEYTOOL -import -trustcacerts -alias "$alias" -keystore "$KEYSTORE_PATH" -storepass "$KEYSTORE_PASSWORD" -file "$cert"

    if [ $? -gt 0 ] ; then
        echo "ERROR: unable to import the certificate"
        exit 1
    fi
}

# Verbose keystore listing
keystore-list()
{
    local KEYSTORE_PATH=$1
    local KEYSTORE_PASSWORD=$2
    local KEYTOOL=$3

    validate-file "$KEYSTORE_PATH"

    $KEYTOOL -list -v -keystore "$KEYSTORE_PATH" -storepass "$KEYSTORE_PASSWORD"
}

# Concise keystor elisting
keystore-list-short()
{
    local KEYSTORE_PATH=$1
    local KEYSTORE_PASSWORD=$2
    local KEYTOOL=$3

    validate-file "$KEYSTORE_PATH"

    $KEYTOOL -list -keystore "$KEYSTORE_PATH" -storepass "$KEYSTORE_PASSWORD"
}

# Return an alias name based on the certificate name
get-alias-from-cert()
{
    if [ -z "$1" ]; then
        echo "Required: certificate file name"
        exit 1
    fi

    local fullfile=$1
    local filename="${fullfile##*/}"
    local alias=$(echo $filename | cut -f 1 -d '.') #File name without the extension

    echo "$alias"
}

# Validate the existance of multipel directories
validate-dirs()
{
    for var in "$@"
    do
        validate-directory "$var"
    done
}

# Return exit code 0 if file is found, 1 if not found.
validate-directory()
{
    if [ ! -d "$1" ]; then
        echo "ERROR: Unable to find $1. Set this variable in this script."
        exit 1
    fi
}

# Return exit code 0 if file is found, 1 if not found.
validate-file()
{
    if [ ! -f "$1" ]; then
        echo "ERROR: File not found, $1"
        exit 1
    fi
}

# Validate a certificate including the filename and extension
validate-certificate()
{
    local cert=$1

    if [ -z "$cert" ]; then
        echo "Required: certificate file name"
        exit 1
    fi

    if [[ $cert == *.p12 || $cert == *.P12 ]]; then
        echo "ERROR: This script does not support p12 certificates. Please refer to the appropriate, official docs."
        echo " "
        echo "https://docs.appdynamics.com/display/latest/Install+and+Configure+the+On-Premise+EUM+Server"
        echo "https://docs.appdynamics.com/display/PRO42/Controller+SSL+and+Certificates#ControllerSSLandCertificates-ImportanExistingKeypairintotheKeystore"
        exit 1
    fi

    validate-file "$cert"
}

validate-controlled-is-stopped() {
    echo "TODO"
}
