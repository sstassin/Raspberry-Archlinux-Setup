# Simple reminder to build and push Docker image

#sstassin sstassin/docker-transmission-openvpn
git clone https://github.com/sstassin/docker-transmission-openvpn.git
cd sstassin/docker-transmission-openvpn
docker build . -f Dockerfile -t sstassin/docker-transmission-openvpn:debug

#Pulling to docker hub



docker images
# testings on w window machine
docker container stop transmission-ws && docker container rm transmission-ws
docker run --name=transmission-ws --cap-add=NET_ADMIN --device=/dev/net/tun \
  --dns 8.8.8.8 --dns 8.8.4.4 \
  -v ~/transmission-docker-data/:/data \
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
  -e MONITORDNS_ENABLED=true \
  --log-driver json-file \
  --log-opt max-size=10m \
  -p 9091:9091 \
  sstassin/docker-transmission-openvpn

#With port 443,80,53,1194,54783 and custom DNS Windscribe 10.255.255.1
docker container stop transmission && docker container rm transmission
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
  -e MONITORDNS_ENABLED=true \
  --log-driver json-file \
  --log-opt max-size=10m \
  -p 9091:9091 \
  sstassin/docker-transmission-openvpn:armhf
