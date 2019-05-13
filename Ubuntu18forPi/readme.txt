REQUIRE:
	1. Registe a domain name by anyway. (Get a free domain on the https://www.freenom.com)
	2. Assign a registed domain name to your ip router.
	3. Get your ip 'server' (ex: ip of raspberry pi - ipconfig - wlan0 for wireless, eth0 for ethernet)
	4. Log in your router, forwarding some port (22 for ssh, 80 for http, 443 for SSL, 1880 for Node-RED, 1883 for mosca(MQTT-Broker), 8080 for mosca-socket, 27017 for MongoDB) to your LAN ip 'server'.
	5. Uninstall or remove all existing software (Node - MongoDB - NginX - Node-RED).

How to use Wifi replace Ethernet on ubuntu 18.04 server:
    - Modify file in folder /etc/netplan (for example: '50-cloud-init.yaml')
    - Code example : config.yaml 
    - 'sudo netplan try' to debug and push [Enter]
    - if oK type 'sudo netplan apply' to finish
    - Wait for minutes ...
