#! /bin/bash


echo """export HTTP_PROXY=\"http://10.7.6.6:3128/\"
export HTTPS_PROXY=\"http://10.7.6.6:3128/\"
export FTP_PROXY=\"http://10.7.6.6:3128/\"
export NO_PROXY=\"localhost,127.0.0.0/8,::1, 10.7.6.*,10.7.7.*,*.santafe.gov.ar,*.sfnet\"
export http_proxy=\"http://10.7.6.6:3128/\"
export https_proxy=\"http://10.7.6.6:3128/\"
export ftp_proxy=\"http://10.7.6.6:3128/\"
export no_proxy=\"localhost,127.0.0.0/8,::1, 10.7.6.*,10.7.7.*,*.santafe.gov.ar,*.sfnet\"""" >> environment


confirm='N'
while [[ $confirm != 'S' ]] && [[ $confirm != 's' ]]
do
	read -p "IP: " ip
	read -p "Confirmar ${ip} (S/N)?: " confirm
done

read -p "Máscara de red (255.255.254.0): " netmask
netmask="${netmask:=255.255.254.0}"

read -p "Puerta de enlace (10.7.6.200): " gateway
gateway="${gateway:=10.7.6.200}"

read -p "DNS (10.1.4.111 y 10.1.4.112): " gateway
dns="${dns:=10.1.4.111,10.1.4.112}"

echo """network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enp2s0:
      dhcp4: no
      dhcp6: no
      addresses: [$2/$netmask]
      gateway4: $gateway
      nameservers:
        addresses: [$dns]""" # > test
