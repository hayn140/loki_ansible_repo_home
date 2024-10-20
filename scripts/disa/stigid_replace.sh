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

i.e. For ${RHEL_STIGID_PREFIX}-010020 enter 010020 : " STIGID_NUM

        echo ""

            if [[ "$STIGID_NUM" =~ ^-?[0-9]+$ ]]
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
echo "You are assigning all tasks with STIG-ID ${RHEL_STIGID_PREFIX}-${STIGID_NUM} with the '$TAG_CHOICE' tag."
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

# Define STIGID variable
STIGID="${RHEL_STIGID_PREFIX}-${STIGID_NUM}"

# Ensure there's two empty lines at the end of the file for this script to work
sed -i -e '$!b' -e '/^$/!a\' -e '' "$TASKS"

###############################################################################

# Create a function to find line numbers matching STIGID, find the line number of the next
#     empty line, then add the corresponding TAG_CHOICE

tag_tasks() {

# Parse through the TASKS file and find all STIGID lines and output the line number,
#     reverse the order of the grep results, then isolate just the numbers and assign 
#     the numbers to the STIGID_LINES variable.

STIGID_LINES=$(grep -n $STIGID $TASKS | tac | cut -d ':' -f 1)


# This loop will repeat the tagging for each matched task

for LINE in $STIGID_LINES
do
    # Print task where STIGID is located to view and confirm
    echo ""
    echo "Found a match for keyword '$STIGID' on line $LINE"
    echo ""
        # Create function to display the found task

        display_found_task() {
            echo "---------------------------"
            echo ""
            # Extract lines from the start to $LINE, reverse them, and stop at the first empty line
            head -n "$LINE" "$TASKS" | tac | awk '!NF {exit} {print}' | tac

            # Extract lines from $LINE onward, exclude the first line, stop at the next empty line
            tail -n +"$LINE" "$TASKS" | awk 'NF {print} !NF {exit}' | tail -n +2
            echo ""
            echo "---------------------------"
            echo ""
        }
        
        # Call on display_found_task function

        display_found_task
    
    # Starting at the first line number in the for loop, 
    #   find the line number of the next empty line
    
    START_LINE=$LINE
    LINE_NUMBER=$(awk -v start="$START_LINE" 'NR >= start && /^[[:space:]]*$/ {print NR; exit}' "$TASKS")
    
    # echo ""
    # echo "The next empty line is at line number: $LINE_NUMBER"
    # echo ""
    
        while true
        do

        read -p "Do you want to continue tagging this task? (y/n) " CONTINUE_B
            if [[ "$CONTINUE_B" == "y" || "$CONTINUE_B" == "n" ]]; then   
                if [[ "$CONTINUE_B" == "y" ]]; then
                    
                # Add an ansible tag at the line number of the next empty line
                #   if the task doesn't already have a tags line, if it does,
                #   append the TAG_CHOICE to the existing tags line.
                    
                    # Check if task has a tags line
                        # Extract the line previous to the empty line
                        PREVIOUS_LINE=$(sed -n "$((LINE_NUMBER - 1))p" "$TASKS")

                        # Check if the line previous to the empty line starts with '  tags:'
                        if [[ $PREVIOUS_LINE =~ "  tags:"* ]]; then
                            
                            # Append tag to already existing tags line
                            NEW_LINE_NUMBER=$((LINE_NUMBER - 1))
                            echo ""
                            echo "This task already has tags: '$PREVIOUS_LINE'"
                            echo ""
                            echo "Appending '$TAG_CHOICE' to existing tags. (Line $NEW_LINE_NUMBER)"
                            echo ""
                            sed -i "$((LINE_NUMBER - 1))s/$/,$TAG_CHOICE/" "$TASKS"

                        else
                            # Add a new tags line to the task
                            echo ""
                            echo "A new 'tags:' line will be added to this task. (Line $LINE_NUMBER)"
                            echo ""

                            STRING=" tags: $TAG_CHOICE
                            "
                            sed -i "${LINE_NUMBER}i\ ${STRING}" "$TASKS"
                        
                        fi
                    
                    sleep 1

                    echo ""
                    echo "Result: "
                    
                    # Call on display_found_task function
                    display_found_task
                    echo ""
                    sleep 1

                    break
                
                else
                    
                    echo ""
                    echo "Skipping this task..."
                    break

                fi

            else
                echo "Invalid input. Please enter 'y' or 'n'."
    
            fi
        done

    sleep 1

done
}

# Call on function

tag_tasks
