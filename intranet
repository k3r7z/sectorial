#! /bin/bash

function print_help(){
  echo "intranet -d [device] -i [ip] -P [proxy] -p [proxy port] -m [network mask] -g [gateway]"
}

readonly NETWORK_NAME="red"
readonly DNS="10.1.4.111,10.1.4.112"
declare device ip proxy port gateway mask


function get_proxy(){
  proxy=$(gsettings get org.gnome.system.proxy.http host)
  port=$(gsettings get org.gnome.system.proxy.http port)
  type=$(gsettings get org.gnome.system.proxy mode)
  echo "Proxy: $proxy:$port $type"
}


function get_network_info(){
  ip=$(nmcli -t -f ipv4.addresses connection show "$NETWORK_NAME")
  gateway=$(nmcli -t -f ipv4.gateway connection show "$NETWORK_NAME")
  device=$(nmcli -t -f connection.interface-name connection show "$NETWORK_NAME")
  echo "$ip"
  echo "$gateway"
  echo "$device"
}

function set_proxy(){
	gsettings set org.gnome.system.proxy mode manual
	gsettings set org.gnome.system.proxy.http port "$port"
	gsettings set org.gnome.system.proxy.https port "$port"
	gsettings set org.gnome.system.proxy.ftp port "$port"
	gsettings set org.gnome.system.proxy.http host "$proxy"
	gsettings set org.gnome.system.proxy.https host "$proxy"
	gsettings set org.gnome.system.proxy.ftp host "$proxy"
}


function create_network_connection(){
  nmcli connection delete "$NETWORK_NAME" 1>/dev/null
	nmcli connection add type ethernet ifname "$device" con-name "$NETWORK_NAME" ip4 "$ip/$mask" gw4 "$gateway" ipv4.dns "$DNS"
  nmcli connection up "$NETWORK_NAME"
}


if [[ "$#" == 0 ]]
then
  get_proxy
  get_network_info
  exit 0
fi

while getopts 'd:i:P:p:m:g:h' OPTION
do
  case $OPTION in
    d)
      device=$OPTARG;;
    i)
      ip=$OPTARG;;
    P)
      proxy=$OPTARG;;
    p)
      port=$OPTARG;;
    m)
      mask=$OPTARG;;
    g)
      gateway=$OPTARG;;
    h | *)
      print_help
      exit 0;;
  esac
done

set_proxy
create_network_connection
exit 0
