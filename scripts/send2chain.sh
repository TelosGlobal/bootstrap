#!/bin/bash

#  Usage:  ./send2chain.sh
#  Finds out how much liquid coin is available, rounds to whole number
#  If liquid coins are available, continue
#  Opens wallet $WALLET
#  Sends coin to Chainrift $CRACCT (using $MEMO) 
#  Locks wallet

. .secret

AMT=`/ext/telos/cleos get account $ACCT -j | jq '.core_liquid_balance'`
AMTT=${AMT%.*}
COIN=${AMTT:1}

if [ $COIN -gt 0 ] 
then
    /ext/telos/cleos wallet unlock -n $SENDWALLET --password $SENDKEY
    /ext/telos/cleos push action eosio.token transfer '{"from":"$ACCT","to":"$CRACCT","quantity":"$COIN.0000 TLOS","memo":"$MEMO"}' -p "$ACCT@transfer"
    /ext/telos/cleos wallet lock -n $SENDWALLET
else
    echo "Liquid balance is less than 1.  Balance is $AMT.  Bye."
fi
