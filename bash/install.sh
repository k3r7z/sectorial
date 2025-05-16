#! /bin/bash

readonly HEIGHT=15
readonly WIDTH=100
readonly BACKTITLE="Instalador de Linux (beta)"
readonly SCAN_DIR=/home/usuario/scan
readonly SHARE_DIR=/home/usuario/compartida
readonly DNS='10.1.4.111,10.1.4.112'
readonly PROXY_PORT="3128"
readonly SCAI_PROXY="10.10.254.218"
readonly INSTALL_PROXY="10.7.6.6"
readonly NETWORK_NAME="red"
readonly ADMIN_NETWORK_NAME="admin"
readonly PACKAGES=(
    "lsb" # Linux standard base
    "x11vnc" # programa para control remoto de entornos linux
    "libreoffice" # suite de herramientas
    "ssh"
    "printer-driver-cups-pdf"
    "openssh-server" # protocolo para control remoto de terminales
    "unrar" #para rars
    "unzip" # para zips
    "vlc" # reproductor de audio y videos
    "mc"
    "myspell-es"
    "thunderbird" # correo
    "thunderbird-locale-es" # en castellano
    "myspell-es" # correcion en castellano para libreoffice
    "ubuntu-restricted-extras" # algunas utilidades para ubuntu
    "firefox-locale-es" # traducción de firefox
    "ntp" # Protocolo para la sincronizacion del reloj
    "hplip"
    "x3270" # El SIE
    "hplip-gui" # drivers para impresoras HP
    "gimp" # editor de imagenes
    "inkscape" # editor de imagenes vectorial
    "neovim" # editor de texto
    "wine" # interfaz para windows
    "ocsinventory-agent" # programa para gestión de inventario
    "cifs-utils" # utilidades para el protocolo cifs
    "net-tools" # utilidades de red
    "ethtool" # utilidad para controlar los drivers de red y hardware
    "putty" # cliente de terminal ssh/telnet integrada
    "ubuntu-restricted-extras"
    "ubuntu-mate-desktop" # entorno mate
    "samba" # protocolo para comparticion de archivos
    "caja-share" #?
    "gnome-panel" #?
    "net-tools" #?
    "dconf-editor" #editor para el dconf
    "ethtool" #?
    "nast" #?
    "ntp" #?
    "pidgin" #?
    "pidgin-otr" #?
    "putty" #?
    "scribus" #?
    "scribus-doc" #?
    "system-config-printer-gnome" #?
    "yad" #?
    "google-chrome-stable" # Google chrome
    "anydesk"
)
declare user="usuario"
declare passwd="usuario"
declare admin_ip
declare user_ip


function print_message(){
  whiptail --title "$1" --backtitle "$BACKTITLE" --msgbox "$2" "$HEIGHT" "$WIDTH"
}


function user_exists(){
  if id "$1" 1>/dev/null 2>/dev/null
  then
    true
  else
    false
  fi
}


function set_user_groups(){
  sudo usermod -aG lpadmin "$user"
}


function create_user(){
  local title="Creación del usuario"

  if user_exists "$user"
  then
    return 0
  fi

  while true
  do
    user=$(
      whiptail \
        --title "$title" \
        --backtitle "$BACKTITLE" \
        --inputbox "Ingresar usuario" "$HEIGHT" "$WIDTH" \
        3>&1 1>&2 2>&3)

    passwd=$(whiptail \
      --title "$title" \
      --backtitle "$BACKTITLE" \
      --inputbox "Ingresar contraseña" "$HEIGHT" "$WIDTH" \
      3>&1 1>&2 2>&3)

    if user_exists "$user"
    then
      print_message "$title" "El usuario ya existe"
      break
    fi

    if whiptail \
      --title "$title" \
      --backtitle "$BACKTITLE" \
      --yesno "Usuario: $user\nContraseña: $passwd\n\nConfirmar?" \
      "$HEIGHT" "$WIDTH"
    then
      if ! sudo useradd -m "$user"
      then
        print_message "$title" "Ocurrió un error al crear el usuario"
        break
      fi

      if ! echo "$user:$passwd" | sudo chpasswd
      then
        print_message "$title" "Ocurrió un error al intentar setear la contraseña del usuario"
        break
      fi
        print_message "$title" "El usuario fue creado con éxito"
        set_user_groups
      break
    fi
  done
}


function network_exists(){
	if [[ -f "/etc/NetworkManager/system-connections/${1}.nmconnection" ]]
	then
    true
  else
    false
	fi
}


function reset_fds(){
  exec 0</dev/tty
  exec 1>/dev/tty
  exec 2>/dev/tty
}

