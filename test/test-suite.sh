#!/bin/bash

source ./resources/assert.sh
source ../ssl-certs-util-common.sh

# Set up the test variables
SERVER_HOME="./tmp"
DATETIME=$(date +%Y%m%d%H%M)
CSR="$SERVER_HOME/$HOSTNAME-$DATETIME.csr"
SIGNED_CERT_ALIAS_NAME="s1as"
KEYSTORE_NAME="keystore.jks"
KEYSTORE_PASSWORD="changeit"
CONFIG_HOME=$SERVER_HOME
KEYSTORE_PATH=$CONFIG_HOME/$KEYSTORE_NAME
KEYTOOL_HOME=$SERVER_HOME/
KEYTOOL=keytool
KEYSTORE_BACKUP="$SERVER_HOME/$KEYSTORE_NAME-$DATETIME.bak"

# Tasks to setup the environment for the next test
setup-test()
{
    # Remove SERVER_HOME
    if [ -d "$SERVER_HOME" ]; then
        rm -rf $SERVER_HOME
    fi

    # Create SERVER_HOME exists
    if [ ! -d "$SERVER_HOME" ]; then
        mkdir $SERVER_HOME
        cp ./resources/keystore.jks.original $CONFIG_HOME/keystore.jks
    fi

    # Helpful output
    echo "TESTING: $1"
}

# Tasks to clean the environment for the next test
teardown-test()
{
    echo " "
}

# Import the other test suites and run them
source test-validation.sh
source test-keystore.sh
