# Install NGINX
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install -y nginx

# SSL for Nginx  
sudo apt-get update
sudo apt-get install -y letsencrypt

echo "Enter server name for confirming SSL certificate: (ex: filiotteam.ml)"
read server_name

sudo cp -f -r  /var/www/html /var/www/$server_name

nginx_conf_http="server{\n\tlisten 80 default_server;\n\tlisten [::]:80 default_server;\n\troot /var/www/$server_name;\n\tserver_name $server_name;\n\tlocation ~/.well-known {\n\t\tallow all;\n\t}\n}"

nginx_conf_https="server{\n\tlisten\t\t80;\n\tserver_name\t$server_name;\n\treturn\t\t301 https://\$server_name\$request_uri;\n}\n\nserver{\n\tlisten\t\t443 ssl http2;\n\tserver_name\t$server_name;\n\n\tssl_certificate\t\t/etc/letsencrypt/live/$server_name/fullchain.pem;\n\tssl_certificate_key\t/etc/letsencrypt/live/filiotteam.ml/privkey.pem;\n\n\tinclude\tsnippets/ssl-params.conf;\n\n\troot\t/var/www/$server_name;\n\n\tlocation / {\n\t\tproxy_pass http://localhost:1880;\n\t\tproxy_set_header Host \$host;\n\t\tproxy_set_header X-Real-IP \$remote_addr;\n\t\tproxy_http_version 1.1;\n\t\tproxy_set_header Upgrade \$http_upgrade;\n\t\tproxy_set_header Connection \"upgrade\";\n\t}\n\n\tlocation ~ /.well-known {\n\t\tallow all;\n\t}\n}"

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
