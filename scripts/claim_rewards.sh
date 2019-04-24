#!/bin/bash
date
<<<<<<< HEAD
#Unlock wallet
/ext/telos/cleos wallet unlock -n claimer --password PW5K2jiWEAVj2coHrDPQSjQbZSGUs27CS2rNZPckLFjZPibHns7z1
=======
. .secret

#Unlock wallet
/ext/telos/cleos wallet unlock -n claimer --password $CLAIM_WALLET_KEY

>>>>>>> c5def6f710f2aa2f5941fbcdef94e5a697dad3f5
#Claim
/ext/telos/cleos push action eosio claimrewards '{"owner":"telosglobal1"}' -p telosglobal1@claimer
/ext/telos/cleos wallet lock -n claimer

