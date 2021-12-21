#/bin/bash

#Config
MIN_VERSION="11" # No decimals (Included)
MAX_VERSION="12" # No decimals (Not included)

# Colors
BLUE="\033[0;36m"
GREEN="\033[0;32m"
RED="\033[1;31m"
PURPLE="\033[0;35m"
YELLOW="\033[0;33m"
NC="\033[0m"

##########################################################
# PREVIOUS CHECKS FUNCTION
# Previous checks before running the script
# Exits if one of the checks fails
# FLAGS:
# 	-r: User must be root
# 	-p: Script without params allowed
# 	-v: Check debian version
##########################################################
previousChecks() {
        local OPTIND

	checkRunByRootFlag=false
        checkNoParamsFlag=false
	checkDebianVersionFlag=false

        while getopts "rpv" flag; do
                case "${flag}" in
			r) checkRunByRootFlag=true;;
                        p) checkNoParamsFlag=true;;
			v) checkDebianVersionFlag=true;;
                        *) printf "${RED}Invalid option -${flag}${NC}\n";;
                esac
        done

        if $checkNoParamsFlag; then
                checkNoParams
        fi

	if $checkRunByRootFlag; then
		checkRunByRoot
	fi

	if $checkDebianVersionFlag; then
		checkDebianVersionTested
	fi
}

##########################################################
# CHECK DEBIAN VERSION
##########################################################
checkDebianVersionTested() {

        #Check version file
        if [ -f /etc/debian_version==false ]
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
}

##########################################################
# CHECK ROOT
##########################################################
checkRunByRoot() {

	# Script must be run by root
	if [ "$EUID" -ne 0 ]
        	then printf "${RED}ERROR: You must be root to run this script${NC}\n"
        	exit 1
	fi
}

##########################################################
# CHECK PARAMETERS (NO PARAMETERS ALLOWED)
##########################################################
checkNoParams() {

	# No parameters allowed
	if [ $# != 0 ]
        	then printf "${RED}ERROR: This script does not accept any parameters${NC}\n"
        	exit 1
	fi
}
