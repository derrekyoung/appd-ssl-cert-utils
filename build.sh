#!/bin/bash

VERSION="v0.7-BETA"

DISTRIBUTABLE_NAME="ssl-cert-utils-"$VERSION".zip"

rm -R ./dist/
mkdir ./dist
zip ./dist/$DISTRIBUTABLE_NAME controller-ssl-certs-util.sh eum-ssl-certs-util.sh
