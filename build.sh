#!/bin/bash

VERSION="v0.7-BETA"

DIST_DIR="./dist"
DIST_TOP_FOLDER="appd-ssl-cert-utils-$VERSION"
DISTRIBUTABLE_NAME="$DIST_TOP_FOLDER.zip"

if [ -d "$DIST_DIR" ]; then
  echo "Cleaning dist/ directory..."
  rm -R $DIST_DIR
fi

if [ ! -d "$DIST_DIR" ]; then
  echo "Making dist/ directory..."
  mkdir $DIST_DIR
fi

# Create a top-level folder for when unzipping the archive
mkdir $DIST_DIR/$DIST_TOP_FOLDER
cp *-ssl-certs-util.sh $DIST_DIR/$DIST_TOP_FOLDER/

echo "Creating the Zip file..."
#zip $DIST_DIR/$DISTRIBUTABLE_NAME controller-ssl-certs-util.sh eum-ssl-certs-util.sh
cd $DIST_DIR/
zip -r $DISTRIBUTABLE_NAME $DIST_TOP_FOLDER/

#unzip -l $DISTRIBUTABLE_NAME
