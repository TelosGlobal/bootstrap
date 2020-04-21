#!/bin/bash

echo "Getting latest MAINNET snapshot..."
cd /ext/telos/snapshots
wget https://eosmetal.io/snapshots/telos/latest.tar.gz

echo "Unpacking the files..."
tar -xzvf latest.tar.gz
rm latest.tar.gz
cd opt/telos*/data-dir/snapshots/
mv snapshot* /ext/telos/snapshots/snapshot.bin
cd /ext/telos/snapshots/
rm -Rf opt/

echo "Done.  Don't forget to empty your blocks/ and state/ folders then run ./snapstart.sh"

