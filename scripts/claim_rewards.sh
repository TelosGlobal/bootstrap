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
cleos wallet unlock -n $WALLET --password $PWD

#Claim
cleos -u http://10.126.107.14:8888 push action eosio claimrewards '{"owner":"$ACCT"}' -p $ACCT@claimer
cleos wallet lock -n $WALLET
