#!/bin/bash

echo "Getting latest MAINNET snapshot..."
cd /ext/telos/snapshots

if [[ $(hostname) == *"testnet"* ]]
then
  echo "I'm a testnet node...fetching testnet snap."
  ##TESTNET
  wget -O latest.zst https://snapshots.eosnation.io/telostest-v6/latest
else
  #MAINNET
  wget -O latest.zst https://snapshots.eosnation.io/telos-v6/latest
fi
echo

rm snapshot.bin
echo "Unpacking the files..."
zstd -d latest.zst
rm latest.zst
mv latest snapshot.bin

echo "Done.  Don't forget to empty your blocks/ and state/ folders then run ./snapstart.sh"