function set_proxy(){
  proxy=$1
	gsettings set org.gnome.system.proxy mode manual
	gsettings set org.gnome.system.proxy.http port "$PROXY_PORT"
	gsettings set org.gnome.system.proxy.https port "$PROXY_PORT"
	gsettings set org.gnome.system.proxy.ftp port "$PROXY_PORT"
	gsettings set org.gnome.system.proxy.http host "$proxy"
	gsettings set org.gnome.system.proxy.https host "$proxy"
	gsettings set org.gnome.system.proxy.ftp host "$proxy"

  echo "
export http_proxy=http://${proxy}:${PROXY_PORT}
export https_proxy=http://${proxy}:${PROXY_PORT}
export ftp_proxy=http://${proxy}:${PROXY_PORT}
export NO_PROXY=santafe.gob.ar,santafe.gov.ar,sfnet,dpi.sfnet,10.0.0.0/8
export no_proxy=santafe.gob.ar,santafe.gov.ar,sfnet,dpi.sfnet,10.0.0.0/8
" | sudo tee /etc/environment 1>/dev/null
}


function add_chrome_key(){
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
}


function add_anydesk_key(){
  wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo apt-key add -
  echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
}


function add_external_packages(){
  add_chrome_key
  add_anydesk_key
  add_adobe_key
}


function check_connectivity(){
  if [[ $(nmcli networking connectivity check) == "full" ]]
  then
    true
  else
    false
  fi
}


function create_network_connection(){
  local network=$1
  local ip=$2
  local mask=$3
  local gateway=$4
  local dns=$5
  local device=$6
  local set_up=$7

  if network_exists "$network"
  then
    delete_network "$network"
  fi

  nmcli connection add type ethernet \
    ifname "$device" \
    con-name "$network" \
    ip4 "$ip/$mask" \
    gw4 "$gateway" \
    ipv4.dns "$dns" 1>/dev/null 2>/dev/null

  if [[ $set_up == true ]]
  then
    nmcli connection up "$network"
  fi
}


function set_admin_network(){
  local title="Configurar red para la instalación"

  while true;
  do
  admin_ip=$(
    whiptail \
    --title "$title" \
    --backtitle "$BACKTITLE" \
    --inputbox "Ingresar IP con acceso al 10.7.6.6" "$HEIGHT" "$WIDTH" \
    3>&2 2>&1 1>&3
  )

  device=$(
    whiptail \
    --title "$title" \
    --backtitle "$BACKTITLE" \
    --inputbox "Ingresar el dispositivo de red\n$(nmcli device | grep ethernet)" "$HEIGHT" "$WIDTH" \
    3>&2 2>&1 1>&3
  )

  if whiptail \
    --title "$title" \
    --backtitle "$BACKTITLE" \
    --yesno """
        IP: $admin_ip
        Disposito: $device
        Confirmar?""" "$HEIGHT" "$WIDTH"
      then
    break
  fi
  done

  create_network_connection "$ADMIN_NETWORK_NAME" "$admin_ip" "23" "10.7.6.200" "$DNS" "$device" true
}


function set_user_network() {
  local title="Configurar red del usuario"

  while true
  do
    network=$(whiptail \
      --title "$title" \
      --radiolist "Seleccionar la red a donde va a estar la pc" "$HEIGHT" "$WIDTH" 6 \
      "1" "Ministerio - 10.7.6.0/23" OFF \
      "2" "Secretaría de Ciencia y Tecnología / Secretaría de Transporte: 10.8.50.0/23" OFF \
      "3" "Secretaría de Turismo - 10.10.14.0/24" OFF \
      "4" "Terminal de Santa Fe - 10.7.48.0/24" OFF \
      "5" "Enerfe Puerto Santa Fe - 10.10.20.0/24" OFF \
      "6" "Aeropuerto de Sauce Viejo - 10.8.44.0/24" OFF \
      2>&1 > /dev/tty
    )
  declare gateway;
  declare network_mask;
  case "$network" in
    1) 
      network="Ministerio"
      gateway="10.7.6.200"
      network_mask="23";;
    2)
      network="Sec. de Ciencia y Tecnología / Sec. de Transporte"
      gateway="10.8.50.200"
      network_mask="23";;
    3)
      network="Secretaría de Turismo"
      gateway="10.10.14.200"
      network_mask="24";;
    4)
      network="Terminal de Santa Fe"
      gateway="10.7.48.200"
      network_mask="24";;
    5)
      network="Enerfe Puerto de Santa Fe"
      gateway="10.10.20.200"
      network_mask="24";;
    6)
      network="Aeropuerto de Sauce Viejo"
      gateway="10.8.44.200"
      network_mask="24";;
  esac

  user_ip=$(
    whiptail \
    --title "$title" \
    --backtitle "$BACKTITLE" \
    --inputbox "Ingresar IP" "$HEIGHT" "$WIDTH" \
    3>&2 2>&1 1>&3
  )

  device=$(
    whiptail \
    --title "$title" \
    --backtitle "$BACKTITLE" \
    --inputbox "Ingresar el dispositivo de red\n$(nmcli device | grep ethernet)" "$HEIGHT" "$WIDTH" \
    3>&2 2>&1 1>&3
  )

  if whiptail \
    --title "$title" \
    --backtitle "$BACKTITLE" \
    --yesno """
        Red: $network
        Gateway: $gateway
        Mascara de subred: $network_mask
        IP final del usuario: $user_ip
        Disposito: $device
        Confirmar?""" "$HEIGHT" "$WIDTH"
      then
    break
  fi
  done

  create_network_connection "$NETWORK_NAME" "$user_ip" "$network_mask" "$gateway" "$DNS" "$device" true
  delete_network "$ADMIN_NETWORK_NAME"
  return 0
}


