#! /bin/bash
#Install Zabbit Agent

#function to call after installing agent
function install_agent {
    apt update
    apt install zabbix-agent2 zabbix-agent2-plugin-*

    #Add zabbix server into zabbix.conf
    sed -i.bak 's/Server=127\.0\.0\.1/Server=127\.0\.0\.1\,63\.250\.47\.6/' /etc/zabbix/zabbix_agent2.conf

    #restart and enable for start on reboot
    systemctl restart zabbix-agent2
    systemctl enable zabbix-agent2
    rm zabbix-release*
}

#Get version
ver=`lsb_release -rs| awk -F'.' '{print $1}'`;
echo "OS Version: "$ver

#Check version and run correct install script
if [ $ver == 18 ] 
then
    wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu18.04_all.deb
    dpkg -i zabbix-release_6.4-1+ubuntu18.04_all.deb
    install_agent
elif [ $ver == 20 ] 
then
    wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu20.04_all.deb
    dpkg -i zabbix-release_6.4-1+ubuntu20.04_all.deb
    install_agent
elif [ $ver == 22 ] 
then
    wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
    dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
    install_agent
else
    echo "No compatible OS version found."
fi



