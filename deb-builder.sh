#!/bin/bash

VERSION="0.1.0"

# Any packages specified here will be installed if not installed already.
DEPENDS="dpkg-dev"

DATA_DIR="${HOME}/deb-builder/data"

# Color variables (thanks @Itai-Nelken)
bold="\e[1m"
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
light_cyan="\e[96m"
normal="\e[0m"

function error {
  echo -e "\e[91m$1\e[39m"
  exit 1
}

# Define control c function, intialised when ctrl c is pressed
function ctrl_c() {
  break &>/dev/null
  exit 1
}
# Have the ctrl_c function run if ctrl+c is pressed
trap "ctrl_c" 2

if [ "$EUID" = 0 ]; then
  error "This script can't be run with root."
fi

mkdir -p $DATA_DIR

# ask user to input the directory with the files. 
# the directory should not cointain a DEBIAN folder or a control file, only the files desired for the deb.
read -rp "Enter the full directory with the desired contents for the deb: " DIRECTORYB
if [ ! -d "$DIRECTORYB" ]; then
    error "Sorry, that directory can't be located. Try running the script again."
else
    echo "continuing."
fi

# install dependencies with apt
sudo apt-get update || error "Failed to update apt lists. Check the errors above."
sudo apt-get install $DEPENDS -y || error "Failed to install $DEPENDS"

cd $DATA_DIR
NOWDAY="$(printf '%(%Y-%m-%d)T\n' -1)" || error "Failed to get current date."
rm -rf $NOWDAY || sudo rm -rf $NOWDAY
mkdir $NOWDAY || error "Failed to make $NOWDAY directory."
cd $NOWDAY

# copy contents from source folder into the deb-builder/data/nowday folder
cp -r ${DIRECTORYB}/* . || sudo cp -r ${DIRECTORYB}/* .

echo "Review the contents of the folder. If it's not correct, answer 'n'. If the contents are correct, answer 'y'."
echo ""
ls ${DATA_DIR}/${NOWDAY}
echo ""
read -rp "Continue (y/n)? " choicea
case "$choicea" in 
  y|Y ) CONTINUE=1 ;;
  n|N ) CONTINUE=0 ;;
  * ) echo "Invalid input" ;;
esac
if [[ "$CONTINUE" == 1 ]]; then
    echo "Continuing."
elif [[ "$CONTINUE" == 0 ]]; then
    error "Exiting."
fi

echo "Creating control file."
read -rp "Maintainer? Usually this is in the form of Name <name@gmail.com> " MAINTAINER
read -rp "Short summary? " SUMMARY
read -rp "Name? Usually this is the package name. " NAME
read -rp "Description? " DESCRIPTION
read -rp "Version? " VERSIONA
read -rp "License? (example: gpl) " LICENSE
read -rp "Architecture? (armhf, all, arm64, etc.) " ARCHA
read -rp "Provides? (what packages does this package provide) " PROVIDES
read -rp "Priority? (usually 'optional') " PRIORITY
read -rp "Recommends? (packages suggested to install but not required) " RECOMMENDS
read -rp "Conflicts? (packages that can't be alongside this package) " CONFLICTS
read -rp "Package? (should be the same as the name in most cases) " PACKAGE

mkdir -p DEBIAN && cd DEBIAN

echo "Maintainer: ${MAINTAINER}
Summary: ${SUMMARY}
Name: ${NAME} 
Description: ${DESCRIPTION}
Version: ${VERSIONA}
License: ${LICENSE}
Architecture: ${ARCHA}
Provides: ${PROVIDES}
Priority: ${PRIORITY}
Section: ${SECTION}
Recommends: ${RECOMMENDS}
Conflicts: ${CONFLICTS}
Package: ${PACKAGE}" > control

sudo chmod 775 control || error "Failed to change control file permissions!"

# go two directories up
cd ..
cd ..

echo "Last chance: review the contents of the folder. If it's not correct, answer 'n'. If the contents are correct, answer 'y'."
echo ""
ls ${DATA_DIR}/${NOWDAY}
echo ""
read -rp "Continue (y/n)? " choiceab
case "$choiceab" in 
  y|Y ) CONTINUEB=1 ;;
  n|N ) CONTINUEB=0 ;;
  * ) echo "Invalid input" ;;
esac
if [[ "$CONTINUEB" == 1 ]]; then
    echo "Continuing."
elif [[ "$CONTINUEB" == 0 ]]; then
    error "Exiting."
fi

DEBDIR="$(pwd)"

read -rp "Name of the deb file? (ex: helloworld_0.1.0_armhf.deb) " DEBNAME

echo "QEMU deb will be built at $DEBDIR"

echo "Building deb..."
dpkg-deb --build $NOWDAY/ ${DEBNAME} || error "Failed to create "

echo "Done!"