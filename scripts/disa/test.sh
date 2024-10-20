#!/bin/bash

TASKS=~/loki_ansible_repo_home/playbooks/disa_stigs/roles/rhel8_stig/tasks/main.yml
HANDLERS=~/loki_ansible_repo_home/playbooks/disa_stigs/roles/rhel8_stig/handlers/main.yml
STIGID="RHEL-08-123"

###################################################################################################

# # This block of Code will make sure that the files defined in the TASKS and HANDLERS variables
# #     exist and are writable

# # Function to verify the file path is valid

# verify_file_exists() {
#     until [[ $a == "2" ]]
#     do
#         # Check if the TASKS file exists and is writable
#         if [[ -f "$TASKS" && -w "$TASKS" ]]
#         then
#             echo "TASKS file is valid and writable."
#             (( a ++ ))
#         elif [[ -f "$TASKS" ]]; then
#             echo "The TASKS file exists but is not writable. Please choose a writable file or adjust permissions on the file."
#             exit
#         else
#             echo "The TASKS file does not exist. Please enter a valid file path for the TASKS variable in the script."
#             exit
#         fi

#         # Check if the TASKS file exists and is writable
#         if [[ -f "$HANDLERS" && -w "$HANDLERS" ]]
#         then
#             echo "HANDLERS file is valid and writable."
#             (( a ++ ))
#         elif [[ -f "$HANDLERS" ]]; then
#             echo "The HANDLERS file exists but is not writable. Please choose a writable file or adjust permissions on the file."
#             exit
#         else
#             echo "The HANDLERS file does not exist. Please enter a valid file path for the HANDLERS variable in the script."
#             exit
#         fi
#     done
# }

# # Call the function to verify the files exist
# verify_file_exists
# echo ""
# echo ""

##################################################################################

# # This block of code will find the STIGID and then print out the lines before it
# #     until it finds an empty space and all the lines after the STIGID until it
# #     finds and empty space.  I was hoping to use it to have the user check to make
# #     sure that they wanted to add the tag to that particular task

# print_stigid_lines() {

# # Use awk to print lines above the found line, stopping at empty lines
# awk -v search="$STIGID" '
#     BEGIN { above_count = 0 }

#     # Store all lines in a buffer
#     {
#         if (NF) {
#             buffer[above_count++] = $0;  # Store non-empty lines
#         } else {
#             buffer[above_count++] = "";  # Store empty line
#         }
#     }

#     # If we find the search word
#     $0 ~ search {
#         # Print lines above, stopping at the first empty line
#         for (i = above_count - 1; i >= 0; i--) {
#             if (buffer[i] == "") break;  # Stop at empty line
#             print buffer[i];              # Print in the order they were stored
#         }
#         exit;  # Exit after printing
#     }

# ' "$TASKS" | tac
# # Use awk to print lines after the found line, stopping at empty lines
# awk -v search="$STIGID" '
#     # Flag to start printing after the match
#     $0 ~ search { print_found=1; next }

#     # If we found the line, print subsequent lines until we hit an empty line
#     print_found && NF { print }

#     # If we encounter an empty line, stop printing
#     print_found && !NF { exit }
# ' "$TASKS"

# }

# print_stigid_lines

##############################################################################################

# # This block of code successfully finds all instances of the STIGID and its line numbers
# # It then assigns each line number to a variable
# # Then we can use a for loop to take action on each line number defined in the variable

# # Define the search string
# STIGID="RHEL-08-123"

# # Use grep to get line numbers and store them in a variable separated by spaces
# LINE_NUMBERS=$(grep -n "$STIGID" "$TASKS" | cut -d':' -f1)

# # Now you can loop through the line numbers using a for loop
# for LINE in $LINE_NUMBERS; do
#     echo "Processing line: $LINE"
#     sleep 1
#     echo ""
#     # Do something with $LINE here
# done
###########################################################################################

# # This block of code correctly finds the STIGID and adds a tag before the next empty line
# # BUT it doesn't do it for every instance of the STIGID

# # Define the STIGID variable
# STIGID="RHEL-08-123"  # Replace with your actual STIGID
# # Define the new line to add
# new_line="  tags: cat1"

# # Use awk to find the line and add the new line before the next empty line
# awk -v stigid="$STIGID" -v new_line="$new_line" '
#     {
#         if ($0 ~ stigid && NF > 0) { # Check for STIGID and ensure the line is not empty
#             found = 1;  # Mark that we found the line with STIGID
#         }
#         if (found && NF == 0) {
#             print new_line;  # Add the new line before the next empty line
#             found = 0;  # Reset found to avoid adding multiple times
#         }
#         print;  # Print the current line
#     }
# ' "$TASKS" > temp_file && mv temp_file "$TASKS"

#############################################################################################

# This block of code will first find all the line numbers where STIGID is found
# Then it will search for the STIGID keyword and print it

# # Define the STIGID variable
# STIGID="RHEL-08-123"  # Replace with your actual STIGID value

# # Use grep to get line numbers and store them in a variable separated by spaces

# LINE_NUMBERS=$(grep -n "$STIGID" "$TASKS" | cut -d':' -f1)

# # Use awk to search from the specified line until the next empty line
# for START_LINE in $LINE_NUMBERS
# do

