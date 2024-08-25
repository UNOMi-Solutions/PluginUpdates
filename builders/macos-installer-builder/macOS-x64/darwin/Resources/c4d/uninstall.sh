#!/bin/bash

#Generate application uninstallers for macOS.

#Parameters
DATE=`date +%Y-%m-%d`
TIME=`date +%H:%M:%S`
LOG_PREFIX="[$DATE $TIME]"

PRODUCT_HOME=/Library/__ROOT_DIR__/__APP_ID__
PLUGIN_DIR=__PLUGIN_DIR__
APP_URL="org.__ORG__.__APP_ID__"
APP_DIRS=("/Applications/Maxon Cinema 4D R25"
"/Applications/Maxon Cinema 4D S26"
"/Applications/Maxon Cinema 4D 2023"
"/Applications/Maxon Cinema 4D 2024"
"/Applications/Maxon Cinema 4D 2025")


#Functions
log_info() {
    echo "${LOG_PREFIX}[INFO]" $1
}

log_warn() {
    echo "${LOG_PREFIX}[WARN]" $1
}

log_error() {
    echo "${LOG_PREFIX}[ERROR]" $1
}

#Check running user
if (( $EUID != 0 )); then
    echo "Please run as root."
    exit
fi

echo "Welcome to Application Uninstaller"
echo "The following packages will be REMOVED:"
echo "  __PRODUCT__-__VERSION__"
while true; do
    read -p "Do you wish to continue [Y/n]?" answer
    [[ $answer == "y" || $answer == "Y" || $answer == "" ]] && break
    [[ $answer == "n" || $answer == "N" ]] && exit 0
    echo "Please answer with 'y' or 'n'"
done


#Need to replace these with install preparation script
VERSION=__VERSION__
PRODUCT=__PRODUCT__

echo "Application uninstalling process started"
# remove link to shorcut file
find "/usr/local/bin/" -name "__PRODUCT__-__VERSION__" | xargs rm
if [ $? -eq 0 ]
then
  echo "[1/4] [DONE] Successfully deleted shortcut links"
else
  echo "[1/4] [ERROR] Could not delete shortcut links" >&2
fi

#forget from pkgutil
pkgutil --forget "$APP_URL" > /dev/null 2>&1
if [ $? -eq 0 ]
then
  echo "[2/4] [DONE] Successfully deleted application informations"
else
  echo "[2/4] [ERROR] Could not delete application informations" >&2
fi

#remove application source distribution
[ -e "${PRODUCT_HOME}" ] && rm -rf "${PRODUCT_HOME}"
if [ $? -eq 0 ]
then
  echo "[3/4] [DONE] Successfully deleted application"
else
  echo "[3/4] [ERROR] Could not delete application" >&2
fi

#remove from plugin directories
for dir in "${APP_DIRS[@]}"
do
  full_dir="${dir}/plugins/${PLUGIN_DIR}"
  [ -e "${full_dir}" ] && echo "Deleting ${full_dir}..." && rm -rf "${full_dir}"
done
if [ $? -eq 0 ]
then
  echo "[4/4] [DONE] Successfully deleted plugin directories"
else
  echo "[4/4] [ERROR] Could not delete plugin directories" >&2
fi

echo "Application uninstall process finished"
exit 0
