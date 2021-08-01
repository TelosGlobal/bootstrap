#!/bin/bash

echo "Getting latest MAINNET snapshot..."
cd /ext/telos/snapshots
wget http://cdn.eosarabia.net/snapshots/telosm/latest.tar.gz

echo "Unpacking the files..."
tar -xzvf latest.tar.gz
rm latest.tar.gz
cd mnt/tmainnet/
mv snapshot* /ext/telos/snapshots/snapshot.bin
cd /ext/telos/snapshots/
rm -Rf mnt/

echo "Done.  Don't forget to empty your blocks/ and state/ folders then run ./snapstart.sh"

