# -*- mode: ruby -*-
# vi: set ft=ruby :

# Inspired by https://github.com/fideloper/Vaprobash

################################################################################

# Configuration
hostname = "vagrant.dev"
boxname = "Vagrant LEMP"
network_port_mapping = false # port mapping enabled when true
shared_folder_nfs = false # nfs enabled when true

server_ip = "192.168.10.10" # local private network IP address
server_cpus = 1 # cores
server_memory = 512 # MB
server_swap = 768 # MB | false. Guideline: Between 1x or 2x server_memory
server_timezone = "UTC"

php_timezone = "Europe/Madrid" # PHP default timezone

mysql_root_password = "r00t" # password for root user
mysql_enable_remote = true # remote access enabled when true

webserver_docroot = "/vagrant/site"

################################################################################

Vagrant.configure("2") do |config|

    # Every Vagrant virtual environment requires a box to build off of
    config.vm.box = "ubuntu/trusty64"

    # Create a hostname, don't forget to put it to the `hosts` file
    config.vm.hostname = hostname

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine
    if network_port_mapping
        puts ">>> Configuring forwarded port mapping"
        config.vm.network "forwarded_port", guest: 80, host: 8080 # webserver
        config.vm.network "forwarded_port", guest: 3306, host: 33306 # mysql
    end

    # Private network, which allows host-only access to the machine using its IP
    config.vm.network "private_network", ip: server_ip

    # Virtualbox shared folder implementation have high performance penalties
    # NFS can offer a solution if you see bad performance with synced folders
    if shared_folder_nfs
        puts ">>> Configuring NFS shared folder"
        config.vm.synced_folder ".", "/vagrant",
            id: "core",
            :nfs => true,
            :mount_options => ['nolock,vers=3,udp,noatime']
    end

    # Virtualbox
    config.vm.provider :virtualbox do |vb|
        vb.name = boxname
        # vb.gui = true

        vb.customize ["modifyvm", :id, "--cpus", server_cpus]
        vb.customize ["modifyvm", :id, "--memory", server_memory]

        # How much host CPU can be used by the virtual CPU
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "80"]

        # Set the timesync threshold to 10 seconds
        vb.customize ["guestproperty", "set", :id,
            "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]

        # Prevent VMs running on Ubuntu to lose internet connection
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end

    config.vm.provision :shell, path: "provision_base.sh", args: [server_swap, server_timezone]
    config.vm.provision :shell, path: "provision_php.sh", args: [php_timezone]
    config.vm.provision :shell, path: "provision_nginx.sh", args: [hostname, server_ip, webserver_docroot]
    config.vm.provision :shell, path: "provision_mysql.sh", args: [mysql_root_password, mysql_enable_remote.to_s]

end
