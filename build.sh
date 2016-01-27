#!/bin/bash

VERSION="1.0-BETA"


################################################
# Do not edit below this line
DIST_DIR="./dist"
DIST_TOP_FOLDER="appd-ssl-certs-utils-$VERSION"
DISTRIBUTABLE_NAME="$DIST_TOP_FOLDER.zip"

dist()
{
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

  cp controller-ssl-certs-util.sh $DIST_DIR/$DIST_TOP_FOLDER/controller-ssl-certs-util-$VERSION.sh
  cp eum-ssl-certs-util.sh $DIST_DIR/$DIST_TOP_FOLDER/eum-ssl-certs-util-$VERSION.sh
  cp ssl-certs-util-common.sh $DIST_DIR/$DIST_TOP_FOLDER/ssl-certs-util-common.sh
  cp README.md $DIST_DIR/$DIST_TOP_FOLDER/README.md

  echo "Creating the Zip file..."

  cd $DIST_DIR/
  zip -r $DISTRIBUTABLE_NAME $DIST_TOP_FOLDER/
}

dist
