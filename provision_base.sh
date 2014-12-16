#!/usr/bin/env bash

SERVER_TIMEZONE=$1
SWAP_MEMORY=$2 # 0:disabled

################################################################################

echo ">>> Setting Timezone to ${SERVER_TIMEZONE}"

echo "${SERVER_TIMEZONE}" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

################################################################################

echo ">>> Setting default Locale (C.UTF-8)"

locale-gen C.UTF-8
export LANGUAGE=C.UTF-8
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

sed -i '/^export \(LANG\|LANGUAGE\|LC_ALL\)=/d' /home/vagrant/.bashrc
echo "export LANGUAGE=C.UTF-8" >> /home/vagrant/.bashrc
echo "export LANG=C.UTF-8" >> /home/vagrant/.bashrc
echo "export LC_ALL=C.UTF-8" >> /home/vagrant/.bashrc

################################################################################

swapon -s | grep -i swapfile > /dev/null
SWAP_STATUS=$? # 0:enabled

if [[ ${SWAP_MEMORY} != "0" && ${SWAP_STATUS} != "0" ]]; then
    echo ">>> Enabling Swap (${SWAP_MEMORY} MB)"

    fallocate -l ${SWAP_MEMORY}M /swapfile # Create the Swap file
    chmod 600 /swapfile # Set the correct Swap permissions
    mkswap /swapfile # Setup Swap space
    swapon /swapfile # Enable Swap space

    # Make the Swap file permanent
    echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab

    # Swap settings
    # vm.swappiness=10: Means that there wont be a Swap file until memory hits 90% useage
    # vm.vfs_cache_pressure=50: http://rudd-o.com/linux-and-free-software/tales-from-responsivenessland-why-linux-feels-slow-and-how-to-fix-that
    echo "vm.swappiness=10" >> /etc/sysctl.conf
    echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf
    sysctl -p
fi

if [[ ${SWAP_MEMORY} == "0" && ${SWAP_STATUS} == "0" ]]; then
    echo ">>> Disabling Swap"

    swapoff -a
    perl -pi -e "s#/swapfile.*\n##" /etc/fstab
    perl -pi -e "s#vm\.swappiness.*\n##" /etc/sysctl.conf
    perl -pi -e "s#vm\.vfs_cache_pressure.*\n##" /etc/sysctl.conf
    sysctl -p
fi

echo ">>> Checking Swap"
swapon -s

################################################################################

echo ">>> Optimizing APT sources to select best mirror"

perl -pi -e 's@^\s*(deb(\-src)?)\s+http://us.archive.*?\s+@\1 mirror://mirrors.ubuntu.com/mirrors.txt @g' /etc/apt/sources.list
apt-get update -q

################################################################################

echo ">>> Installing Base Packages"

# -qq implies -y --force-yes
apt-get install -qq curl unzip git-core software-properties-common build-essential

################################################################################