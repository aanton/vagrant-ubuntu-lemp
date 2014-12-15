#!/usr/bin/env bash
# $1: server_timezone
# $2: server_swap

################################################################################

echo ">>> Setting Timezone to $1"

echo "$1" > /etc/timezone
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

echo ">>> Optimizing apt sources to select best mirror"

perl -pi -e 's@^\s*(deb(\-src)?)\s+http://us.archive.*?\s+@\1 mirror://mirrors.ubuntu.com/mirrors.txt @g' /etc/apt/sources.list

apt-get update -q

################################################################################

echo ">>> Installing Base Packages"

# -qq implies -y --force-yes
apt-get install -qq curl unzip git-core software-properties-common build-essential

################################################################################

SWAP_CHECK=`swapon -s | grep -ic swapfile`

if [[ $2 != false && $2 =~ ^[0-9]*$ && SWAP_CHECK -eq 0 ]]; then
    echo ">>> Setting up Swap ($2 MB)"

    # Create the Swap file
    fallocate -l $2M /swapfile

    # Set the correct Swap permissions
    chmod 600 /swapfile

    # Setup Swap space
    mkswap /swapfile

    # Enable Swap space
    swapon /swapfile

    # Make the Swap file permanent
    echo "/swapfile   none    swap    sw    0   0" | tee -a /etc/fstab

    # Add some swap settings:
    # vm.swappiness=10: Means that there wont be a Swap file until memory hits 90% useage
    # vm.vfs_cache_pressure=50: read http://rudd-o.com/linux-and-free-software/tales-from-responsivenessland-why-linux-feels-slow-and-how-to-fix-that
    printf "vm.swappiness=10\nvm.vfs_cache_pressure=50" | tee -a /etc/sysctl.conf && sysctl -p
fi

################################################################################