#!/bin/bash

# Declare the STIG YAML files (TASKS & HANDLERS) and RHEL distribution (RHEL_VERSION)

TASKS=~/loki_ansible_repo_home/playbooks/disa_stigs/roles/rhel8_stig/tasks/main.yml
HANDLERS=~/loki_ansible_repo_home/playbooks/disa_stigs/roles/rhel8_stig/handlers/main.yml
RHEL_VERSION=8


# Create function to verify the file path is valid

verify_file_exists() {
    until [[ $a == "2" ]]
    do
        # Check if the TASKS file exists and is writable
        if [[ -f "$TASKS" && -w "$TASKS" ]]
        then
            (( a ++ ))
        elif [[ -f "$TASKS" ]]; then
            echo "The TASKS file exists but is not writable. Please choose a writable file or adjust permissions on the file."
            exit
        else
            echo "The TASKS file does not exist. Please enter a valid file path for the TASKS variable in the script."
            exit
        fi

        # Check if the TASKS file exists and is writable
        if [[ -f "$HANDLERS" && -w "$HANDLERS" ]]
        then
            (( a ++ ))
        elif [[ -f "$HANDLERS" ]]; then
            echo "The HANDLERS file exists but is not writable. Please choose a writable file or adjust permissions on the file."
            exit
        else
            echo "The HANDLERS file does not exist. Please enter a valid file path for the HANDLERS variable in the script."
            exit
        fi
    done
}


# Call the function to verify the files exist
verify_file_exists


# Define other variables based on RHEL_DISTRO variable

case $RHEL_VERSION in
    8)
        RHEL_STIGID_PREFIX=RHEL-08;;
    9)
        RHEL_STIGID_PREFIX=RHEL-09;;
esac

echo ""


# Have user verify their settings before continuing

echo "Verify that the following are correct before continuing:


Tasks file to edit: 
----------------------

$TASKS


Handlers file to edit:
----------------------

$HANDLERS


RHEL Distribution:
----------------------

$RHEL_STIGID_PREFIX


"
    while true
    do

    read -p "Is this all correct? (y/n) : " RESPONSE
        if [[ "$RESPONSE" == "y" || "$RESPONSE" == "n" ]]; then   
            if [[ "$RESPONSE" == "y" ]]; then   
                break
            else
                echo ""
                echo "Please adjust the TASKS, HANDLERS, and/or RHEL_VERSION variables with the correct information then rerun the script."
                exit
            fi
        else
            echo ""
            echo "Invalid input. Please enter 'y' or 'n'."
    
        fi
    done

echo ""


# Declare the STIGID variable

until [[ $CONTINUE == "y" ]]
do

    while true
    do
        read -p "

Enter the STIG-ID number you wish to Target

i.e. For ${RHEL_STIGID_PREFIX}-010020 enter 010020 : " STIGID

        echo ""

            if [[ "$STIGID" =~ ^-?[0-9]+$ ]]
            then
                break
            
            else
                echo "Invalid input. Please enter a valid integer."

            fi
    done


# Declare TAG Variable
declare -a TAG=("cat1" "cat2" "cat3" "cat_all" "ste")

    # Show a list of TAG options

    while true
    do
    
    echo "Here are the available ansible tags to choose from:"
    echo ""

        for i in "${!TAG[@]}"
        do 
            echo "$((i + 1)): ${TAG[i]}"
        done

        read -r -p "

Please select the TAG to assign to this STIG-ID (1-5) : " SELECTION

            if [[ "$SELECTION" =~ ^[1-5] ]]
            then
                case $SELECTION in
                    1)
                        TAG_CHOICE=cat1;;
                    2)
                        TAG_CHOICE=cat2;;
                    3)
                        TAG_CHOICE=cat3;;
                    4)
                        TAG_CHOICE=cat_all;;
                    5)
                        TAG_CHOICE=ste;;
                esac
                break

            else
                echo "Invalid input. Please enter a valid integer"

            fi
    echo ""
    done


# Verify STIGID and TAG Association before continuing script
echo ""
echo "You are assigning all tasks with STIG-ID ${RHEL_STIGID_PREFIX}-${STIGID} with the '$TAG_CHOICE' tag."
echo ""

    while true
    do

    read -p "Do you want to continue? (y/n) : " CONTINUE
        if [[ "$CONTINUE" == "y" || "$CONTINUE" == "n" ]]
        then   
            break

        else
            echo "Invalid input. Please enter 'y' or 'n'."
    
        fi
    done
done

echo ""

tag_tasks() {

STIGID_LINES=$(grep -n $STIGID $TASKS | cut -d ':' -f 1)

for LINE in $STIGID_LINES
do

# Print line numbers where STIGIDs are located
echo "Line $LINE"

# Print strings found at line numbers, should be STIGIDs
sed -n "${LINE}p" "$TASKS"

# Starting at the first line number in the for loop, 
#   find the line number of the next empty line
START_LINE=$LINE
LINE_NUMBER=$(awk -v start="$START_LINE" 'NR >= start && /^$/ {print NR; exit}' "$TASKS")

echo "The next empty line is at line number: $LINE_NUMBER"

# Add an ansible tag at the line number of the next empty line
STRING=" tags: $TAG_CHOICE
"
sed -i "${LINE_NUMBER}i\ ${STRING}" "$TASKS"

done

}

tag_tasks