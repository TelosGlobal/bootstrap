#!/bin/bash

# Use this init script to kickstart a new telos node.  Spin up a node with:
# 2 cpu, 32Gb ram, (2) 500Gb raw partitions for zfs, public IP (unless producer node)
# Execute this command to kick things off:
# apt update -y && apt upgrade -y && apt-get install git -y && cd /root && git clone https://github.com/TelosGlobal/bootstrap.git && cd bootstrap && ./init_telos.sh
#
# Run script as root from /root/bootstrap/
# Run as:  init_telos.sh -v <5.0.0>

while getopts v: option
do
case "${option}"
in
v) VERSION=${OPTARG};;
u) URL=${OPTARG};;
#h) PRODUCT=${OPTARG};;
#f) FORMAT=$OPTARG;;
esac
done

if [ -z "$VERSION" ]
then
    echo "No arguments passed. Use the following example: "
    echo "init_telos.sh -v <5.0.0>"
    echo "Exiting..."
    exit
fi

apt update && apt -y full-upgrade

echo "Installing required software...."
apt install -y software-properties-common git ntpstat jq pigz ntp python3-pip net-tools schedtool stress cpufrequtils lm-sensors linux-tools-generic htop iotop tree
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt-get update -y
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo apt autoremove -y

#General Updates

echo "Setting up for ssh keys if needed"
mkdir -p $HOME/.ssh
chmod 0700 $HOME/.ssh


echo "Setting up ntp...."
/usr/bin/ntpq -p

echo "Changing timezone to UTC..."
sudo timedatectl set-timezone UTC

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

read -p "Install LEAP? (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then        
    echo "Installing LEAP version $VERSION "
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
	
    ### Check if a directory does not exist ###
    echo "Checking if dir '/ext' exists...."
    if [ -d "/ext" ] 
    then
        chown -R telosuser /ext
    else
        mkdir /ext
        chown -R telosuser /ext
    fi
        
    #Remove old symlinks
    rm /ext/telos/cleos
    rm /ext/telos/nodeos

    #Install LEAP
    cd /tmp
    sudo apt-get update -y
    wget "https://github.com/AntelopeIO/leap/releases/download/v${VERSION}/leap_${VERSION}_amd64.deb"
    echo "Installing v$VERSION..."
    sudo apt install ./leap_${VERSION}_amd64.deb -y

    if [ ! -d "/ext/telos" ] 
    then
        mkdir /ext/telos/
        chown -R telosuser /ext/telos
        mkdir /ext/telos/config
        chown -R telosuser /ext/telos/config
        mkdir /ext/telos/state/
        chown -R telosuser /ext/telos/state
        mkdir /ext/telos/state/state-history
        chown -R telosuser /ext/telos/state/state-history
    fi
	
    if [ ! -d "/var/log/nodeos" ] 
    then
        mkdir /var/log/nodeos
        chown telosuser /var/log/nodeos/
    fi

    sudo chown -R telosuser /usr/opt/eosio/
    cp -rf /root/bootstrap/scripts/. /ext/telos/
    chown -R telosuser /ext/*
    /ext/telos/nodeos -v	
else
    echo "LEAP install cancelled."
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

read -p "Install Zabbix Agent? (y/n): " confirm
if [ $confirm == "Y" ] || [ $confirm == "y" ]
then
    #function to call after installing agent
    function install_agent {
        apt install zabbix-agent2 zabbix-agent2-plugin-*

        #Add zabbix server into zabbix.conf
        sed -i.bak 's/Server=127\.0\.0\.1/Server=127\.0\.0\.1\,63\.250\.47\.6/' /etc/zabbix/zabbix_agent2.conf

        #restart and enable for start on reboot
        systemctl restart zabbix-agent2
        systemctl enable zabbix-agent2
        rm zabbix-release*
    }

    cd /tmp

    #Get version
    ver=`lsb_release -rs| awk -F'.' '{print $1}'`;
    echo "OS Version: "$ver

    #Check version and run correct install script
    if [ $ver == 18 ] 
    then
        wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu18.04_all.deb
        dpkg -i zabbix-release_6.4-1+ubuntu18.04_all.deb
        install_agent
    elif [ $ver == 20 ] 
    then
        wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu20.04_all.deb
        dpkg -i zabbix-release_6.4-1+ubuntu20.04_all.deb
        install_agent
    elif [ $ver == 22 ] 
    then
        wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
        dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
        install_agent
    else
        echo "No compatible OS version found."
    fi
else
    echo "Zabbix setup cancelled."
fi

echo "bootstrap completed."


