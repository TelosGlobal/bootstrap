#!/bin/bash

# Run script as root from /root/bootstrap/
# Run as:  upgrade_telos.sh -v <3.1.1> 

while getopts v: option
do
case "${option}"
in
v) VERSION=${OPTARG};;
u) URL=${OPTARG};;
#h) PRODUCT=${OPTARG};;
#f) FORMAT=$OPTARG;;
esac
done

if [ -z "$VERSION" ]
then
    echo "No arguments passed. Use the following example: "
    echo "upgrade_telos.sh -v <3.1.1>"
    echo "Exiting..."
    exit
fi

#Build URL
if [ -z "$URL" ]
then
    URL="https://github.com/AntelopeIO/leap/releases/download/v$VERSION/leap_$VERSION-ubuntu18.04_amd64.deb"
fi
echo "Using URL: $URL"

function validate_url(){
    wget --spider $1
    return $?
}

if validate_url $URL; then

   echo "Stopping nodeos..."
   /ext/telos/stop.sh
   cd /tmp

   echo "Removing current EOSIO package (if exists)..."
   sudo apt remove eosio -y

   echo "Removing current LEAP package..."
   sudo apt remove leap -y

   echo "Removing symlinks (if they exist)..."
   rm /ext/telos/nodeos
   rm /ext/telos/cleos

   echo "Cloning v$VERSION..."
   wget $URL

   echo "Installing v$VERSION..."
   sudo apt install ./leap_$VERSION-ubuntu18.04_amd64.deb -y

   chown -R telosuser /ext/telos/

   echo "Upgraded to LEAP v$VERSION.  Login as telosuser and restart nodeos."

else
   echo "File not found at: "$URL
   echo "Check version and try again.  Upgrade aborted."
fi

