#!/usr/bin/env bash

# imported env vars
# NOTARIZATION_PRIVATE_KEY
# NOTARIZATION_KEY_ID
# NOTARIZATION_ISSUER_ID
# end imports

# Respectively those values are explained here:
# https://keith.github.io/xcode-man-pages/notarytool.1.html#AUTHENTICATION_OPTIONS
# They are basically App Store Connect API keys


PACKAGE_NAME=${1}   # Name & dir with ".pkg" extension
SIGNED_NAME=${2}

# Show the commands being run
set -x

# installer signing
echo "Signing installer package"
productsign --sign "Developer ID Installer: Oomi Inc." "${PACKAGE_NAME}" "${SIGNED_NAME}"
pkgutil --check-signature "${SIGNED_NAME}"

# private key setup
PRIVATE_KEY_PATH="private_keys/AuthKey_${NOTARIZATION_KEY_ID}.p8"

function notarizeAndStaple() {
    package=$1
    notaryJson=$(xcrun \
        notarytool \
        submit \
        -k ${PRIVATE_KEY_PATH} \
        -d ${NOTARIZATION_KEY_ID} \
        -i ${NOTARIZATION_ISSUER_ID} \
        -f json \
        --wait \
        "${package}")

    echo "${notaryJson}"

    acceptance=$(echo "${notaryJson}" | jq -r '.status')

    if [[ "${acceptance}" != "Accepted" ]]; then
        echo "Failure notarizing file"
        exit 1
    fi

    xcrun \
        stapler \
        staple \
        -v \
        "${package}"
}

if [ ! -f $PRIVATE_KEY_PATH ]; then 
    set +x
    mkdir -p private_keys
    echo -e $NOTARIZATION_PRIVATE_KEY > $PRIVATE_KEY_PATH
    set -x
fi

echo "Notarizing installer package"

notarizeAndStaple "${SIGNED_NAME}" > notarizing.log
cat notarizing.log

echo "Notarization finished!"