#!/bin/bash

#Configuration Variables and Parameters

#Parameters
PRODUCT=${1}
VERSION=${2}
APP_ID=${3}         # Either "c4d" or "maya", selecting the dir in /Resources
SIGN=${4}           # Either "true" or "false"
PACKAGE_NAME=${5}   # Name with ".pkg" extension

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
REPO_DIRECTORY="$(dirname "$(dirname "$(dirname "$SCRIPTPATH")")")"
TARGET_DIRECTORY="$REPO_DIRECTORY/output"             # Output dir at repo root
PACKAGE_DIRECTORY="$REPO_DIRECTORY/dist-$APP_ID"    # Input package
ORG="unomi"
ROOT_DIR="UnomiPlugin"  # The install dir in /Library
PLUGIN_DIR=""           # The root dir of the plugin, before the content

DATE=`date +%Y-%m-%d`
TIME=`date +%H:%M:%S`
LOG_PREFIX="[$DATE $TIME]"

function printSignature() {
  cat "$SCRIPTPATH/utils/ascii_art.txt"
  echo
}

function printUsage() {
  echo -e "\033[1mUsage:\033[0m"
  echo "$0 [APPLICATION_NAME] [APPLICATION_VERSION]"
  echo
  echo -e "\033[1mOptions:\033[0m"
  echo "  -h (--help)"
  echo
  echo -e "\033[1mExample::\033[0m"
  echo "$0 wso2am 2.6.0"

}

#Start the generator
printSignature

#Argument validation
if [[ "$1" == "-h" ||  "$1" == "--help" ]]; then
    printUsage
    exit 1
fi
if [ -z "$1" ]; then
    echo "Please enter a valid application name for your application"
    echo
    printUsage
    exit 1
else
    echo "Application Name : $1"
fi
if [[ "$2" =~ [0-9]+.[0-9]+.[0-9]+ ]]; then
    echo "Application Version : $2"
else
    echo "Please enter a valid version for your application (format [0-9].[0-9].[0-9])"
    echo
    printUsage
    exit 1
fi

#Functions
go_to_dir() {
    pushd $1 >/dev/null 2>&1
}

log_info() {
    echo "${LOG_PREFIX}[INFO]" $1
}

log_warn() {
    echo "${LOG_PREFIX}[WARN]" $1
}

log_error() {
    echo "${LOG_PREFIX}[ERROR]" $1
}

deleteInstallationDirectory() {
    log_info "Cleaning $TARGET_DIRECTORY directory."
    rm -rf "$TARGET_DIRECTORY"

    if [[ $? != 0 ]]; then
        log_error "Failed to clean $TARGET_DIRECTORY directory" $?
        exit 1
    fi
}

createInstallationDirectory() {
    if [ -d "${TARGET_DIRECTORY}" ]; then
        deleteInstallationDirectory
    fi
    mkdir -pv "$TARGET_DIRECTORY"

    if [[ $? != 0 ]]; then
        log_error "Failed to create $TARGET_DIRECTORY directory" $?
        exit 1
    fi
}

copyDarwinDirectory(){
  createInstallationDirectory
  cp -r "$SCRIPTPATH/darwin" "${TARGET_DIRECTORY}/"
  chmod -R 755 "${TARGET_DIRECTORY}/darwin/scripts"
  chmod -R 755 "${TARGET_DIRECTORY}/darwin/Resources/${APP_ID}"
  chmod 755 "${TARGET_DIRECTORY}/darwin/Distribution"
}

