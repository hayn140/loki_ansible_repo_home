#!/bin/bash

TASKS=~/loki_ansible_repo_home/playbooks/disa_stigs/roles/rhel8_stig/tasks/main.yml
HANDLERS=~/loki_ansible_repo_home/playbooks/disa_stigs/roles/rhel8_stig/handlers/main.yml
# Function to verify the file path is valid

verify_file_exists() {
    until [[ $a == "2" ]]
    do
        # Check if the TASKS file exists and is writable
        if [[ -f "$TASKS" && -w "$TASKS" ]]
        then
            echo "TASKS file is valid and writable."
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
            echo "HANDLERS file is valid and writable."
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
echo ""
echo ""
STIGID=RHEL-08-123

# Use awk to print lines above the found line, stopping at empty lines
awk -v search="$STIGID" '
    BEGIN { above_count = 0 }

    # Store all lines in a buffer
    {
        if (NF) {
            buffer[above_count++] = $0;  # Store non-empty lines
        } else {
            buffer[above_count++] = "";  # Store empty line
        }
    }

    # If we find the search word
    $0 ~ search {
        # Print lines above, stopping at the first empty line
        for (i = above_count - 1; i >= 0; i--) {
            if (buffer[i] == "") break;  # Stop at empty line
            print buffer[i];              # Print in the order they were stored
        }
        exit;  # Exit after printing
    }

' "$TASKS" | tac