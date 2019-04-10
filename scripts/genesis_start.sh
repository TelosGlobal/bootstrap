#!/bin/bash
#/usr/bin/php /root/scripts/slack.php "Jungle Test Server" "businesscat" "infrastructure-team" "Starting NodeOS"

NODEOS=/ext/telos/nodeos
DATADIR=/ext/telos
CFGDIR=/ext/telos/config
LOGDIR=/var/log/nodeos
TIMESTAMP=$(date '+%Y-%m-%d-%H_%M_%S')
$DATADIR/stop.sh

echo "Backing up log files to logbackup-$TIMESTAMP.tar"
tar cf $LOGDIR/logbackup-$TIMESTAMP.tar -C $LOGDIR stderr.txt
echo "Starting compression of logbackup-$TIMESTAMP.tar in background"
nice bzip2 -q9 $LOGDIR/logbackup-$TIMESTAMP.tar &

echo "Starting nodeos as GENESIS..."
$NODEOS --data-dir $DATADIR --config-dir $CFGDIR --genesis-json $CFGDIR/genesis.json --disable-replay-opts --delete-all-blocks &>> $LOGDIR/stderr.txt & echo $! > $DATADIR/nodeos.pid

PID=$(cat $DATADIR/nodeos.pid)
if ps -p $PID > /dev/null; then
	echo "Node OS started with pid $PID"
	echo
	exit 0
else
	echo "NodeOS failed to start" 
	echo
	exit 1
fi

