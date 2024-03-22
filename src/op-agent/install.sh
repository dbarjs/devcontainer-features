#!/bin/bash

set -e

USERNAME=${USERNAME:-$_REMOTE_USER}
SSH_CONFIG_MOUNT_PATH="${SSHCONFIGMOUNTPATH:-"/home/node/ssh-config"}"

echo "installing $USERNAME"

# Import helper scripts
source "scripts/helpers.sh"

# Check if root
check_root

echo "Configuring ZSH for user: $USERNAME"

USER_LOCATION=$(get_user_location "$USERNAME")

copy_ssh_config "$SSH_CONFIG_MOUNT_PATH" "$USER_LOCATION"
