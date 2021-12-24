#!/bin/bash

# MAIN SCRIPT

. ./inc/init-script.sh

. ./inc/setup-debian.sh
. ./inc/lemp-install.sh
. ./inc/nginx-add-virtual-host.sh
. ./inc/mysql-create-db-and-user.sh
. ./inc/mysql-remove-db-and-user.sh

#############################################
# MAIN MENU
# Shows a list of scripts to the user
# The user will be able to choose which
# script to execute.
#############################################
mainMenu() {

	title "KRATU'S SYSTEM SCRIPTS"

	printf "${BLUE} ┌────────────────────────────────────────────────────────────┐${NC}\n"
	printf "${BLUE} │${NC} ${YELLOW}--> CHOOSE YOUR OPTION${NC}                                     ${BLUE}│${NC}\n"
	printf "${BLUE} ├────────────────────────────────────────────────────────────┤${NC}\n"
	printf "${BLUE} │${NC}     ${PURPLE}■${NC} 1. Setup debian                                      ${BLUE}│${NC}\n"
	printf "${BLUE} │${NC}     ${PURPLE}■${NC} 2. LEMP Install                                      ${BLUE}│${NC}\n"
	printf "${BLUE} │${NC}     ${PURPLE}■${NC} 3. NGINX Add Virtual Host                            ${BLUE}│${NC}\n"
	printf "${BLUE} │${NC}     ${PURPLE}■${NC} 4. MySQL Create Database and User                    ${BLUE}│${NC}\n"
	printf "${BLUE} │${NC}     ${PURPLE}■${NC} 5. MySQL Remove Database and User                    ${BLUE}│${NC}\n"
	printf "${BLUE} │${NC}     ${PURPLE}■${NC} 6. Wordpress install                                 ${BLUE}│${NC}\n"
	printf "${BLUE} │${NC}                                                            ${BLUE}│${NC}\n"
	printf "${BLUE} │${NC}     ${PURPLE}■${NC} 0. Exit                                              ${BLUE}│${NC}\n"
	printf "${BLUE} └────────────────────────────────────────────────────────────┘${NC}\n"

	scriptNumber=""
	until [ "${scriptNumber}" != "" ]
	do
        	read -p "Script number: " scriptNumber
		if ! [[ "${scriptNumber}" =~ ^[0-9]+$ ]]; then
			printf "${RED}Invalid option. Only integers allowed.\nTry again.${NC}\n"
	        	scriptNumber=""
		fi
	done

	case $((scriptNumber)) in

		1) # Debian setup
			setupDebian ;;

		2) # LEMP Install
			lempInstall ;;

		3) # NGINX Add Virtual Host
			nginxAddVirtualHost ;;

		4) # MySQL Create Database and User
			mySQLCreateDbAndUser ;;

		5) # MySQL Remove Database and User
			mySQLRemoveDbAndUser ;;

		6) # Wordpress Install
			wordpressInstall ;;

		0) # Exit
			printf "${GREEN}Goodbye (: ${NC}\n"
			exit ;;

		*) # Invalid option
			printf "${RED}Invalid option${NC}\n" ;;
	esac

	confirm -e -t "Do you want to run another script?"
	mainMenu
}


mainMenu