function configure_samba(){
	if [[ ! -d $SCAN_DIR ]]
	then
		sudo mkdir $SCAN_DIR
		sudo chown usuario:usuario $SCAN_DIR
		sudo chmod 777 $SCAN_DIR
		echo "[scan]
		path = $SCAN_DIR
		force user = usuario
		public = yes
		writable = yes
		browseable = yes
		read only = no
		force directory mode = 0777
		force create mode = 0777" | sudo tee -a /etc/samba/smb.conf > /dev/null
	fi

	if [[ ! -d $SHARE_DIR ]]
	then
		sudo mkdir $SHARE_DIR
		sudo chown usuario:usuario $SHARE_DIR
		sudo chmod 777 $SHARE_DIR
		echo "[compartida]
		path = $SHARE_DIR public = yes
		writable = yes
		browseable = yes
		read only = no
		force directory mode = 0777
		force create mode = 0777" | sudo tee -a /etc/samba/smb.conf > /dev/null
	fi

	sudo systemctl reload-or-restart smbd
}


function configure_vnc(){
  echo "[Unit]
Description=x11vnc service
After=display-manager.service network.target syslog.target
[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -forever -display :0 -auth guess -passwd 3e2w1q
ExecStop=/usr/bin/killall x11vnc
Restart=on-failure
[Install]
WantedBy=multi-user.target " | sudo tee /etc/systemd/system/x11vnc.service > /dev/null
	sudo systemctl enable --now x11vnc
}


function configure_cups(){
  sudo systemctl enable cups
  sudo systemctl start cups
  sudo systemctl enable cups-browsed
  sudo systemctl start cups-browsed
}


function configure_services(){
  configure_cups
  configure_vnc
  configure_samba
}


function delete_network(){
  nmcli connection delete "$1"
  return 0
}


function install_chrome(){
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb
  if sudo dpkg -i chrome.deb
  then
    sudo rm chrome.deb
    return 0            # 0 expresses no error
  else
    return 1            # non-zero means an error occured
  fi
}


function install_packages(){
  local title="Instalación de paquetes"

  reset_fds
  add_external_packages

	if ! sudo apt update
  then
    print_message "$title" "Error: Ocurrió un problema al intentar actualizar el repositorio"
    #exit 1
  fi

  uninstalled_packages=()
  for package in "${PACKAGES[@]}"
  do
    sudo apt-get install -y "$package"
    output=$?
    echo "Codigo de salida: $output"
    if [[ "$output" != 0 ]]
    then
      uninstalled_packages+=("$package")
    fi
  done

  if ! install_chrome
  then
    uninstalled_packages+=("google-chrome")
  fi

  if ! install_anydesk
  then
    uninstalled_packages+=("anydesk")
  fi
	
  if [[ ${#uninstalled_packages[@]} -gt 1 ]]
  then
    print_message "$title" "Los siguientes paquetes no pudieron ser instalados: ${uninstalled_packages[*]}"
  fi

  create_shortcuts
  configure_services
}



function finish_installation(){
  local title="Finalizar instalación"
  set_proxy "$SCAI_PROXY" "$PROXY_PORT"
  set_user_network_up
	sudo cp ~/.config/dconf/user /home/"$user"/.config/dconf/user

  if whiptail \
    --title "$title" \
    --backtitle "$BACKTITLE" \
    --yesno "Es necesario reiniciar el sistema para terminar la instalación.\nFinalizar y reiniciar?" "$HEIGHT" "$WIDTH"
  then
    sudo systemctl reboot
  fi
}


function main(){
  set_admin_network               # para la instalacion de paquetes
  set_proxy "$INSTALL_PROXY"      # seteo del proxy
  create_user                     # creacion del usuario
  install_packages                # instalacion de los paquetes
  set_user_network                # ip final para el usuario, si la hay
  set_proxy "$SCAI_PROXY"         # seteo del proxy final
  finish_installation             # finalizacion de la instalacion
}

main