# [MongoDB v3.6.3]

sudo apt-get install mongodb

# if you want to install ver4.0, see at :https://andyfelong.com/2019/03/mongodb-4-0-6-64-bit-on-raspberry-pi-3/
# but you cant use curl !

sudo touch /tmp/theswap
sudo chmod 600 /tmp/theswap
sudo dd if=/dev/zero of=/tmp/theswap bs=1M count=2048
sudo mkswap /tmp/theswap
sudo swapon /tmp/theswap
