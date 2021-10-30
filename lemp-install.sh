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

# ---------------- > NGINX
printf "${BLUE}------> 1.- NGINX Installation${NC}\n"

# Install required packages
printf "${GREEN}Installing required packages${NC}\n"
sudo apt install \
        curl \
        gnupg2 \
        ca-certificates \
        lsb-release \
        debian-archive-keyring \
        -y
# lsb_releases & ca-certificates also needed for PHP

# Import official nginx signing key to let apt verify packages authenticity
printf "${GREEN}Importing official nginx signing key${NC}\n"

keyringFile="/usr/share/keyrings/nginx-archive-keyring.gpg"

curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
	| sudo tee $keyringFile >/dev/null

# Verify that the downloaded file contains the proper key
result=`gpg --dry-run --quiet --import --import-options import-show $keyringFile`

fingerprint=`[[ "$(curl https://nginx.org/en/linux_packages.html)" \
		=~ (Debian.* ([0-9A-F]{40}))  ]] \
	&& echo "${BASH_REMATCH[2]}"`

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

# Update
printf "${GREEN}Updating${NC}\n"
sudo apt update

# Install nginx
printf "${GREEN}Installing nginx${NC}\n"
sudo apt install nginx -y

# Start server
printf "${GREEN}NGINX installed. Starting server${NC}\n"
sudo systemctl start nginx

# Setup nginx
printf "${GREEN}Seting up nginx...${NC}\n"
nginxConfFile="/etc/nginx/nginx.conf";
if [[ -f "${nginxConfFile}" ]]; then
        mv "${nginxConfFile}" "${nginxConfFile}.bak"
fi

cp ./nginx/nginx.conf "$nginxConfFile"
nginxDefaultDir="/usr/share/nginx/html/"
cp ./nginx/default.conf "/etc/nginx/conf.d/default.conf"

cp ./templates/403.html   "${nginxDefaultDir}404.html"
cp ./templates/404.html   "${nginxDefaultDir}404.html"
cp ./templates/50x.html   "${nginxDefaultDir}50x.html"
cp ./templates/index.html "${nginxDefaultDir}index.html"

sudo systemctl restart nginx

# ---------------- > MARIA DB
printf "${BLUE}------> 2.- MariaDB Installation${NC}\n"

# Install required packages
printf "${GREEN}Installing required packages${NC}\n"
sudo apt install mariadb-server -y

# Configure MariaDB
printf "${GREEN}Configuring MariaDB${NC}\n"
sudo mysql_secure_installation

printf "${GREEN}MariaDB was installed and configured${NC}\n"

# ---------------- > PHP-FPM
printf "${BLUE}------> 3.- PHP-FPM Installation${NC}\n"

# Install required packages
printf "${GREEN}Installing required packages${NC}\n"
sudo apt install \
	wget \
	apt-transport-https \
	-y

printf "${GREEN}Downloading Sury PPA for PHP 8 package${NC}\n"
# Repository key
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

# Add APT repository
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | \
	sudo tee /etc/apt/sources.list.d/php.list

# Update
printf "${GREEN}Updating${NC}\n"
sudo apt update

# Install PHP
printf "${GREEN}Installing PHP-FPM${NC}\n"
sudo apt install php8.0-fpm -y

php -v

printf "${GREEN}Installing extensions${NC}\n"
sudo apt install php8.0-{bcmath,cli,curl,gd,intl,mbstring,mysql,soap,xml,zip} -y

printf "${RED}TO DO: Setup php...${NC}\n"
printf "${GREEN}PHP-FPM was installed and configured${NC}\n"

printf "${BLUE}------> Restarting servers${NC}\n"
systemctl restart nginx
systemctl restart php8.0-fpm
systemctl restart mysql

printf "${GREEN}LEMP server installation is complete${NC}\n"
