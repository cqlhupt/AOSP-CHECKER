#!/bin/bash
echo " █████   ██████  ███████ ██████       ██████ ██   ██ ███████  ██████ ██   ██ ███████ ██████  "
echo "██   ██ ██    ██ ██      ██   ██     ██      ██   ██ ██      ██      ██  ██  ██      ██   ██ "
echo "███████ ██    ██ ███████ ██████      ██      ███████ █████   ██      █████   █████   ██████  "
echo "██   ██ ██    ██      ██ ██          ██      ██   ██ ██      ██      ██  ██  ██      ██   ██ "
echo "██   ██  ██████  ███████ ██           ██████ ██   ██ ███████  ██████ ██   ██ ███████ ██   ██ "
echo "                                                                                             "
echo "                                                                                             "
echo "This script will checkout the latest version AOSP source code and build it at this dirtory for you."

# tools install
# sudo apt install software-properties-common python3-launchpadlib -y
sudo apt update
# sudo add-apt-repository ppa:openjdk-r/ppa 
# sudo apt install unzip zip libssl-dev  libffi-dev gnupg flex bison gperf build-essential  curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 x11proto-core-dev libx11-dev libz-dev ccache libgl1-mesa-dev libxml2-utils xsltproc git python2 openjdk-8-jdk aptitude repo libncurses5-dev -y 
# sudo apt install lib32ncurses5-dev 
# sudo aptitude install libncurses5-dev -y
sudo apt-get install git-core gnupg flex bison build-essential zip curl zlib1g-dev libc6-dev-i386 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig -y

# git config
read -p "Input your git email:" email
read -p "Input your git name:" name
git config --global user.email "${email}"
git config --global user.name "${name}"

# make a directory to store the AOSP source code
mkdir android
mkdir android/bin
export here=$(pwd)
export AOSP_DIR=${here}/android
cd ${AOSP_DIR}/bin

echo "PATH=$(pwd):\$PATH" >> ~/.bashrc
echo "export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo/'" >> ~/.bashrc

source ~/.bashrc

# Download source code from USTC mirror
echo "Start to download the source code from USTC mirror at $(date)."
wget -c https://mirrors.ustc.edu.cn/aosp-monthly/aosp-latest.tar
wget -c https://mirrors.ustc.edu.cn/aosp-monthly/aosp-latest.tar.md5

echo "Start to check the md5sum of the source code at $(date)."
my_md5=$(md5sum aosp-latest.tar)
md5=$(cat aosp-latest.tar.md5)
if [ "${my_md5:0:31}" != "${md5:0:31}" ]; then
    echo "md5sum check failed, please try again."
    exit 1
fi

echo "Start to extract the source code at $(date)."
tar -xvf aosp-latest.tar # aosp/.repo

# repo update and sync
# cd aosp/.repo
# git pull

# cd ..
echo "Start to repo init and sync at $(date)."
repo init -u https://aosp.tuna.tsinghua.edu.cn/platform/manifest -b android-13.0.0_r44 # android-15.0.0_r3
repo sync -j4 # ustc mirror has a limit of 4 connections one ip address
source build/envsetup.sh

# list_products
# list_releases [PRODUCT]
# list_variants [PRODUCT] [RELEASE]
# lunch <product>-<release>-<variant>
# lunch sdk_phone64_x86_64-ap4a-userdebug
lunch sdk_phone64_x86_64-ap3a-eng

echo "Start to build the source code at $(date)."
make -j10 # you change the number of jobs according to your CPU cores

emulator
# #### failed to build some targets (26:21 (mm:ss)) ####
# change device/generic/goldfish/tools/mk_combined_img.py to python2
