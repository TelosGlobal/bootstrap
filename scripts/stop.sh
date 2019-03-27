#!/bin/bash

DATADIR=/ext/telos

    if [ -f $DATADIR"/nodeos.pid" ]; then
        pid=$(cat $DATADIR"/nodeos.pid")
        echo "Stopping NodeOS with pid $pid"
        kill $pid
        rm -r $DATADIR"/nodeos.pid"

        echo -ne "Stopping Nodeos"

        while true; do
            [ ! -d "/proc/$pid/fd" ] && break
            echo -ne "."
            sleep 1
        done
        echo -ne "\rNodeos stopped. \n"

    fi

