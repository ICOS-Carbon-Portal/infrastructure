#!/bin/bash
#
# Ver: 2025-09-21 by Robert
#
export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes

REPO_BASE_DIR=$1
REPO_DIR=$(eval echo "$REPO_BASE_DIR")
repos=$(ls "$REPO_DIR" 2>/dev/null)
current_time=$(date +%Y-%m-%d)

# Check each repository
for repo in $repos; do
    [[ "$repo" == "." || "$repo" == ".." ]] && continue
    [[ "$repo" == "prometheus.repo" ]] && continue
    
    latest_archive=$(borg list --format '{time:%Y-%m-%d} {name}' --last=1 "$REPO_BASE_DIR/$repo" 2>/dev/null)
    if [[ $? -eq 0 && "$latest_archive" != "" ]]; then
        backup_date=$(echo "$latest_archive" | cut -c1-10)
        if [[ "$backup_date" != "$current_time" ]]; then
            echo "FAILURE1: Outdated backup in repo $repo"
            exit 0  # Important: exit 0 so Zabbix gets the data
        fi
    else
        echo "FAILURE2: Cannot check repo $repo"
        exit 0  # Important: exit 0 so Zabbix gets the data
    fi
done

echo "SUCCESS: All repositories have backups for today ($current_time)"
exit 0

