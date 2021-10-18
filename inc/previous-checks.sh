#!/bin/bash

# Script must be run by root
if [ "$EUID" -ne 0 ]
        then printf "${RED}ERROR: You must be root to run this script${NC}\n"
        exit 1
# No parameters allowed
elif [ $# != 0 ]
        then printf "${RED}ERROR: This script does not accept any parameters${NC}\n"
        exit 1
#Check version file
elif [ -f /etc/debian_version==false ] 
        then printf "${RED}ERROR: Debian version file not found${NC}\n"
        exit 1
fi

# Make sure it is a tested version
debianVersion=$(echo "$(cat /etc/debian_version)" | sed 's/\.[0-9]*//g')
printf "${GREEN}Current Debian version: $debianVersion${NC}\n"

if [[ debianVersion -lt MIN_VERSION ]] || [[ debianVersion -ge MAX_VERSION ]]
        then printf "${RED}ERROR: Current debian version has not been tested${NC}\n"
        exit 1
fi

