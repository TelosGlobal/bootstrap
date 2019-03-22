#!/bin/bash

# Use this init script to kickstart a new telos node.  Spin up a node with:
# 2 cpu, 32Gb ram, (2) 250Gb raw partitions for zfs, public IP (unless producer node)
# Execute this command to kick things off:
# apt-get install git -y && cd /root && git clone https://github.com/TelosGlobal/bootstrap.git && chown 775 bootstrap/ini_telos.sh
#
# Then run this script:
# /root/bootstrap/init_telos.sh

apt update && apt -y full-upgrade

### Check if a directory does not exist ###
echo "Checking if user 'telosuser' exists...."
if [ ! -d "/home/telosuser" ] 
then
    echo "user telosuser doesn't exist.  Creating user..." 
	useradd -d /home/telosuser -g telosuser -G sudo -m -s /bin/bash telosuser
fi

echo "Installing required software...."
apt install -y software-properties-common git jq pigz ntp python-pip python3-pip zfsutils-linux salt-minion schedtool stress cpufrequtils lm-sensors linux-tools-generic htop iotop

echo "Setting up ntp...."
/usr/bin/ntpq -p

#Change hostname
read -p "Set Hostname? (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then
    read -p "Enter new hostname: " hostname
    echo "Setting hostname to $hostname...."
    hostnamectl set-hostname $hostname
    vi /etc/hosts
    cd /
else
    echo "Hostname change cancelled."
fi

read -p "Install Salt Minion? (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then
    cd /etc/salt
    echo "Copy these variables:"
    echo "master: 66.150.99.232 id: <desired_minion_name> master_port: 4506"
    read -p "Press Enter to continue..." e
    vi minion
    service salt-minion start
    sleep 3
    service salt-minion stop
    sleep 3
    service salt-minion start  
else
    echo "Salt setup cancelled."
fi
echo "Show current ZFS list"
zfs list
read -p "Configure ZFS? (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then        
    echo "ZFS setup ..."
    parted -l
    read -p "Enter first raw disk (sdc, sdd, etc): " disk1
    read -p "Enter second raw disk (sdc, sdd, etc): " disk2
    read -p "Continue? (y/n): " confirm
    if [ $confirm == "Y" ] || [ $confirm == "y" ]
    then
	echo "Creating pool and filesystem ..."
	zpool create eosio mirror $disk1 $disk2
	sleep 5
	zfs create -o mountpoint=/ext -o compression=on -o atime=off eosio/ext
	zpool list
	zpool status
	zfs list
    else
	echo "ZFS Setup cancelled."
    fi
else
    echo "ZFS configuration cancelled."
fi

read -p "Install EOSIO? (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then        
	chown -R telosuser /ext
	cd /ext
	read -p "Enter EOSIO build version: " target
	mkdir $target
	chown -R telosuser $target
	ln -s /ext/$2 /ext/telos-build

	#Install Eosio
	echo "Installing EOSIO Version: "$target
	cd /ext/telos-build
	#sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" -y
	sudo apt-get update -y
	#sudo apt-get install libicu55 -y
	wget 'https://github.com/EOSIO/eos/releases/download/v1.7.0/eosio_1.7.0-1-ubuntu-18.04_amd64.deb'
	apt install ./eosio_1.7.0-1-ubuntu-18.04_amd64.deb
	nodeos -v
else
    echo "EOSIO install cancelled."
fi

read -p "Install Nagios? (Takes about 10 mins) (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then
    cd /tmp
    wget https://assets.nagios.com/downloads/nagiosxi/agents/linux-nrpe-agent.tar.gz
    tar xzf linux-nrpe-agent.tar.gz
    cd linux-nrpe-agent
    sudo ./fullinstall -n -i '127.0.0.1 64.74.98.106 10.91.176.13'
    /etc/init.d/xinetd restart
else
    echo "Nagios setup cancelled."
fi
