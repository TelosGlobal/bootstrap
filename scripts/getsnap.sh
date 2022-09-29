#!/bin/bash

echo "Getting latest MAINNET snapshot..."
cd /ext/telos/snapshots
wget https://snapshots.greymass.network/telos/latest.tar.gz

echo "Unpacking the files..."
tar -xzvf latest.tar.gz
rm latest.tar.gz
cd /ext/telos/

echo "Done.  Don't forget to empty your blocks/ and state/ folders then run ./snapstart.sh"

