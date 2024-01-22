#!/bin/bash

n=0
BPTHEN=""

echo "Waiting for TelosGlobal to finish their turn..."

# continue until BPNOW = telosglobal1 and $n equals 1
while [[ $BPNOW != 'telosglobal1' ]] || [[ $n -ne 1 ]]
do
    BPGET=`curl -sS 'https://node1.us-west.telosglobal.io/v1/chain/get_info' | jq -c '.head_block_producer'`
    # echo $BPGET
    BPNOW=${BPGET:1:12}

    # Only print current BP once
    if [ "$BPNOW" != "$BPTHEN" ]
    then
        echo "Currently on: $BPNOW"
        # echo $n
    fi

    # Exit as soon as our turn is over 
    if [ $BPNOW == "telosglobal1" ]
    then
        n=1
    fi
    sleep 1s
    BPTHEN=$BPNOW
done
echo "It's a go..."

