#!/bin/bash

# [NginX + HTTPS + Node-RED + MongoDB]
# Shell script for raspian 
# Test : Linux raspberrypi 4.14.98-v7+ #1200 SMP Tue Feb 12 20:27:48 GMT 2019 armv7l GNU/Linux
# Version 0.1
# NOTE: read "README" file before running script 

# Install packet software 

sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade
sudo apt-get install curl
sudo apt-get install gcc g++ make


# Install NGINX
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install -y nginx


# Install Mongodb

sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade
sudo apt-get install -y mongodb

sudo touch /tmp/theswap
sudo chmod 600 /tmp/theswap
sudo dd if=/dev/zero of=/tmp/theswap bs=1M count=2048
sudo mkswap /tmp/theswap
sudo swapon /tmp/theswap

# Install Node-RED

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

script_auth_none="131i adminAuth: {type: \"credentials\",users: [{username: \" admin\",password: \"`echo $hashcode`\",permissions: \"*\"}]},"
echo $script_auth_none > sed.cmd
# Modify name of file for release
sudo sed -i -f sed.cmd ~/.node-red/settings.js
sudo systemctl restart node-red.service

# SSL for Nginx  
sudo apt-get update
sudo apt-get install -y letsencrypt

echo "Enter server name for confirming SSL certificate: (ex: filiotteam.ml)"
read server_name

sudo cp -f -r  /var/www/html /var/www/$server_name

nginx_conf_http="server{\n\tlisten 80 default_server;\n\tlisten [::]:80 default_server;\n\troot /var/www/$server_name;\n\tserver_name $server_name;\n\tlocation ~/.well-known {\n\t\tallow all;\n\t}\n}"

nginx_conf_https="server{\n\tlisten\t\t80;\n\tserver_name\t$server_name;\n\treturn\t\t301 https://\$server_name\$request_uri;\n}\n\nserver{\n\tlisten\t\t443 ssl http2;\n\tserver_name\t$server_name;\n\n\tssl_certificate\t\t/etc/letsencrypt/live/$server_name/fullchain.pem;\n\tssl_certificate_key\t/etc/letsencrypt/live/filiotteam.ml/privkey.pem;\n\n\tinclude\tsnippets/ssl-params.conf;\n\n\troot\t/var/www/$server_name;\n\n\tlocation / {\n\t\tproxy_pass http://localhost:1880;\n\t\tproxy_set_header Host \$host;\n\t\tproxy_set_header X-Real-IP $remote_addr;\n\t\tproxy_http_version 1.1;\n\t\tproxy_set_header Upgrade \$http_upgrade;\n\t\tproxy_set_header Connection \"upgrade\";\n\t}\n\n\tlocation ~ /.well-known {\n\t\tallow all;\n\t}\n}"

echo -e $nginx_conf_http > default_f
echo -e $nginx_conf_https > default_s

sudo cp -f default_f /etc/nginx/sites-available/default
sudo systemctl restart nginx.service

sudo letsencrypt certonly -a webroot --webroot-path=/var/www/$server_name -d $server_name

sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

ssl_param="ssl_protocols TLSv1 TLSv1.1 TLSv1.2;\nssl_prefer_server_ciphers on;\nssl_ciphers \"EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH\";\nssl_ecdh_curve secp384r1;\nssl_session_cache shared:SSL:10m;\nssl_stapling on;\nssl_stapling_verify on;\nssl_dhparam /etc/ssl/certs/dhparam.pem;\n\nresolver 8.8.8.8 8.8.4.4 valid=300s;\nresolver_timeout 5s;\n\nadd_header Strict-Transport-Security \"max-age=63072000; includeSubdomains\";\nadd_header X-Frame-Options DENY;\nadd_header X-Content-Type-Options nosniff;"

echo -e $ssl_param > ssl-params.conf
sudo cp -f ssl-params.conf /etc/nginx/snippets/ssl-params.conf

sudo cp -f default_s /etc/nginx/sites-available/default

sudo systemctl restart nginx.service

echo "Reboot is neccessary !!!"

