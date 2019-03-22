#!/bin/bash

#  Needs arguments passed!!!!!
#  "Usage:  ./init_telos.sh [hostname] [git branch tag]
#        1. hostname must include the string "net"
#        2. TELOS branch tag (i.e. stage2.1) See https://github.com/Telos-Foundation/telos

#  run as root

echo "First arg:  $1"
echo "Second arg: $2"
if [ -z $1 ] || [ -z $2 ]
then
        echo "Insufficient arguments!"
        echo "Usage:  ./init_telos_server.sh [hostname] [git branch tag]"
        echo "For correct tag, see: https://github.com/Telos-Foundation/telos"
elif [[ $1 == *"net"* ]]
then
	apt-get update -y
	apt-get upgrade -y
	### Check if a directory does not exist ###
	echo "Checking if user 'telosuser' exists...."
	if [ ! -d "/home/telosuser" ] 
	then
	    echo "user telosuser doesn't exist.  Creating user..." 
		adduser telosuser
		usermod -aG sudo telosuser
	fi

	echo "Installing required software...."
	apt install software-properties-common git jq pigz ntp python-pip salt-minion schedtool stress cpufrequtils lm-sensors linux-tools-4.4.0-142-generic -y

	echo "Setting up ntp...."
	ntpq -p

	#Change hostname
	echo "Setting hostname to $1...."
	hostnamectl set-hostname $1
	vi /etc/hosts
	
	cd /
	chown -R telosuser /ext

	cd /ext
	mkdir $2
	chown -R telosuser $2
	ln -s /ext/$2 /ext/telos-build
	
	
	#Install Telos
	echo "Installing TelosIO Version: "$2
	cd /ext/telos-build
	git clone https://github.com/EOSIO/eos.git
	chown -R telosuser eos
	cd eos
	git checkout $2
	git submodule update --init --recursive
	cd scripts
	export HOME=/ext/telos-build/
	./eosio_build.sh
		
	#Verify Install & version
	echo "Verifying TelosIO installation...."
	../build/bin/nodeos --version
	
else
    echo "Check arguments!"
    echo "Usage:  ./init_telos_server.sh [hostname] [git branch tag]"
    echo "For correct tag, see: https://github.com/Telos-Foundation/telos"
	echo "Nothing to do.  bye."
fi
