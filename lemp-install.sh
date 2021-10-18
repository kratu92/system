#!/bin/bash

# Initial config
. ./inc/init-script.sh


printf "${BLUE} ╔═══════════════════════════════════════════════╗${NC}\n"
printf "${BLUE} ║ -> KRATU'S LEMP SERVER INSTALLATION SCRIPT <- ║${NC}\n"
printf "${BLUE} ╚═══════════════════════════════════════════════╝${NC}\n"

# Ask for confirmation
. ./inc/ask-for-confirmation.sh

# Previous checks
. ./inc/previous-checks.sh

# Update and upgrade
printf "${GREEN}Updating and upgrading${NC}\n"
sudo apt update -y
sudo apt upgrade -y

printf "${BLUE}------> 1- NGINX Installation${NC}\n"

# Install required packages
printf "${GREEN}Installing required packages${NC}\n"
sudo apt install \
        curl \
        gnupg2 \
        ca-certificates \
        lsb-release \
        debian-archive-keyring \
        -y

# Import official nginx signing key to let apt verify packages authenticity
printf "${GREEN}Importing official nginx signing key${NC}\n"

keyringFile="/usr/share/keyrings/nginx-archive-keyring.gpg"

curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
	| sudo tee $keyringFile >/dev/null

# Verify that the downloaded file contains the proper key
result=`gpg --dry-run --quiet --import --import-options import-show $keyringFile`

fingerprint=`[[ \
		"$(curl https://nginx.org/en/linux_packages.html)" \
		=~ (Debian.* ([0-9A-F]{40})) \
	]] && echo "${BASH_REMATCH[2]}"`

if [[ "$result" != *"$fingerprint"* ]]; then
	printf "${RED}Fingerprint does not match${NC}\n"
	sudo rm -f $keyringFile
	exit 1
else
	printf "${GREEN}Fingerprint matches${NC}\n"
fi

# Setup apt repository for mainline nginx packages
printf "${GREEN}Setting up apt repository for stable nginx packages${NC}\n"
echo "deb [signed-by=$keyringFile] \
	http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" \
	| sudo tee /etc/apt/sources.list.d/nginx.list

# Setup repository pinning to prefer nginx's packages over distribution-provider ones
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
	| sudo tee /etc/apt/preferences.d/99nginx

printf "${GREEN}Updating${NC}\n"
sudo apt update

printf "${GREEN}Installing nginx${NC}\n"
sudo apt install nginx -y

printf "${GREEN}NGINX installed. Starting server${NC}\n"
sudo systemctl start nginx


