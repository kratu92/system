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

# Install required packages
sudo apt install \
        curl \
        gnupg2 \
        ca-certificates \
        lsb-release \
        debian-archive-keyring \
        -y
