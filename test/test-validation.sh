#!/bin/bash

setup-test "validate-directory"
assert_raises "validate-directory $CONFIG_HOME" 0
assert_raises "validate-directory ./foo/" 1
teardown-test

setup-test "validate-file"
assert_raises "validate-file $KEYSTORE_PATH" 0
assert_raises "validate-file ./foo.txt" 1
teardown-test

setup-test "validate-dirs"
assert_raises "validate-dirs $SERVER_HOME $CONFIG_HOME $KEYTOOL_HOME" 0
assert_raises "validate-dirs $SERVER_HOME $CONFIG_HOME ./foobar/" 1
teardown-test

setup-test "validate-certificate"
assert_raises "validate-certificate ./resources/ca-chain.cert.pem" 0
assert_raises "validate-certificate ./resources/ca.cert.pem" 0
assert_raises "validate-certificate ./resources/intermediate.cert.pem" 0
assert_raises "validate-certificate ./resources/intermediate.cert.pem" 0
assert_raises "validate-certificate ./foo/" 1
teardown-test

assert_end test-validation
