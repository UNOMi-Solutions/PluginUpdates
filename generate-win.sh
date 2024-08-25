# Cinema 4D
RELEASE_URL="https://github.com/UNOMi-Solutions/PluginUpdates/releases/" 
RELEASE_C4D_WIN_FILE="c4d-lipsync.win32.latest.zip"
RELEASE_C4D_WIN="${RELEASE_URL}download/c4d-ls.win32.latest/${RELEASE_C4D_WIN_FILE}"
C4D_DIR="./dist-c4d"

# Download the zip file
rm -rf $C4D_DIR
wget $RELEASE_C4D_WIN -P $C4D_DIR

# Extract the file then delete the zip
unzip $C4D_DIR/$RELEASE_C4D_WIN_FILE -d $C4D_DIR
rm $C4D_DIR/$RELEASE_C4D_WIN_FILE

# Generate installer using Inno Setup
iscc ./builders/unomi-c4d-plugin.win32.iss

# Maya
RELEASE_MAYA_WIN_FILE="maya-lipsync.win32.latest.zip"
RELEASE_MAYA_WIN="${RELEASE_URL}download/maya-ls.win32.latest/${RELEASE_MAYA_WIN_FILE}"
MAYA_DIR="./dist-maya"

# Download the zip file
rm -rf $MAYA_DIR
wget $RELEASE_MAYA_WIN -P $MAYA_DIR

# Extract the file then delete the zip
unzip $MAYA_DIR/$RELEASE_MAYA_WIN_FILE -d $MAYA_DIR
rm $MAYA_DIR/$RELEASE_MAYA_WIN_FILE

# Generate installer using Inno Setup
iscc ./builders/unomi-maya-plugin.win32.iss
sleep 3