#! /bin/sh

#Installing docker using the shell script
# https://docs.docker.com/install/linux/docker-ce/debian/#install-using-the-convenience-script
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker your-user



#-Installing Docker Hypriot Image to RPI
#-http://blog.hypriot.com

#Warning : for rpi0 at the date at 2018-11-28 
#There is a bug in the new vesrion of docker with arm6
# Need to downgrade until the issue is resolved
# See : https://github.com/moby/moby/issues/38175#issuecomment-439733278
sudo apt-get install docker-ce=18.06.1~ce~3-0~raspbian

#-Setting up several usefull container
#-More info at https://docs.docker.com/engine/reference/run/
docker container ls
docker image ls

#Adding current user to docker group to allow start of docker
sudo groupadd docker
sudo usermod -a $USER docker
sudo usermod alarm -aG docker

#Good stats to display about container
docker stats --all --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}"

#Testing with hello world
docker run --name hello-world hypriot/armhf-hello-world

#Rpi Portainer : https://store.docker.com/community/images/hypriot/rpi-portainer
docker volume create portainer_data
docker container stop portainer && docker container rm portainer
docker run --name portainer --restart=always -d -p 9000:9000 \
 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data \
 portainer/portainer:arm
 
#WatchTower : https://hub.docker.com/r/v2tec/watchtower
docker run -d --name watchtower --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  v2tec/watchtower:armhf-latest

 
#RPI Webcam : https://hub.docker.com/r/nieleyde/rpi-webcam/
#Use the http request node to take a pic using this url:
#http://<ipaddress>:8080/camera/snapshot
#Use the http request node to retrieve the most recent camera shot using this url:
#http://<ipaddress>:8080/pictures/image.jpg
docker run -p 8080:8080 -d  --privileged nieleyde/rpi-webcam


#Rpi Monitor : https://store.docker.com/community/images/neoraptor/rpi-monitor
docker container stop rpimonitor && docker container rm rpimonitor
docker run -d --name=rpimonitor --restart=always -p 8888:8888 neoraptor/rpi-monitor

#Samba : https://github.com/dastrasmue/rpi-samba   --CONFIRMED WORKING on 2018-08-24 on RPI2
docker container stop rpi2-samba && docker container rm rpi2-samba
docker run --name rpi2-samba -d \
  --restart='always' --hostname 'rpi2-filer' \
  -p 137:137/udp -p 138:138/udp -p 139:139 -p 445:445 -p 445:445/udp \
  -v /media/HDD1000G:/share/HDD1000G -v /var/log:/share/log \
  dastrasmue/rpi-samba:v3 \
  -u "pi:pi" \
  -s "logs:/share/log:ro" \
  -s "HDD1000G:/share/HDD1000G:rw:pi"

#TransmissionOpenVPN : https://github.com/haugene/docker-transmission-openvpn
echo "PUREVPNUSERNAME=myvpnusername" >> /etc/environment
echo "PUREVPNPWD=myvpnpwd" >> /etc/environment
#echo "WSVPNUSERNAME=myvpnusername" >> /etc/environment
#echo "WSVPNPWD=myvpnpwd" >> /etc/environment
sudo echo "WSVPNUSERNAME=myvpnusername" >> /etc/environment
sudo echo "WSVPNPWD=myvpnpwd" >> /etc/environment

mkdir -p /media/HDD1000G/Torrents-Downloads
chmod 766 

#using WIndscribe
docker container stop transmission && docker container rm transmission
docker pull haugene/transmission-openvpn:latest-armhf
docker run --name=transmission --cap-add=NET_ADMIN --device=/dev/net/tun \
  --dns 208.67.222.222 --dns 208.67.222.220 --restart='always' -d \
  -v /media/HDD1000G/:/data \
  -v /etc/localtime:/etc/localtime:ro \
  -e OPENVPN_PROVIDER=WINDSCRIBE \
  -e OPENVPN_CONFIG=Norway-udp \
  -e OPENVPN_USERNAME=$WSVPNUSERNAME \
  -e OPENVPN_PASSWORD=$WSVPNPWD \
  -e LOCAL_NETWORK=192.168.0.0/24 \
  -e ENABLE_UFW=false \
  -e OPENVPN_OPTS="--inactive 3601 --ping 10 --ping-exit 60" \
  -e DROP_DEFAULT_ROUTE=true \
  -e TRANSMISSION_DOWNLOAD_DIR="/data/Torrents-Downloads" \
  -e TRANSMISSION_INCOMPLETE_DIR_ENABLED=false \
  -e TRANSMISSION_RATIO_LIMIT=0.1 \
  -e TRANSMISSION_RATIO_LIMIT_ENABLED=true \
  --log-driver json-file \
  --log-opt max-size=10m \
  -p 9091:9091 \
  haugene/transmission-openvpn:latest-armhf


#using on Ubuntu Stef 2 Laptop
docker container stop transmission-ws && docker container rm transmission-ws
docker run --name=transmission-ws --cap-add=NET_ADMIN --device=/dev/net/tun \
  --dns 8.8.8.8 --dns 8.8.4.4 --restart='always' \
  -v /home/sstassin/transmission-docker-data/:/data \
  -v /etc/localtime:/etc/localtime:ro \
  -e OPENVPN_PROVIDER=WINDSCRIBE \
  -e OPENVPN_CONFIG=Netherlands-tcp,Norway-tcp,Sweden-tcp,Germany-tcp \
  -e OPENVPN_USERNAME=$WSVPNUSERNAME \
  -e OPENVPN_PASSWORD=$WSVPNPWD \
  -e LOCAL_NETWORK=192.168.0.0/24 \
  -e ENABLE_UFW=false \
  -e OPENVPN_OPTS="--inactive 3601 --ping 10 --ping-exit 60" \
  -e DROP_DEFAULT_ROUTE=true \
  -e TRANSMISSION_DOWNLOAD_DIR="/data/Torrents-Downloads" \
  -e TRANSMISSION_INCOMPLETE_DIR_ENABLED=false \
  --log-driver json-file \
  --log-opt max-size=10m \
  -p 9091:9091 \
  haugene/transmission-openvpn


  Testing

