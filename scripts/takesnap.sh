#!/bin/bash

timestamp=`date +%Y-%m-%d_%H-%MUTC`

cd /ext/telos/
echo "*Starting Block Backup*"
echo "Stopping NodeOS"
./stop.sh > /dev/null
#sudo zfs list -t snapshot -o name | grep block-backup | tac | tail -n +16 | sudo xargs -n 1 zfs destroy -r
sudo zfs list -t snapshot -o name | grep block-backup | tac | tail -n +12 | awk '{print "Destroying: "$0; system("sudo zfs destroy -r "$0); system("sleep 5")}'
sudo zfs snapshot eosio/ext@block-backup-$timestamp
./start.sh > /dev/null

free=`df -h | grep eosio/ext | awk '{print $4}'` 
 
echo "block-backup-$timestamp.tar.bz2 -- $flsize"
echo "Disk space available: $free"
echo "*Block Backup Complete*"

