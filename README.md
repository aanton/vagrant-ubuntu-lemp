# Vagrant LEMP environment

## Introduction

This project automates the setup of a LEMP development environment with Ubuntu 14.04. It is inspired by [Vaprobash](https://github.com/fideloper/Vaprobash) and aims to practice and learning.

## Requirements

* [VirtualBox](https://www.virtualbox.org)
* [Vagrant](http://vagrantup.com)

## Contents

### Vagrant machine

* Ubuntu 14.04 (Trusty Tahr) 64bits running in VirtualBox
* Optionally, forwarded port mapping to allow access to a specific port within the virtual machine from a port on the host machine
* Optionally, [NFS shared folder](https://docs.vagrantup.com/v2/synced-folders/nfs.html) to get better performance

### Base provisioner

* Timezone settings
* Locale settings
* Swap settings
* Optimized APT sources (using best mirror)
* Base packages: `curl`, `git`, `unzip`, `software-properties-common`, `build-essential`

### MySQL provisioner

* MySQL 5.6 ([latest packages](https://launchpad.net/~ondrej/+archive/ubuntu/mysql-5.6))
* Optionally, remote access settings

### PHP provisioner

* PHP 5.5 ([latest packages](https://launchpad.net/~ondrej/+archive/ubuntu/php5))
* PHP-FPM
* Composer
* Optionally, xDebug
* PHP & PHP-FPM settings

### nginx provisioner

* nginx ([official Ubuntu package](http://packages.ubuntu.com/trusty/httpd/))
* nginx settings
* PHP-FPM settings for nginx
* Simple web application located in the `site` folder (mapped to `/vagrant/site`)


## Instructions

### 1. Installation

```shell
git clone https://github.com/aanton/vagrant-ubuntu-lemp.git
cd vagrant-ubuntu-lemp
```

### 2. Configuration

See [Vagrantfile](https://github.com/aanton/vagrant-ubuntu-lemp/blob/master/Vagrantfile)

### 3. Create the environment

```shell
vagrant up
```

### 4. Check environment

#### Check SSH access

```shell
vagrant ssh
```

#### Check web access

* Request the application URL [http://vagrant.dev.192.168.10.10.xip.io/](http://vagrant.dev.192.168.10.10.xip.io/), thanks to [xip.io](http://xip.io/)
    * Change `vagrant-dev` if the property `hostname` has been modified in `Vagrantfile`
    * Change `192.168.10.10` if the property `server_private_ip` has been modified in `Vagrantfile`
    * Alternatively, a new rule can be create in the `hosts` file to map `vagrant.dev` to `192.168.10.10`. If done, just use [http://vagrant.dev](http://vagrant.dev)