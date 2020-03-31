#!/bin/bash

NODEOS=/ext/telos/nodeos
DATADIR=/ext/telos
CFGDIR=/ext/telos/config
SNAPFILE=/ext/telos/snapshots/snapshot.bin
LOGDIR=/var/log/nodeos
TIMESTAMP=$(date '+%Y-%m-%d-%H_%M_%S')
$DATADIR/stop.sh

echo "Backing up log files to logbackup-$TIMESTAMP.tar"
tar cf $LOGDIR/logbackup-$TIMESTAMP.tar -C $LOGDIR stderr.txt
echo "Starting compression of logbackup-$TIMESTAMP.tar in background"
nice bzip2 -q9 $LOGDIR/logbackup-$TIMESTAMP.tar &

$NODEOS --data-dir $DATADIR --config-dir $CFGDIR --snapshot $SNAPFILE &>> $LOGDIR/stderr.txt & echo $! > $DATADIR/nodeos.pid

PID=$(cat $DATADIR/nodeos.pid)
if ps -p $PID > /dev/null; then
	echo "Node OS started with pid $PID"
	if [[ $(hostname) == *"prdr"* ]]
        then
            echo "I'm a producer node...setting affinity."
	    taskset -p -c 0 $PID
	    echo "Set PID $PID to CPU 0."
	fi
	echo
	exit 0
else
	echo "NodeOS failed to start" 
	echo
	exit 1
fi

