# Vagrant LEMP environment

## Introduction

This project automates the setup of a LEMP development environment with Ubuntu 14.04. It is inspired by [Vaprobash](https://github.com/fideloper/Vaprobash) and aims to practice and learning.

## Requirements

* [VirtualBox](https://www.virtualbox.org)
* [Vagrant](http://vagrantup.com)

## Environment contents

* Ubuntu 14.04 x64
* PHP, common extensions (eg. xdebug, opcache enabled, mysql, memcached, ...) & composer
* Nginx
* php5-fpm
* MySQL 5.6
* Site folder, configured to receive web requests

## Instructions

### 1. Installation

```shell
git clone https://github.com/aanton/vagrant-ubuntu-lemp.git
```

### 2. Configuration

See `Vagrantfile`

### 3. Create the environment

```shell
cd vagrant-ubuntu-lemp
vagrant up
```

### 4. Check environment

* Connect to the environment

```shell
vagrant ssh
```

* Request the site folder `http://vagrant.dev.192.168.10.10.xip.io/` (see [xip.io](http://xip.io/))
    * Change `vagrant-dev` if the property `hostname` has been modified in `Vagrantfile`
    * Change `192.168.10.10` if the property `server_ip` has been modified in `Vagrantfile`
    * Alternatively a new rule can be create in the `hosts` file to map `vagrant.dev` to `192.168.10.10`. If done, just use `http://vagrant.dev`