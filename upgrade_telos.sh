#!/bin/bash

# Run script as root from /root/bootstrap/
# Run as:  upgrade_telos.sh -v <1.7.2>  (without the v)

while getopts v: option
do
case "${option}"
in
v) VERSION=${OPTARG};;
#d) DATE=${OPTARG};;
#p) PRODUCT=${OPTARG};;
#f) FORMAT=$OPTARG;;
esac
done

if [ -z "$VERSION" ]
then
    echo "No arguments passed.  Exiting..."
    exit
fi

echo "Stopping nodeos..."
/ext/telos/stop.sh
cd /tmp

echo "Removing current EOSIO package..."
sudo apt remove eosio -y

echo "Cloning v$VERSION..."
wget https://github.com/eosio/eos/releases/download/v$VERSION/eosio_$VERSION-1-ubuntu-18.04_amd64.deb

echo "Installing v$VERSION..."
sudo apt install ./eosio_$VERSION-1-ubuntu-18.04_amd64.deb

echo "Updating symlinks..."
rm /ext/telos/nodeos
rm /ext/telos/cleos
ln -s /usr/opt/eosio/$VERSION/bin/nodeos /ext/telos/nodeos
ln -s /usr/opt/eosio/$VERSION/bin/cleos /ext/telos/cleos

chown -R telosuser /ext/telos/

echo "Upgraded to EOSIO v$VERSION.  Login as telosuser and restart nodeos."
