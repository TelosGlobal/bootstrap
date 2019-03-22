#!/bin/bash

#apt-get update -y
#apt-get upgrade -y
apt update && apt -y full-upgrade

### Check if a directory does not exist ###
echo "Checking if user 'telosuser' exists...."
if [ ! -d "/home/telosuser" ] 
then
    echo "user telosuser doesn't exist.  Creating user..." 
    	#adduser telosuser
	#usermod -aG sudo telosuser
	useradd -d /home/telosuser -g telosuser -G sudo -m -s /bin/bash telosuser
fi

echo "Installing required software...."
apt install -y software-properties-common git jq pigz ntp python-pip python3-pip zfsutils-linux salt-minion schedtool stress cpufrequtils lm-sensors linux-tools-generic htop iotop

# You just did this, it's not needed again, you didn't change any of the repos
#apt-get update -y
#apt-get upgrade -y

echo "Setting up ntp...."
# don't use relative paths, where is this thing supposed to live?
ntpq -p

#Change hostname
read -p "Set Hostname? (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then
    read -p "Enter new hostname: " hostname
    echo "Setting hostname to $hostname...."
    hostnamectl set-hostname $hostname
    vi /etc/hosts #use sed here instead of vi if you already have the hostname set in a variable
    cd /
else
    echo "Hostname change cancelled."
fi

read -p "Install Salt Minion? (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then
    cd /etc/salt
    # this can all very easily be scriptied you should never need to call vi in an automated script unless it's for edge case reasons
    echo "Copy these variables:"
    echo "master: 66.150.99.232 id: <desired_minion_name> master_port: 4506"
    read -p "Press space to continue..." space
    vi minion
    # Are you sure you don't mean systemctl here?
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
	# Google to make sure you don't need an ashift=12 here
	zpool create eosio mirror $disk1 $disk2
	sleep 5
	zfs create -o mountpoint=/ext eosio/ext
	# zfs set -R ... set atime off and compression to lz4 
	zfs create ext/telos
	zfs create ext/telos/data
	zfs create ext/telos/state
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
	
	chown -R telosuser:telosuser /ext/telos
	cd /ext/telos
	#use apt here instead
	#read -p "Enter EOSIO build version: " target
	#mkdir $target
	#chown -R telosuser $target
	#ln -s /ext/$2 /ext/telos-build

	#Install Eosio
	echo "Installing EOSIO Version: "$target
	mkdir /ext/telos-source
	cd /ext/telos-source
	#sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" -y
	#sudo apt-get update -y
	#sudo apt-get install libicu55 -y
	# Aren't you useing Ubuntu 16.04.05?  You should be using the release for that version of Ubuntu, not 18.04.
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
    # Again, script this crap with sed
    echo "Copy these variables:"
    echo "127.0.0.1 64.74.98.106 10.91.176.13"
    read -p "Press ENTER to continue..." space
    sudo ./fullinstall 
    /etc/init.d/xinetd restart
else
    echo "Nagios setup cancelled."
fi
