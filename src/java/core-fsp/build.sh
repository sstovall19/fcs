#!/bin/sh

if [ -z "$FON_DIR" ]; then
    echo "Need to set FON_DIR"
    exit 1
fi  

echo "Building.."

export JAVA_HOME=/usr/java/latest
export ANT_HOME=~cwolf/pub_bin/ant
$ANT_HOME/bin/ant

echo "Preparing Directories..."
mkdir -p $FON_DIR/lib/java
mkdir -p $FON_DIR/lib/java/conf
mkdir -p $FON_DIR/lib/java/conf/images
mkdir -p $FON_DIR/lib/java/conf/reports



echo "Copying files"
cp -fv --preserve=mode ./lib/*.* $FON_DIR/lib/java/
cp -fv --preserve=mode ./lib/ext/*.* $FON_DIR/lib/java/
cp -fv --preserve=mode ./conf/*.* $FON_DIR/lib/java/conf/
cp -fv --preserve=mode ./conf/reports/*.* $FON_DIR/lib/java/conf/reports
cp -fv --preserve=mode ./conf/images/*.* $FON_DIR/lib/java/conf/images

cp -fv --preserve=mode build/dist/email-notification.jar $FON_DIR/BU/shared/
cp -fv --preserve=mode build/dist/fonality-fcs.jar $FON_DIR/lib/java
cp -fv  build/dist/quote/*jar $FON_DIR/BU/quote/
echo "Done. Now go and do that voodoo that you do so... adequately."
