#!/bin/bash

#  Usage:  ./send2chain.sh
#  Finds out how much liquid coin is available, rounds to whole number
#  If liquid coins are available, continue
#  Opens wallet $WALLET
#  Sends coin to a target Exchange $CRACCT (using $MEMO) 
#  Locks wallet

#ENTER YOUR ACCT NAME (ex. telosglobal1)
ACCT="telosglobal1"

#ENTER TARGET EXCHANGE ACCT NAME
CRACCT="xxxxxxx"

#ENTER YOUR UNIQUE MEMO IDENTIFER (Optional, but used by most exchanges to route internally)
MEMO="xxxxxxx"

#YOUR LOCAL WALLET WITH SIGNING KEYS WITHIN
WALLET="x"
#WALLET PASSWORD
PWD=""

TRIGGER=5000
KEEPAMT=500


AMT=`/ext/telos/cleos get account $ACCT -j | jq '.core_liquid_balance'`
AMTT=${AMT%.*}
COIN=${AMTT:1}

if [ $COIN -gt $TRIGGER ] 
then
    SENDAMT=`expr $COIN - $KEEPAMT`
    echo "Net send is "$SENDAMT

    # FOR TESTING ONLY
    #SENDAMT=10

    /ext/telos/cleos wallet unlock -n $WALLET --password $PWD
    echo "Balance is $AMT.  Coin is $COIN."
    /ext/telos/cleos push action eosio.token transfer "{\"from\":\""$ACCT"\" \"to\":\""$CRACCT"\" \"quantity\":\""$SENDAMT".0000 TLOS\" \"memo\":\""$MEMO"\"}" -p "$ACCT@tgtrsfr"
    /ext/telos/cleos wallet lock -n $WALLET
else
    echo "Liquid balance is less than $TRIGGER.  Balance is $AMT.  Bye."
fi
