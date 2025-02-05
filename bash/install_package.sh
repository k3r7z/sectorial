#! /bin/bash

readonly PROXY_PORT="3128"
readonly ADMIN_PROXY="10.7.6.6"
packages="$*"

gsettings set org.gnome.system.proxy mode manual
gsettings set org.gnome.system.proxy.http port "$PROXY_PORT"
gsettings set org.gnome.system.proxy.https port "$PROXY_PORT"
gsettings set org.gnome.system.proxy.ftp port "$PROXY_PORT"
gsettings set org.gnome.system.proxy.http host "$ADMIN_PROXY"
gsettings set org.gnome.system.proxy.https host "$ADMIN_PROXY"
gsettings set org.gnome.system.proxy.ftp host "$ADMIN_PROXY"



sudo apt update
sudo apt install -y "$packages"
