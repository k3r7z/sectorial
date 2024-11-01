#! /bin/bash


sudo apt update

# instalar wine
sudo apt update
sudo apt-get install --install-recommends wine


# Reemplazo adobe con atril, un lector de pdf propio de mate
cd /usr/share/applications/atril.desktop ~/Escritorio


echo .............Instalación de Google Chrome.............
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb
sudo dpkg -i chrome.deb
rm chrome.deb
cp /usr/share/applications/google-chrome.desktop ~/Escritorio

echo .............Instalación de Anydesk.............
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo apt-key add -
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
sudo apt install anydesk


# Agregar la red
read -p "IP: " ip
network_name="Red"
dns="10.1.4.111/10.1.4.112"
gateway=10.7.6.200
nmcli connection add type ethernet ifname "${dev}" con-name ${network_name} ip4 "${ip}/23" gw4 ${gateway} ipv4.dns ${dns}

# Proxy
export {HTTP,HTTPS,FTP}_PROXY="http://10.10.254.218:3128"
export {http,https,ftp}_proxy="http://10.10.254.218:3128"
