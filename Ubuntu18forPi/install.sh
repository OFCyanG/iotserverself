#!/bin/bash

# [NginX + HTTPS + Node-RED +MongoDB]
# Shell script for Ubuntu18 

# OS 
# Linux ubuntu 4.15.0-1034-raspi2 #36-Ubuntu GNU/Linux
# VERSION="18.04.2 LTS (Bionic Beaver)"

# IMG : ubuntu-18.04.2-preinstalled-server-arm64+raspi3.img

sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade
sudo apt-get install -y git curl gcc g++ make

# [MongoDB v3.6.3]

sudo apt-get install mongodb

# if you want to install ver4.0, see at :https://andyfelong.com/2019/03/mongodb-4-0-6-64-bit-on-raspberry-pi-3/
# but you cant use curl !

sudo touch /tmp/theswap
sudo chmod 600 /tmp/theswap
sudo dd if=/dev/zero of=/tmp/theswap bs=1M count=2048
sudo mkswap /tmp/theswap
sudo swapon /tmp/theswap

sudo service mongodb start

# [Node-RED]

sudo apt-get update && sudo apt-get upgrade
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential
sudo npm install -g --unsafe-perm node-red node-red-admin --allow-root

script_node_red_services="[Unit]\nDescription=Node-RED\nAfter=syslog.target network.target\n\n[Service]\nExecStart=`which 'node-red'`-pi --max-old-space-size=128 -v\nRestart=on-failure\nKillSignal=SIGINT\nSyslogIdentifier=node-red\nStandardOutput=syslog\nWorkingDirectory=/home/`echo $USER`/\nUser=`echo $USER`\n\n[Install]\nWantedBy=multi-user.target"

echo -e $script_node_red_services > ./node-red.service
sudo cp -f ./node-red.service /etc/systemd/system/node-red.service

sudo systemctl daemon-reload
sudo systemctl enable node-red.service
sudo systemctl start node-red.service

# Node-RED Admin Get Hash-pw for Auth 
echo "Enter password for node-red!"
read passnode
hashcode=`echo $passnode | node-red-admin hash-pw`
hashcode=${hashcode:19}
echo "Created hash-pw from your produced password."
echo "Password is:"
echo $hashcode

script_auth_none="131i adminAuth: {type: \"credentials\",users: [{username: \"admin\",password: \"`echo $hashcode`\",permissions: \"*\"}]},"
echo $script_auth_none > sed.cmd
# Modify name of file for release
sudo sed -i -f sed.cmd ~/.node-red/settings.js
sudo systemctl restart node-red.service
