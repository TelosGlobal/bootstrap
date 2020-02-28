#!/bin/bash

echo "What type of node am I?"

if [[ $(hostname) == *"prdr"* ]]
then
    echo "I'm a producer node."
elif [[ $(hostname) == *"node"* ]]
then
    echo "I am just a node."
else
    echo "I don't know what I am."
fi
