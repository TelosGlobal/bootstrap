#!/bin/bash

#  Usage:  ./claim_rewards.sh
#  Opens wallet $WALLET
#  Claims any eligible BP rewards
#  Locks wallet

ACCT="telosglobal1"

WALLET="claimer"
PWD=""

date
#Unlock wallet
/ext/telos/cleos wallet unlock -n $WALLET --password $PWD

#Claim
/ext/telos/cleos -u http://10.126.107.14:8888 push action eosio claimrewards '{"owner":"$ACCT"}' -p $ACCT@claimer
/ext/telos/cleos wallet lock -n $WALLET
