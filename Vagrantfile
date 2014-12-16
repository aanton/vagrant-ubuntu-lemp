# -*- mode: ruby -*-
# vi: set ft=ruby :

# Inspired by https://github.com/fideloper/Vaprobash

################################################################################

# Main configuration
boxname = "Vagrant Ubuntu LEMP" # Virtualbox name

hostname = "vagrant.dev"
port_mapping_enabled = false
nfs_enabled = false

server_cpus = 1
server_memory = 512
server_swap_enabled = true
server_swap_memory = 768 # Between 1x or 2x server_memory
server_timezone = "UTC"
server_private_ip = "192.168.10.10"

# PHP configuration
php_timezone = "Europe/Madrid"
php_xdebug_enabled = false

# MySQL configuration
mysql_root_password = "r00t" # password for root user
mysql_remote_enabled = true

# Webserver configuration
webserver_docroot = "/vagrant/site"

################################################################################

Vagrant.configure("2") do |config|

    # Every Vagrant virtual environment requires a box to build off of
    config.vm.box = "ubuntu/trusty64"

    # Create a hostname, don't forget to put it to the `hosts` file
    config.vm.hostname = hostname

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine
    if port_mapping_enabled
        puts ">>> Configuring forwarded port mapping"
        config.vm.network "forwarded_port", guest: 80, host: 8080 # webserver
        config.vm.network "forwarded_port", guest: 3306, host: 33306 # mysql
    end

    # Private network, which allows host-only access to the machine using its IP
    config.vm.network "private_network", ip: server_private_ip

    # Virtualbox shared folder implementation have high performance penalties
    # NFS can offer a solution if you see bad performance with synced folders
    if nfs_enabled
        puts ">>> Configuring NFS shared folder"
        config.vm.synced_folder ".", "/vagrant",
            id: "core",
            :nfs => true,
            :mount_options => ['nolock,vers=3,udp,noatime']
    end

    # Virtualbox provider
    config.vm.provider :virtualbox do |vb|
        # vb.gui = true
        vb.name = boxname

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

    # By default shell provisioning use a privileged user to execute scripts
    config.vm.provision :shell, path: "provision_base.sh", args: [server_timezone, server_swap_enabled ? server_swap_memory : 0]
    config.vm.provision :shell, path: "provision_mysql.sh", args: [mysql_root_password, mysql_remote_enabled.to_s]
    config.vm.provision :shell, path: "provision_php.sh", args: [php_timezone, php_xdebug_enabled.to_s]
    config.vm.provision :shell, path: "provision_nginx.sh", args: [hostname, server_private_ip, webserver_docroot]

end
