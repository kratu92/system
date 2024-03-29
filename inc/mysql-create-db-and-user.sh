#!/bin/bash

############################################
# mySQL Create Database and User
############################################
mySQLCreateDbAndUser() {

	title "KRATU'S MYSQL DB AND USER CREATE SCRIPT"

	# Ask for confirmation
	if ! confirm; then return 1; fi # return false

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
		pass=""
	else
		if [ "$#" -ne 3 ]; then 
			printf "${RED}Error: Invalid number of arguments supplied${NC}\n"
			printf "${YELLOW}Number of arguments allowed: 0 or 3 (db, user, password)${NC}\n"
			exit 1
		fi

		db=$1
		user=$2
		pass=$3
	fi

	# Ask for a DB name
	until [ "${db}" != "" ]
	do
        	read -p "Set a name for the new database: " db
	        db="$(echo -e "${db,,}" | sed -e 's/^[[:space:]]*//')";
	done

	# Ask for a username
	until [ "${user}" != "" ]
	do
        	read -p "Set a username: " user
	        user="$(echo -e "${user,,}" | sed -e 's/^[[:space:]]*//')";
	done

	# Ask for password
	until [ "${pass}" != "" ]
	do
        	read -s -p "Set a password for the user ${user}: " pass
	        pass="$(echo -e "${pass,,}" | sed -e 's/^[[:space:]]*//')";
		echo "" # New line

		if [ "${pass}" != "" ]
			then read -s -p "Retype the password for user ${user}: " passConfirm
			passConfirm="$(echo -e "${passConfirm,,}" | sed -e 's/^[[:space:]]*//')";
			echo "" # New line 

			if [ "${pass}" != "${passConfirm}" ]
				then printf "${RED}Password does not match. Try setting the password again.${NC}\n"
				pass=""
			fi
		fi
	done

	# Confirm selected data
	echo "The new database will be created with the following data:"
	printf "${WHITE}- database name: ${PURPLE}${db}${NC}\n"
	printf "${WHITE}- username: ${PURPLE}${user}${NC}\n"

	if ! confirm; then return 1; fi # return false

	query1="CREATE DATABASE IF NOT EXISTS \`${db}\`;"
	query2="CREATE USER IF NOT EXISTS '${user}'@'%' IDENTIFIED BY '${pass}';"
	query3="GRANT ALL PRIVILEGES ON \`${db}\`.* TO '${user}'@'%';"
	query4="FLUSH PRIVILEGES;"
	query5="SELECT COUNT(DISTINCT(user)) AS 'Current users' FROM mysql.db;"
        query6="SELECT db, user, host FROM mysql.db; SHOW DATABASES;"

	sql="${query1} ${query2} ${query3} ${query4} ${query5} ${query6}"

	printf "${GREEN}You will be asked to introduce MySQL's root password${NC}\n"
	`command -v mysql` -u root -p -e "${sql}"

	printf "${GREEN}MySQL user [${PURPLE}${user}${GREEN}] and database [${PURPLE}${db}${GREEN}] where created${NC}\n"
}
