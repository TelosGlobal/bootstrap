#!/bin/bash
date
. .secret

#Unlock wallet
/ext/telos/cleos wallet unlock -n claimer --password $CLAIM_WALLET_KEY

#Claim
/ext/telos/cleos push action eosio claimrewards '{"owner":"telosglobal1"}' -p telosglobal1@claimer
/ext/telos/cleos wallet lock -n claimer

