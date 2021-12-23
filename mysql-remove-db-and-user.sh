#!/bin/bash

# Initial config
. ./inc/init-script.sh

################################################
# MySQL Remove Database and User
################################################
mySQLRemoveDbAndUser() {

	printf "${BLUE} ╔═══════════════════════════════════════════════╗${NC}\n"
	printf "${BLUE} ║ -> KRATU'S MYSQL DB AND USER REMOVE SCRIPT <- ║${NC}\n"
	printf "${BLUE} ╚═══════════════════════════════════════════════╝${NC}\n"

	# Ask for confirmation
	confirm -e

	# Previous checks
	previousChecks -rv

	# Make sure mysql is installed
	! test -x /usr/sbin/mysqld \
        	&& printf "${RED}Error: nginx is not installed${NC}\n" \
	        && exit 1

	# Check arguments
	if [ -z "$1" ]; then
        	db=""
	        user=""
	else
        	if [ "$#" -ne 2 ]; then 
                	printf "${RED}Error: Invalid number of arguments supplied${NC}\n"
	                printf "${YELLOW}Number of arguments allowed: 0 or 2 (db, user)${NC}\n"
        	        exit 1
	        fi

        	db=$1
	        user=$2
	fi

	# Ask for a DB name
	until [ "${db}" != "" ]
	do
        	read -p "Name of the database to delete: " db
	        db="$(echo -e "${db,,}" | sed -e 's/^[[:space:]]*//')";
	done

	# Ask for a username
	until [ "${user}" != "" ]
	do
        	read -p "User to delete: " user
	        user="$(echo -e "${user,,}" | sed -e 's/^[[:space:]]*//')";
	done

	# Confirm selected data
	echo "The following database and user will be removed:"
	printf "${WHITE}- database name: ${PURPLE}${db}${NC}\n"
	printf "${WHITE}- username: ${PURPLE}${user}${NC}\n"

	confirm -e

	query1="DROP DATABASE IF EXISTS \`${db}\`;"
	query2="DROP USER '${user}'@'%';"
	query3="FLUSH PRIVILEGES;"
	query4="SELECT COUNT(DISTINCT(user)) AS 'Current users' FROM mysql.db;"
	query5="SELECT db, user, host FROM mysql.db; SHOW DATABASES;"

	sql="${query1} ${query2} ${query3} ${query4} ${query5}"

	printf "${GREEN}You will be asked to introduce MySQL's root password${NC}\n"
	`command -v mysql` -u root -p -e "${sql}"

	printf "${GREEN}MySQL user [${PURPLE}${user}${GREEN}] and database [${PURPLE}${db}${GREEN}] where removed${NC}\n"
}

mySQLRemoveDbAndUser
