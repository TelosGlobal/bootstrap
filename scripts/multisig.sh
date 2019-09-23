#!/bin/bash

# Use this script to sign multisig requests.  Requires the wallet password for security purposes.

echo "What is the multisig proposal name?"
read -p "Proposal: " propname
if [ -n "$propname" ]
then
    echo "Who is the proposer?"
    read -p "Proposer: " propsrname
    if [ -n "$propname" ]
    then
       echo "Checking on multisig request..."
       cleos multisig review --show-approvals $propsrname $propname | more

       read -p "VOTE (Y/N): " vote
       if [ $vote == "Y" ]
       then
           echo "We need to unlock the wallet..."
           cleos wallet unlock
           echo "Sending multisig approval..."
           cleos multisig approve $propsrname $propname '{"actor": "telosglobal1", "permission": "active"}' -p telosglobal1@active 
       else
           echo "Didn't get a YES vote.  Cancelling...bye."
       fi
    else
        echo "Didn't get a proposer name.  Cancelling...bye."
    fi
else
    echo "Didn't get a proposal name.  Cancelling...bye."
fi
cleos wallet lock

