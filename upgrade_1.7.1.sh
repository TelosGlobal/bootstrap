#!/bin/bash

# Run script as root from /root/bootstrap/

echo "Stopping nodeos..."
/ext/telos/stop.sh
cd /tmp

echo "Cloning v1.7.1..."
wget https://github.com/eosio/eos/releases/download/v1.7.1/eosio_1.7.1-1-ubuntu-18.04_amd64.deb

echo "Installing v1.7.1..."
sudo apt install ./eosio_1.7.1-1-ubuntu-18.04_amd64.deb

echo "Updating symlinks..."
rm /ext/telos/nodeos
rm /ext/telos/cleos
ln -s /usr/opt/eosio/1.7.1/bin/nodeos /ext/telos/nodeos
ln -s /usr/opt/eosio/1.7.1/bin/cleos /ext/telos/cleos

chown -R telosuser /ext/telos/

echo "Upgraded to EOSIO v1.7.1.  Login as telosuser and restart nodeos."
