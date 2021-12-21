#!/bin/bash

# Initial config
. ./inc/init-script.sh

PHP_VERSION="8.0"

printf "${BLUE} ╔═══════════════════════════════════════════════╗${NC}\n"
printf "${BLUE} ║  -> KRATU'S NGINX NEW VIRTUAL HOST SCRIPT <-  ║${NC}\n"
printf "${BLUE} ╚═══════════════════════════════════════════════╝${NC}\n"

# Ask for confirmation
confirm -e

# Previous checks
previousChecks -rpv

# Make sure nginx is installed
! test -x /usr/sbin/nginx \
	&& printf "${RED}Error: nginx is not installed${NC}\n" \
	&& exit 1

username=""
until [ "${username}" != "" ]
do
        read -p "Set a username: " username
        username="$(echo -e "${username,,}" | sed -e 's/^[[:space:]]*//')";
done

domain=""
until [ "${domain}" != "" ]
do
        read -p "Set a domain (without http or www) [eg. coaru.com]: " domain
        domain="$(echo -e "${domain,,}" | sed -e 's/^[[:space:]]*//')";
done

# Confirm selected data
echo "Chosen username: ${username}"
echo "Chosen domain: ${domain}"
confirm -e

sudo adduser $username

userDir="/home/${username}/"
userPublicDir="${userDir}public"

if [[ ! -d "${userPublicDir}" ]]
	then echo "Creating user's public dir"
	mkdir -p -v $userPublicDir
fi

echo "User's public dir is created"

# Add default index file
\cp ./templates/index.php $userPublicDir

# Add nginx to user's group
printf "${GREEN}Adding nginx to user's group${NC}\n"
sudo usermod -a -G $username nginx

# All files should be owned by the website user
printf "${GREEN}Setting user files owner${NC}\n"
chown -R $username:$username $userDir

# File permissions: 750 dirs 640 files
# website user  [ read files, write files, read dirs ]
# website group [ read files, traverse dirs, not write ]
# Other users   [ none ]
printf "${GREEN}Setting permissions${NC}\n"
chmod -R u=rwX,g=rX,o= $userDir

# We will use it in case we need to backup any config files
timestamp="$(date +%Y%m%d_%H%M%S)"

# Nginx config file
nginxConfFile="/etc/nginx/conf.d/${username}.conf"

# If already exists make a backup so we don't overwrite it
if [[ -f $nginxConfFile ]]
	then backupFile="${nginxConfFile}.${timestamp}.bak"
	printf "${YELLOW}Nginx config file '${nginxConfFile}' already exists.${NC}\n"
	printf "${YELLOW}Backing up to ${backupFile}${NC}\n"
	\mv -v $nginxConfFile $backupFile
fi

# Create new nginx config file
printf "${GREEN}Creating new nginx server block config file${NC}\n"
\cp -v ./nginx/serverBlockTemplate.conf      $nginxConfFile
sed -i "s|SERVER_BLOCK_USERNAME|$username|g" $nginxConfFile
sed -i "s|SERVER_BLOCK_DOMAIN|$domain|g"     $nginxConfFile

# PHP-FPM config file
phpConfFile="/etc/php/${PHP_VERSION}/fpm/pool.d/${username}.conf"

# If already exists make a backup so we don't overwrite it
if [[ -f $phpConfFile ]]
        then backupFile="${phpConfFile}.${timestamp}.bak"
        printf "${YELLOW}PHP-FPM config file '${phpConfFile}' already exists.${NC}\n"
        printf "${YELLOW}Backing up to ${backupFile}${NC}\n"
        \mv -v $phpConfFile $backupFile
fi

# Create new PHP-FPM file
printf "${GREEN}Creating new PHP-FPM pool config file${NC}\n"
\cp -v ./php/poolTemplate.conf $phpConfFile
sed -i "s|SERVER_BLOCK_USERNAME|$username|g" $phpConfFile

printf "${GREEN}Restarting servers${NC}\n"
sudo systemctl restart nginx
sudo systemctl restart "php${PHP_VERSION}-fpm"

printf "${GREEN}New server block (virtual host) is ready!${NC}\n"
