#!/bin/bash

############################################################
# Docker Install Script  
# 
# run as sudo 
############################################################
# ref: https://gist.github.com/shawnsavour/2722086405f7670471908294eed84e76#file-debian-docker-sh
# determine if we run as sudo
# os check Get distro name from /etc/os-release
# grep '^NAME=' /etc/os-release | sed s'/NAME=//'
distro=$(grep '^NAME=' /etc/os-release | sed s'/NAME=//' | sed s'/\"//g' | awk '{print $1}')
osversion=$(grep '^VERSION_ID=' /etc/os-release | sed s'/VERSION_ID=//' | sed s'/\"//g')
# distro to lowercase
distro=$(echo $distro | tr '[:upper:]' '[:lower:]')

userid="${SUDO_USER:-$USER}"
if [ "$userid" == 'root' ]
  then 
    echo "Please run the setup as sudo and not as root!"
    exit 1
fi
if [ "$EUID" -ne 0 ]
  then 
    echo "Please run setup as sudo!"
    exit 1
fi

echo "#############################################"
echo " adding core libraries..."
echo "#############################################"

apt update
apt install -y ne apt-transport-https ca-certificates curl gnupg lsb-release nftables ntp lvm2 ufw

echo "#############################################"
echo " installing docker...."
echo "#############################################"
# Add docker repository
# depend on distro
curl -fsSL https://download.docker.com/linux/$distro/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$distro \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
# install docker...
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose
