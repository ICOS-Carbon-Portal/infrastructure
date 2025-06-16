#!/bin/bash
set -euo pipefail

export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes

servers=(fsicos2 cdb icos1)

for server in "${servers[@]}"; do
    echo -e "\nChecking server: $server" >&2
    
    # Get the list of repositories from the remote server
    repos=$(ssh "$server" ls ~bbserver/repos)

    # Loop over each repository
    for repo in $repos; do
        # Run borg to get the latest archive name
        latest_archive=$(borg list --short --last=1 "$server:~bbserver/repos/$repo" 2>/dev/null)

        # Check if the borg command was successful
        if [ $? -eq 0 ]; then
            echo -e "${repo}\t${latest_archive}"
        else
            echo -e "${repo}\tERROR"
        fi
    done
done