# echo "Code starting at line: $START_LINE"

# # Use awk to search from the specified line until the next empty line
# awk -v line="$START_LINE" -v stigid="$STIGID" '
#     NR >= line {  # Start processing from the specified line
#         if (NF == 0) {  # Stop if the line is empty
#             exit;
#         }
#         if ($0 ~ stigid) {  # Check if the line matches the STIGID
#             print;  # Print matching lines
#         }
#     }
# ' "$TASKS"


# done

#########################################################################################

# # This block of code can find the STIGID line numbers and list the number in a loop until
# # there are no more results.

# # Define the STIGID variable
# STIGID="RHEL-08-123"  # Replace with your actual STIGID value

# # Define a variable to keep track of the starting point
# start_line=0

# while true; do
#     # Use grep to find the STIGID, starting from the last found line + 1
#     result=$(grep -n "$STIGID" "$TASKS" | awk -v start="$start_line" -F: '$1 > start {print $1; exit}')
    
#     if [[ -z $result ]]; then
#         # If no result was found, break the loop
#         echo "No more results found."
#         break
#     else
#         # Print the line number of the found result
#         echo "Found STIGID at line: $result"
        
#         # Update the start_line to the found line number for the next iteration
#         start_line=$result
#     fi
# done

##############################################################################################

# # This block of code WORKS for tagging all tasks based on a STIGID, with one TAG, not for appending additional tags if needed.

# TAG_CHOICE=cat1

# # Create a function to find line numbers matching STIGID, find the line number of the next
# #     empty line, then add the corresponding TAG_CHOICE

# tag_tasks() {

# # Parse through the TASKS file and find all STIGID lines and output the line number,
# #     reverse the order of the grep results, then isolate just the numbers and assign 
# #     the numbers to the STIGID_LINES variable.

# STIGID_LINES=$(grep -n $STIGID $TASKS | tac | cut -d ':' -f 1)


# # This loop will repeat the tagging for each matched task

# for LINE in $STIGID_LINES
# do
#     # Print task where STIGID is located to view and confirm
#     echo ""
#     echo "Found a match for keyword '$STIGID' on line $LINE"
#     echo ""
#         # Create function to display the found task

#         display_found_task() {
#             echo "---------------------------"
#             echo ""
#             # Extract lines from the start to $LINE, reverse them, and stop at the first empty line
#             head -n "$LINE" "$TASKS" | tac | awk '!NF {exit} {print}' | tac

#             # Extract lines from $LINE onward, exclude the first line, stop at the next empty line
#             tail -n +"$LINE" "$TASKS" | awk 'NF {print} !NF {exit}' | tail -n +2
#             echo ""
#             echo "---------------------------"
#             echo ""
#         }
        
#         # Call on display_found_task function

#         display_found_task
    
#     # Starting at the first line number in the for loop, 
#     #   find the line number of the next empty line
    
#     START_LINE=$LINE
#     LINE_NUMBER=$(awk -v start="$START_LINE" 'NR >= start && /^[[:space:]]*$/ {print NR; exit}' "$TASKS")
    
#     # echo ""
#     # echo "The next empty line is at line number: $LINE_NUMBER"
#     # echo ""
    
#         while true
#         do

#         read -p "Do you want to continue tagging this task? (y/n) " CONTINUE_B
#             if [[ "$CONTINUE_B" == "y" || "$CONTINUE_B" == "n" ]]; then   
#                 if [[ "$CONTINUE_B" == "y" ]]; then
                    
#                     # Add an ansible tag at the line number of the next empty line
                    
#                     echo ""
#                     echo "Adding ansible tag '$TAG_CHOICE' at line $LINE_NUMBER..."
                    
#                     STRING=" tags: $TAG_CHOICE
#                     "
#                     sed -i "${LINE_NUMBER}i\ ${STRING}" "$TASKS"
#                     sleep 1

#                     echo ""
#                     echo "Result: "
#                     display_found_task
#                     echo ""
#                     sleep 1

#                     break
                
#                 else
                    
#                     echo ""
#                     echo "Skipping this task..."
#                     break

#                 fi

#             else
#                 echo "Invalid input. Please enter 'y' or 'n'."
    
#             fi
#         done

#     sleep 1

# done
# }

# # Call on function

# tag_tasks

##############################################################################################

# LINE=10

# # Define the line number you're starting from

# # Extract lines from the start to $LINE, reverse them, and stop at the first empty line
# head -n "$LINE" "$TASKS" | tac | awk '!NF {exit} {print}' | tac

# # Extract lines from $LINE onward, exclude the first line, stop at the next empty line
# tail -n +"$LINE" "$TASKS" | awk 'NF {print} !NF {exit}' | tail -n +2

##############################################################################################

# This block of code will attempt to check for tags: and if doesnt exist add the line, if it does, 
#   append TAG_CHOICE to the line

TAG_CHOICE=cat1

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
                    
                    echo ""
                    echo "Adding ansible tag '$TAG_CHOICE' at line $LINE_NUMBER..."
                    
                    STRING=" tags: $TAG_CHOICE
                    "
                    sed -i "${LINE_NUMBER}i\ ${STRING}" "$TASKS"
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
