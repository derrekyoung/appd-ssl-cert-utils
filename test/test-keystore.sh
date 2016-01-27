#!/bin/bash

##############################################################################
##############################################################################
setup-test "get-alias-from-cert"
assert "get-alias-from-cert foobar.pem" "foobar"
assert "get-alias-from-cert ./foo/foobar.pem" "foobar"
assert "get-alias-from-cert ./foo/foobar.intermediate.pem" "foobar"
assert "get-alias-from-cert " "Required: certificate file name"
teardown-test


##############################################################################
##############################################################################
setup-test "keystore-list"
assert_raises "keystore-list $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL" 0
assert "keystore-list $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL | grep -c \"Alias name: s1as\"" "1"
assert "keystore-list $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL | grep -c \"Alias name: foobar\"" "0"
assert_raises "keystore-list ./foo $KEYSTORE_PASSWORD $KEYTOOL" 1
assert_raises "keystore-list $KEYSTORE_PATH $KEYSTORE_PASSWORD badpass" 127
teardown-test


##############################################################################
##############################################################################
setup-test "keystore-backup-existing-keystore"
assert_raises "keystore-backup-existing-keystore $KEYSTORE_PATH $KEYSTORE_BACKUP" 0
assert_raises "validate-file $KEYSTORE_BACKUP" 0
teardown-test


##############################################################################
##############################################################################
setup-test "keystore-move-existing-keystore"
assert_raises "keystore-move-existing-keystore $KEYSTORE_PATH $KEYSTORE_BACKUP" 0
assert_raises "validate-file $KEYSTORE_BACKUP" 0
assert_raises "validate-file $KEYSTORE_PATH" 1
teardown-test


##############################################################################
##############################################################################
setup-test "keystore-delete-alias"
assert "keystore-delete-alias $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL $SIGNED_CERT_ALIAS_NAME" "Deleting $SIGNED_CERT_ALIAS_NAME in $KEYSTORE_PATH "
assert_raises "keystore-delete-alias ./foo $KEYSTORE_PASSWORD $KEYTOOL $SIGNED_CERT_ALIAS_NAME" 1
assert_raises "keystore-delete-alias $KEYSTORE_PATH badpass $KEYTOOL $SIGNED_CERT_ALIAS_NAME" 1
teardown-test


##############################################################################
##############################################################################
setup-test "keystore-import-cert-chain"

# Requires interaction
keystore-import-cert-chain "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL" "./resources/ca.cert.pem"
assert "keystore-list $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL | grep -c \"Alias name: ca\"" "1"

assert_raises "keystore-import-cert-chain badPath $KEYSTORE_PASSWORD $KEYTOOL ./resources/ca.cert.pem" 1
assert_raises "keystore-import-cert-chain $KEYSTORE_PATH badpass $KEYTOOL ./resources/ca.cert.pem" 1
assert_raises "keystore-import-cert-chain $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL foobar.pem" 1

assert_raises "keystore-import-cert-chain $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL ./resources/intermediate.cert.pem" 0
assert "keystore-list $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL | grep -c \"Alias name: intermediate\"" "1"
teardown-test


##############################################################################
##############################################################################
setup-test "keystore-import-signed-cert"

# Requires interaction
keystore-import-cert-chain "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL" "./resources/ca.cert.pem"

assert_raises "keystore-import-cert-chain $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL ./resources/intermediate.cert.pem" 0
assert_raises "keystore-import-signed-cert $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL $SIGNED_CERT_ALIAS_NAME ./resources/www.example.com.cert.pem" 0
assert "keystore-list $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL | grep -c \"Alias name: s1as\"" "1"

assert_raises "keystore-import-signed-cert $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL $SIGNED_CERT_ALIAS_NAME foobar.pem" 1
teardown-test


##############################################################################
##############################################################################
setup-test "keystore-create-csr"
assert "keystore-create-csr $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL $SIGNED_CERT_ALIAS_NAME $CSR" "Creating the Certificate Signing Request at $CSR"
assert_raises "keystore-create-csr ./foo $KEYSTORE_PASSWORD $KEYTOOL $SIGNED_CERT_ALIAS_NAME $CSR" 1
assert_raises "keystore-create-csr $KEYSTORE_PATH badpass $KEYTOOL $SIGNED_CERT_ALIAS_NAME $CSR" 1
assert_raises "keystore-create-csr $KEYSTORE_PATH $KEYSTORE_PASSWORD foo $SIGNED_CERT_ALIAS_NAME $CSR" 1
assert_raises "validate-file $CSR" 0
teardown-test


##############################################################################
##############################################################################
setup-test "keystore-create-keypair"
assert_raises "keystore-backup-existing-keystore $KEYSTORE_PATH $KEYSTORE_BACKUP" 0
assert "keystore-delete-alias $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL $SIGNED_CERT_ALIAS_NAME" "Deleting $SIGNED_CERT_ALIAS_NAME in $KEYSTORE_PATH "

# Requires interaction
keystore-create-keypair "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL" "$SIGNED_CERT_ALIAS_NAME"

assert "keystore-list $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL | grep -c \"Alias name: s1as\"" "1"
assert_raises "keystore-list ./foo $KEYSTORE_PASSWORD $KEYTOOL" 1
assert_raises "keystore-list $KEYSTORE_PATH $KEYSTORE_PASSWORD badpass" 127
assert_raises "validate-file $KEYSTORE_PATH" 0
teardown-test


##############################################################################
##############################################################################
setup-test "keystore-create-new-keystore"
assert_raises "keystore-move-existing-keystore $KEYSTORE_PATH $KEYSTORE_BACKUP" 0

# Requires interaction
keystore-create-new-keystore "$KEYSTORE_PATH" "$KEYSTORE_PASSWORD" "$KEYTOOL" "$SIGNED_CERT_ALIAS_NAME"

assert_raises "validate-file $KEYSTORE_PATH" 0
assert "keystore-list $KEYSTORE_PATH $KEYSTORE_PASSWORD $KEYTOOL | grep -c \"Alias name: s1as\"" "1"
teardown-test

assert_end test-keystore
