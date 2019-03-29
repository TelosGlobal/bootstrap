#!/bin/bash
date
#Unlock wallet
/ext/telos/cleos wallet unlock -n claimer --password PW5K2jiWEAVj2coHrDPQSjQbZSGUs27CS2rNZPckLFjZPibHns7z1
#Claim
/ext/telos/cleos push action eosio claimrewards '{"owner":"telosglobal1"}' -p telosglobal1@claimer
/ext/telos/cleos wallet lock -n claimer

