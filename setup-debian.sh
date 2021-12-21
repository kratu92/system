#!/bin/bash

# Initial config
. ./inc/init-script.sh

printf "${BLUE}         ╔══════════════════════════════════════════╗${NC}\n"
printf "${BLUE}         ║ -> KRATU'S DEBIAN SYSTEM SETUP SCRIPT <- ║${NC}\n"
printf "${BLUE}         ╚══════════════════════════════════════════╝${NC}\n"
printf "${PURPLE}┌────────────────────────────────────────────────────────────┐${NC}\n"
printf "${PURPLE}│${NC}                    ${YELLOW}BEWARE YOUNG PADAWAN${NC}                    ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC}     ${YELLOW}You are about to modify your server configuration.${NC}     ${PURPLE}│${NC}\n"
printf "${PURPLE}├────────────────────────────────────────────────────────────┤${NC}\n"
printf "${PURPLE}│${NC} This script will do the following:                         ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC}     ${BLUE}■${NC} Install required packages                            ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC}     ${BLUE}■${NC} Set up automatic updates                             ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC}     ${BLUE}■${NC} Create a new sudo user                               ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC}       ${BLUE}└─${NC} This will be the only user with ssh access        ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC}          to the server                                     ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC}     ${BLUE}■${NC} SSH                                                  ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC}       ${BLUE}├─${NC} The new ssh port will be reset to port 6116       ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC}       ${BLUE}├─${NC} kratu.pub will be added to the authorized_keys    ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC}       ${BLUE}├─${NC} Password authentication will be disabled          ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC}       ${BLUE}└─${NC} Root login will be disabled                       ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC}     ${BLUE}■${NC} System will be rebooted                              ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC}                                                            ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC} ${RED}- You will only be able to login via SSH with the newly${NC}    ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC} ${RED}  created user, with the kratu.pem keypair.${NC}                ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC} ${RED}- Login with password will be disabled.${NC}                    ${PURPLE}│${NC}\n"
printf "${PURPLE}│${NC} ${RED}- SSH root login will be disabled.${NC}                         ${PURPLE}│${NC}\n"
printf "${PURPLE}├────────────────────────────────────────────────────────────┤${NC}\n"
printf "${PURPLE}│${NC}          ${GREEN}Try not. Do or do not. There is no try.${NC}           ${PURPLE}│${NC}\n"
printf "${PURPLE}└────────────────────────────────────────────────────────────┘${NC}\n"

# Ask for confirmation
. ./inc/ask-for-confirmation.sh

# Previous checks
previousChecks -rpv

# Update and upgrade
printf "${GREEN}Updating and upgrading${NC}\n"
sudo apt update -y
sudo apt upgrade -y

# Install required packages
printf "${GREEN}Installing required packages${NC}\n"
sudo apt install \
	openssh-server \
	net-tools \
	git \
	ufw \
	unattended-upgrades \
	-y

# Auto updates
printf "${GREEN}Setting up auto updates${NC}\n"
echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
sudo dpkg-reconfigure -f noninteractive unattended-upgrades

# Create new user
printf "${GREEN}A new sudo user will be created${NC}\n"
username=""
until [ "$username" != "" ]
do
        read -p "Choose a new username: " username
        username="$(echo -e "${username,,}" | sed -e 's/^[[:space:]]*//')";
done
sudo adduser $username # will prompt for a password
sudo usermod -aG sudo $username # Add to sudoers
echo "The new user $username was created and added to the sudo group"

# Create .ssh dir for the new user
userDir="/home/$username"
userSSHDir="$userDir/.ssh"
if [ ! -d "$userSSHDir" ]
        then  echo "$userSSHDir directory does not exist"
        mkdir -p -v $userSSHDir
fi

# Add public key
kratuPubKey="$(cat ./kratu.pub)"
sed -i '/^'"${kratuPubKey}"'/d' "$userSSHDir/authorized_keys"
cat ./kratu.pub >> "$userSSHDir/authorized_keys"

# Permissions
chown -v -R $username:$username $userSSHDir
chmod -v -R 700 $userSSHDir

# Alias
printf "${GREEN}Setting up alias for new user${NC}\n"
aliasLine="if [ -f ~/.kratu_aliases ]; then . ~/.kratu_aliases; fi; # Do not modify"
sed -i "/kratu_aliases/d" $userDir/.bashrc  # Remove previously added lines
echo "$aliasLine" >> $userDir/.bashrc
cp ./.kratu_aliases $userDir/.kratu_aliases # Create alias file

# Setting up ssh
printf "${GREEN}Setting up ssh${NC}\n"
configFile="/etc/ssh/sshd_config"

paramsToRemove=( "Port" "AddressFamily" "PermitRootLogin" "PasswordAuthentication")
for param in ${paramsToRemove[@]}; do # Remove previous config
  sed -i '/^'"${param}"'/d' $configFile
done

SSHPort=6116
echo "Port $SSHPort" >> $configFile # Change defarult 22 por for a new one
echo "AddressFamily inet" >> $configFile #IPV4 only
echo "PermitRootLogin no" >> $configFile
echo "PasswordAuthentication no" >> $configFile

sudo systemctl restart sshd

# Setup firewall
printf "${GREEN}Setting up firewall${NC}\n"
sudo ufw --force reset
sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw # Disable IPV6
sudo ufw limit $SSHPort/tcp # Allow SSH max 6 attempts in 30 secs
sudo ufw allow 80/tcp # Allow Web
sudo ufw allow 443/tcp # Allow Web SSL
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw --force enable

# if [ "$(ip a | grep inet6)" ]
#	then printf "${GREEN}IPv6 is enabled. Disabling IPv6..."
#	# Disable IPv6 ?? idk
# fi

# Message of the day (Shown on SSH login)
[ -f /etc/motd ] && mv /etc/motd /etc/motd_OLD # backup old
echo "By Kratu © - coaru.com" > /etc/motd

# Set timezone
printf "${GREEN}Setting up timezone${NC}\n"
timedatectl set-timezone Europe/Madrid

# Set hostname
oldHostname="$(hostname)"
printf "${GREEN}Setting new hostname${NC}\n"
echo "Current hostname: $oldHostname"
hostname=""
until [ "$hostname" != "" ]
do
        read -p "Set a new hostname: " hostname
        hostname="$(echo -e "${hostname}" | sed -e 's/^[[:space:]]*//')";
done
sudo sed -i 's/'"${oldHostname}"'/'"${hostname}"'/g' /etc/hosts
sudo hostnamectl set-hostname $hostname

# Alias
printf "${GREEN}Setting up alias${NC}\n"
aliasLine="if [ -f ~/.kratu_aliases ]; then . ~/.kratu_aliases; fi; # Do not modify this line"
sed -i "/kratu_aliases/d" ~/.bashrc  # Remove previously added lines
echo "$aliasLine" >> ~/.bashrc
cp ./.kratu_aliases ~/.kratu_aliases # Create alias file

printf "${GREEN}Configuration has finished${NC}\n"
printf "${GREEN}Rebooting...${NC}\n"
sudo reboot

