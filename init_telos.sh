#!/bin/bash

# Use this init script to kickstart a new telos node.  Spin up a node with:
# 2 cpu, 32Gb ram, (2) 250Gb raw partitions for zfs, public IP (unless producer node)
# Execute this command to kick things off:
# apt-get install git -y && cd /root && git clone https://github.com/TelosGlobal/bootstrap.git && cd bootstrap && chown 775 ini_telos.sh
#
# Then run this script:
# /root/bootstrap/init_telos.sh

apt update && apt -y full-upgrade

echo "Installing required software...."
apt install -y software-properties-common git jq pigz ntp python-pip python3-pip zfsutils-linux net-tools salt-minion schedtool stress cpufrequtils lm-sensors linux-tools-generic htop iotop tree
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt-get update -y
sudo apt-get install certbot -y


echo "Setting up ntp...."
/usr/bin/ntpq -p

#Change hostname
echo "The current hostname is $HOSTNAME"
read -p "Set Hostname? (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then
    read -p "Enter new hostname: " hostname
    echo "Setting hostname to $hostname...."
    hostnamectl set-hostname $hostname
    sed -i.bak '/local /c\127.0.0.1   '"$hostname"'.local '"$hostname" /etc/hosts
else
    echo "Hostname change cancelled."
fi

### Check if a directory does not exist ###
echo "Checking if user 'telosuser' exists...."
if [ ! -d "/home/telosuser" ] 
then
    echo "user telosuser doesn't exist.  Creating user..." 
    adduser telosuser
    usermod -aG sudo telosuser
else
    echo "telosuser already exists...skipping."
fi

read -p "Install Salt Minion? (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then
    if [ -z "$hostname" ]
        hostname=$HOSTNAME
    fi
    echo "$hostname"
    cd /etc/salt
    echo "Adding $hostname to minion file..."
    sed -i.bak '/#id:/c\id: '"$hostname" minion
    echo "Adding master IP and port to minion file..."
    sed -i -f /root/bootstrap/minion_cfg.sed minion
    echo "Done.  Starting Minion..."
    service salt-minion start
    sleep 3
    service salt-minion stop
    sleep 3
    service salt-minion start  
    echo "Minion started."
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
    ### Check if a directory does not exist ###
    echo "Checking if user 'telosuser' exists...."
    if [ ! -d "/home/telosuser" ] 
    then
        echo "user telosuser doesn't exist.  Creating user..." 
	adduser telosuser
        usermod -aG sudo telosuser
    else
        echo "telosuser already exists...skipping."
    fi
    chown -R telosuser /ext

    #Install Eosio
    cd /tmp
    sudo apt-get update -y
    wget 'https://github.com/EOSIO/eos/releases/download/v1.7.0/eosio_1.7.0-1-ubuntu-18.04_amd64.deb'
    apt install ./eosio_1.7.0-1-ubuntu-18.04_amd64.deb
    if [ ! -d "/ext/telos" ] 
    then
        mkdir /ext/telos
        mkdir /ext/telos/data
        mkdir /ext/telos/data/config
        mkdir /ext/telos/state/
        mkdir /ext/telos/state/state-history
    fi
    ln -s /usr/opt/eosio/1.7.0/bin/nodeos /ext/nodeos
    chown -R telosuser /ext/*
    /ext/nodeos -v	
else
    echo "EOSIO install cancelled."
fi	

read -p "Install letsencrypt SSL certs? REQUIRES FW PORTS 80/8899 OPEN (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then
    echo "Type DNS Name for this host.  Examples:"
    echo "<node1.testnet.telosglobal.io>"
    echo "<node2.ny.telosglobal.io>"
    read -p "Type DNS Name: " dnsname
    sudo certbot certonly --standalone --preferred-challenges http -d $dnsname.telosglobal.io
else
    echo "letsencrypt SSL install cancelled."
fi

read -p "Install NGINX? (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then
    sudo apt-get install nginx -y
    sudo apt-cache policy nginx
    echo "deb http://nginx.org/packages/ubuntu/ $(lsb_release -s -c) nginx" | sudo tee -a /etc/apt/sources.list.d/nginx.list
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
    sudo apt-get update
    sudo apt-cache policy nginx
    sudo apt-get install nginx -y
    nginx -v
else
    echo "NGINX install cancelled."
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

echo "bootstrap completed."


