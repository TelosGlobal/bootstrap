#!/bin/bash

# Use this init script to kickstart a new telos node.  Spin up a node with:
# 2 cpu, 32Gb ram, (2) 250Gb raw partitions for zfs, public IP (unless producer node)
# Execute this command to kick things off:
# apt-get install git -y && cd /root && git clone https://github.com/TelosGlobal/bootstrap.git && cd bootstrap && ./init_telos.sh
#

apt update && apt -y full-upgrade

echo "Installing required software...."
apt install -y software-properties-common git ntpstat jq pigz ntp python-pip python3-pip zfsutils-linux net-tools salt-minion schedtool stress cpufrequtils lm-sensors linux-tools-generic htop iotop tree
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt-get update -y
sudo apt-get install certbot -y

#General Updates

echo "Setting up for ssh keys if needed"
mkdir -p $HOME/.ssh
chmod 0700 $HOME/.ssh


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
    then
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
    sleep 1
    service salt-minion stop
    sleep 1
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
	zpool create eosio $disk1 $disk2
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
    echo "Which EOSIO version? "
    echo "  1:  v2.0.0-rc2"
    echo "  2:  v1.8.6"
    read -p "Select (1) or (2): " instVer
    if [ $instVer == "1" ] || [ $instVer == "2" ]
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

        #Remove old symlinks
        rm /ext/telos/cleos
        rm /ext/telos/nodeos

        #Install Eosio
        cd /tmp
        sudo apt-get update -y
        if [ $instVer == "1" ]
        then
            wget 'https://github.com/EOSIO/eos/releases/download/v2.0.0-rc2/eosio_2.0.0-rc2-ubuntu-18.04_amd64.deb'
            apt install ./eosio_2.0.0-rc2-ubuntu-18.04_amd64.deb
        else
            wget 'https://github.com/EOSIO/eos/releases/download/v1.8.6/eosio_1.8.6-1-ubuntu-18.04_amd64.deb'
            apt install ./eosio_1.8.6-1-ubuntu-18.04_amd64.deb
        fi
        if [ ! -d "/ext/telos" ] 
        then
            mkdir /ext/telos/
            mkdir /ext/telos/config
            mkdir /ext/telos/state/
            mkdir /ext/telos/state/state-history
        fi
        if [ ! -d "/var/log/nodeos" ] 
        then
            mkdir /var/log/nodeos
   	    chown telosuser /var/log/nodeos/
        fi
        sudo chown -R telosuser /usr/opt/eosio/
        if [ $instVer == "1" ]
        then
            ln -s /usr/opt/eosio/2.0.0-rc2/bin/nodeos /ext/telos/nodeos
            ln -s /usr/opt/eosio/2.0.0-rc2/bin/cleos /ext/telos/cleos
	else    
            ln -s /usr/opt/eosio/1.8.6/bin/nodeos /ext/telos/nodeos
            ln -s /usr/opt/eosio/1.8.6/bin/cleos /ext/telos/cleos
        fi
        cp -rf /root/bootstrap/scripts/. /ext/telos/
        chown -R telosuser /ext/*
        /ext/telos/nodeos -v	
    else
        echo "Invalid version selected.  EOSIO install cancelled."
    fi	
else
    echo "EOSIO install cancelled."
fi	

echo "This ONLY applies to NODE01 and REQUIRES FW PORTS 80/8899 OPEN"
read -p "Install letsencrypt SSL certs?  (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then
    echo "Type DNS Name for this host.  Examples:"
    echo "<node1.testnet.telosglobal.io>"
    echo "<node2.ny.telosglobal.io>"
    read -p "Type DNS Name: " dnsname
    sudo certbot certonly --standalone --preferred-challenges http -d $dnsname
else
    echo "letsencrypt SSL install cancelled."
fi

echo "This ONLY applies to NODE01 and REQUIRES UFW PORTS 9876/8899 OPEN"
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
    echo "Setting ufw ports:"
    sudo ufw allow 80/tcp
    sudo ufw allow 8888/tcp
    sudo ufw allow 8899/tcp
    sudo ufw allow 9876/tcp
    echo "ufw ports set."
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
    echo "See /root/bootstrap/scripts/nagios/README.md to finish setup."
else
    echo "Nagios setup cancelled."
fi

echo "bootstrap completed."


