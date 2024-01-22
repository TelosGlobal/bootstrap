#/bin/bash

echo "Getting latest MAINNET snapshot..."
cd /ext/telos/snapshots

if [[ $(hostname) == *"testnet"* ]]
then
  echo "I'm a testnet node...fetching testnet snap."
  ##TESTNET
  wget https://snapshots.eosnation.io/telostest-v6/latest
else
  #MAINNET
  wget https://snapshots.eosnation.io/telos-v6/latest
fi
echo

echo "Unpacking the files..."
zstd -o snapshot.bin --rm latest
#rm snapshot.bin
#mv latest.zst snapshot.bin

echo "Done.  Don't forget to empty your blocks/ and state/ folders then run ./snapstart.sh"

