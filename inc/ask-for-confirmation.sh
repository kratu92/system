#/bin/bash

# Ask for confirmation
continueScript=false
until [ "$continueScript" == "true" ]
do
        read -r -p "Do you want to continue? [y/N] " response
        res=${response,,} # tolower

        case $response in
                yes|y)
                        continueScript=true
                        ;;
                no|n|"")
                        printf "${RED}Execution was cancelled${NC}\n"
                        exit 1
                        ;;
                *)
                        printf "${RED}Invalid response${NC}\n"
                        ;;
        esac
done

