#!/bin/sh -xe
# Script to install Qt 6 in docker container

[ "$AQT_VERSION" ] || AQT_VERSION=aqtinstall
[ "$QT_VERSION" ] || exit 1

[ "$QT_PATH" ] || QT_PATH=/opt/Qt

root_dir=$PWD
[ "$root_dir" != '/' ] || root_dir=""

# Init the package system
apt update

echo
echo '--> Save the original installed packages list'
echo

dpkg --get-selections | cut -f 1 > /tmp/packages_orig.lst

echo
echo '--> Install the required packages to install Qt'
echo

apt install -y git python3-pip python3-venv libglib2.0-0
mkdir /tmp/venv
python3 -m venv /tmp/venv
/tmp/venv/bin/pip3 install --no-cache-dir "$AQT_VERSION"

echo
echo '--> Download & install the Qt library using aqt'
echo

/tmp/venv/bin/aqt install-qt -O "$QT_PATH" linux desktop "$QT_VERSION" gcc_64
/tmp/venv/bin/aqt install-tool -O "$QT_PATH" linux desktop tools_cmake
/tmp/venv/bin/aqt install-tool -O "$QT_PATH" linux desktop tools_ninja

/tmp/venv/bin/pip3 freeze | xargs /tmp/venv/bin/pip3 uninstall -y

echo
echo '--> Restore the packages list to the original state'
echo

dpkg --get-selections | cut -f 1 > /tmp/packages_curr.lst
grep -Fxv -f /tmp/packages_orig.lst /tmp/packages_curr.lst | xargs apt remove -y --purge

# Complete the cleaning

apt -qq clean
rm -rf /var/lib/apt/lists/*