copyBuildDirectory() {
    # Get the first folder inside package directory to determine the plugin root dir (the folder inside the release zip)
    PLUGIN_DIR=$(basename "$(ls -d "${PACKAGE_DIRECTORY}"/* | head -n 1)")
    echo "Plugin root folder: $PLUGIN_DIR"

    sed -i '' -e 's/__PLUGIN_DIR__/'"${PLUGIN_DIR}"'/g' "${TARGET_DIRECTORY}/darwin/scripts/postinstall"
    sed -i '' -e 's/__ROOT_DIR__/'"${ROOT_DIR}"'/g' "${TARGET_DIRECTORY}/darwin/scripts/postinstall"
    sed -i '' -e 's/__APP_ID__/'${APP_ID}'/g' "${TARGET_DIRECTORY}/darwin/scripts/postinstall"
    chmod -R 755 "${TARGET_DIRECTORY}/darwin/scripts/postinstall"

    sed -i '' -e 's/__VERSION__/'${VERSION}'/g' "${TARGET_DIRECTORY}/darwin/Distribution"
    sed -i '' -e 's/__PRODUCT__/'"${PRODUCT}"'/g' "${TARGET_DIRECTORY}/darwin/Distribution"
    sed -i '' -e 's/__ROOT_DIR__/'"${ROOT_DIR}"'/g' "${TARGET_DIRECTORY}/darwin/Distribution"
    sed -i '' -e 's/__APP_ID__/'"${APP_ID}"'/g' "${TARGET_DIRECTORY}/darwin/Distribution"
    sed -i '' -e 's/__PACKAGE_NAME__/'"${PACKAGE_NAME}"'/g' "${TARGET_DIRECTORY}/darwin/Distribution"
    chmod -R 755 "${TARGET_DIRECTORY}/darwin/Distribution"

    sed -i '' -e 's/__VERSION__/'${VERSION}'/g' "${TARGET_DIRECTORY}"/darwin/Resources/"${APP_ID}"/*.html
    sed -i '' -e 's/__PRODUCT__/'"${PRODUCT}"'/g' "${TARGET_DIRECTORY}"/darwin/Resources/"${APP_ID}"/*.html
    chmod -R 755 "${TARGET_DIRECTORY}/darwin/Resources/${APP_ID}/"

    rm -rf "${TARGET_DIRECTORY}/darwinpkg"
    mkdir -p "${TARGET_DIRECTORY}/darwinpkg"

    # Copy cellery product to /Library/Cellery (determines the install structure after install)
    mkdir -p "${TARGET_DIRECTORY}"/darwinpkg/Library/${ROOT_DIR}/${APP_ID}
    cp -a "$PACKAGE_DIRECTORY"/. "${TARGET_DIRECTORY}"/darwinpkg/Library/${ROOT_DIR}/${APP_ID}
    chmod -R 755 "${TARGET_DIRECTORY}"/darwinpkg/Library/${ROOT_DIR}/${APP_ID}

    rm -rf "${TARGET_DIRECTORY}/package"
    mkdir -p "${TARGET_DIRECTORY}/package"
    chmod -R 755 "${TARGET_DIRECTORY}/package"

    rm -rf "${TARGET_DIRECTORY}/pkg"
    mkdir -p "${TARGET_DIRECTORY}/pkg"
    chmod -R 755 "${TARGET_DIRECTORY}/pkg"
}

function buildPackage() {
    log_info "Application installer package building started.(1/3)"
    pkgbuild --identifier "org.${ORG}.${APP_ID}" \
    --version "${VERSION}" \
    --scripts "${TARGET_DIRECTORY}/darwin/scripts" \
    --root "${TARGET_DIRECTORY}/darwinpkg" \
    "${TARGET_DIRECTORY}/package/$1" > /dev/null 2>&1
}

function buildProduct() {
    log_info "Application installer product building started.(2/3)"
    productbuild --distribution "${TARGET_DIRECTORY}/darwin/Distribution" \
    --resources "${TARGET_DIRECTORY}/darwin/Resources/${APP_ID}" \
    --package-path "${TARGET_DIRECTORY}/package" \
    "${TARGET_DIRECTORY}/pkg/$1" > /dev/null 2>&1
}

function signProduct() {
    log_info "Application installer signing process started.(3/3)"
    mkdir -pv "${TARGET_DIRECTORY}/pkg-signed"
    chmod -R 755 "${TARGET_DIRECTORY}/pkg-signed"

    read -p "Please enter the Apple Developer Installer Certificate ID:" APPLE_DEVELOPER_CERTIFICATE_ID
    productsign --sign "Developer ID Installer: ${APPLE_DEVELOPER_CERTIFICATE_ID}" \
    "${TARGET_DIRECTORY}/pkg/$1" \
    "${TARGET_DIRECTORY}/pkg-signed/$1"

    pkgutil --check-signature "${TARGET_DIRECTORY}/pkg-signed/$1"
}

function createInstaller() {
    log_info "Application installer generation process started.(3 Steps)"
    buildPackage ${PACKAGE_NAME}
    buildProduct ${PACKAGE_NAME}
    [[ $SIGN == "false" ]] && log_info "Skipped signing process."
    [[ $SIGN == "true" ]] && signProduct ${PACKAGE_NAME}
    log_info "Application installer generation steps finished."
}

function createUninstaller(){
    cp "$SCRIPTPATH/darwin/Resources/${APP_ID}/uninstall.sh" "${TARGET_DIRECTORY}/darwinpkg/Library/${ROOT_DIR}/${APP_ID}"
    sed -i '' -e "s/__VERSION__/${VERSION}/g" "${TARGET_DIRECTORY}/darwinpkg/Library/${ROOT_DIR}/${APP_ID}/uninstall.sh"
    sed -i '' -e "s/__PRODUCT__/${PRODUCT}/g" "${TARGET_DIRECTORY}/darwinpkg/Library/${ROOT_DIR}/${APP_ID}/uninstall.sh"
}

#Main script
log_info "Installer generating process started."

copyDarwinDirectory
copyBuildDirectory
createUninstaller
createInstaller

log_info "Installer generating process finished"
exit 0
