#! /bin/sh
# Simple script to store all the necessary steps to setup my Minibian ARM on my raspberry 1/2/3

#-Get The image at https://minibianpi.wordpress.com
#-Burn It to the SD card using DD
#-Default user is root : raspberry

#-Using Noob, need to enable ssh by creatin a ssh file on the root
users: root/raspberry

#-Installing necessary stuff
apt-get install raspi-config tmux
#Expanding the user space to the entire sd card
raspi-config
apt-get dist-upgrade
apt-get install sudo perl htop git openvpn wget unzip zip zsh 
apt-get install dnsutils nmon nano cifs-utils traceroute mc ncdu samba

#-Creating user
sudo adduser pi
#-Adding alarm to the sudoers users (https://stackoverflow.com/questions/12736351/exit-save-edit-to-sudoers-file-putty-ssh)
visudo
#Navigate to the place you wish to edit using the up and down arrow keys.
#Press insert to go into editing mode.
#Make your changes - for example: user ALL=(ALL) ALL.
#Note - it matters whether you use tabs or spaces when making changes.
#Once your changes are done press esc to exit editing mode.
#Now type :wq to save and press enter.

#-Generating locale
sudo nano /etc/locale.gen
sudo locale-gen
sudo nano /etc/locale.conf  (set LANG = fr_FR.UTF-8 or other)
sudo shutdown -r now

#-Enabling ssh root login
#-https://askubuntu.com/questions/469143/how-to-enable-ssh-root-access-on-ubuntu-14-04#489034
sudo passwd

#-Defining an Static IP Adress
# https://www.howtogeek.com/howto/ubuntu/change-ubuntu-server-from-dhcp-to-a-static-ip-address/
nano /etc/network/interfaces
auto eth0
iface eth0 inet static
address 192.168.0.10
netmask 255.255.255.0
network 192.168.0.0
broadcast 192.168.0.255
gateway 192.168.0.1
dns-nameservers 192.168.0.1
ifdown eth0 && ifup eth0

# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'
nano /etc/dhcpd.conf


#-Mounting my External Hard Drive
mkdir -p /media/HDD1000G
echo "UUID=eebde59c-f5ea-45bb-8671-71e1d4468094 /media/HDD1000G ext4 noatime,nofail 0 0" >> /etc/fstab
mount -a ext4
sudo chown pi:pi -Rv /media/HDD1000G
sudo chmod 666 -Rv /media/HDD1000G

#-Mounting a samba shared drive 
#-https://wiki.ubuntu.com/MountWindowsSharesPermanently
mkdir -p /media/HDD1000G
echo -e 'username=msusername\npassword=mspassword\n' > ~/.smbcredentials
chmod 600 ~/.smbcredentials
echo '//192.168.0.10/HDD1000G /media/HDD1000G cifs credentials=/root/.smbcredentials,nofail,iocharset=utf8,sec=ntlm 0 0 ' >> /etc/fstab
mount -a -v



#-Settings Samba
cd /etc/samba
rm smb.conf && rm smbusers
wget raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/samba/smb.conf
systemctl enable smbd && systemctl start smbd
systemctl enable nmbd && systemctl start nmbd

#-Installing WebMin
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.870_all.deb
dpkg -i webmin_1.870_all.deb
apt --fix-broken install 

#-Installing Shellinabox
yaourt shellinabox-git
systemctl enable shellinabox-git && systemctl start shellinabox-git

#-Installing Nginx and setting up reverse proxy
yaourt -S nginx

#-Generating and installing self-signed certificate
# https://wiki.archlinux.org/index.php/Nginx#TLS.2FSSL
cd /etc/nginx
rm nginx.conf
wget raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/nginx/nginx.conf
mkdir /etc/nginx/ssl
cd /etc/nginx/ssl
openssl req -new -x509 -nodes -newkey rsa:4096 -keyout server.key -out server.crt -days 1095
chmod 400 server.key
chmod 444 server.crt
wget raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/nginx/ssl/server.crt
wget raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/nginx/ssl/server.key
systemctl restart nginx

#-Installin ezServerMonitor
sudo -i
cd /usr/share/nginx/html/
wget https://www.ezservermonitor.com/esm-web/downloads/version/2.5
unzip -o -d ./ 2.5
rm 2.5

#-INstalling and configuring transmission
# https://wiki.archlinux.org/index.php/Transmission
yaourt transmission-cli
yaourt transmission-remote-cli-git
yaourt python2-geoip
yaourt adns-python
sudo systemctl enable transmission
sudo systemctl start transmission
sudo systemctl stop transmission
cd /var/lib/transmission/.config/transmission-daemon
rm settings.json
wget https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/var/lib/transmission/.config/transmission-daemon/settings.json

#-Installing LXDE
# https://wiki.archlinux.org/index.php/LXDE
apt-get install xfce4 xfce4-goodies

#-Installing vncserver
#-Configuring the desktop https://support.realvnc.com/Knowledgebase/Article/View/345/0/
apt-get install realvnc-vnc-server
vncserver
vncserver -kill :1


cd /home/alarm/.vnc
rm xstartup
wget  https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/home/alarm/.vnc/xstartup
chmod u+x xstartup
rm config
https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/home/alarm/.vnc/config
sudo loginctl enable-linger pi
systemctl --user enable vncserver@:1
systemctl --user start vncserver@:1

#-Installing and configuring novnc
#-https://github.com/novnc/noVNC
git clone https://github.com/novnc/noVNC.git
cd noVNC
./utils/launch.sh --vnc localhost:5901


#-Installing and configuring my OpenVpn connection
# https://support.purevpn.com/linux-openvpn-command/
mkdir -p /var/log/openvpn/client
cd /etc/openvpn/
rm vpn-*.sh
wget https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/openvpn/vpn-down.sh
wget https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/openvpn/vpn-up.sh
chmod u+x vpn-*.sh
cd /etc/openvpn/client
rm *.sh 
wget https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/openvpn/client/monitor-openvpn-connection.sh 
wget https://raw.githubusercontent.com/sstassin/Raspberry-Archlinux-Setup/master/etc/openvpn/client/start-purevpn.sh
chmod u+x *.sh
wget https://s3-us-west-1.amazonaws.com/heartbleed/linux/linux-files.zip
cp Linux\ OpenVPN\ Updated\ files/ca.crt ./ca.crt
cp Linux\ OpenVPN\ Updated\ files/Wdc.key ./Wdc.key
nano auth.txt
ln -sf Linux\ OpenVPN\ Updated\ files/TCP/Netherlands1-tcp.ovpn clien.conf
bash monitor-openvpn-connection.sh
tail -f /var/log/openvpn/client


