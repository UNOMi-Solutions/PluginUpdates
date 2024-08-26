# Cinema 4D
RELEASE_URL="https://github.com/UNOMi-Solutions/PluginUpdates/releases/" 
RELEASE_C4D_MAC_FILE="c4d-lipsync.darwin.latest.zip"
RELEASE_C4D_MAC="${RELEASE_URL}download/c4d-ls.darwin.latest/${RELEASE_C4D_MAC_FILE}"
C4D_DIR="./dist-c4d"

# Download the zip file (macOS)
rm -rf $C4D_DIR
wget $RELEASE_C4D_MAC -P $C4D_DIR

# Extract the file then delete the zip
unzip $C4D_DIR/$RELEASE_C4D_MAC_FILE -d $C4D_DIR
rm $C4D_DIR/$RELEASE_C4D_MAC_FILE

# Generate installer without signing
"./builders/macos-installer-builder/macOS-x64/build-macos-x64.sh" "UNOMi Cinema 4D Plugin" "1.0.0" "C4D" "false" "UNOMi_Cinema4D_Plugin.pkg"