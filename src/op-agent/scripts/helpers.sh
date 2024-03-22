#!/bin/bash

# Check if script is running as root
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
  fi
}

# Get the location of the user's home directory
get_user_location() {
  local USERNAME="$1"

  if [ "$USERNAME" = "root" ]; then
    echo "/root"
    return
  fi

  echo "/home/$USERNAME"
}

# Get GID of the username group
get_user_group_name() {
  local USERNAME="$1"

  local group_name="$USERNAME"

  if id -u "${USERNAME}" > /dev/null 2>&1; then
    group_name=$(id -gn "${USERNAME}")
  fi

  echo "$group_name"
}

# Set file permissions for a user
set_file_permissions() {
  local FILE="$1"
  local USERNAME="$2"

  chown "$USERNAME:$(get_user_group_name "$USERNAME")" "$FILE"
}

# Copy SSH config files to user's home directory
copy_ssh_config() {
  local SSH_CONFIG_MOUNT_PATH="$1"
  local USER_LOCATION="$2"

  if [ -d "$SSH_CONFIG_MOUNT_PATH" ]; then
    cp -a "$SSH_CONFIG_MOUNT_PATH/." "$USER_LOCATION/.ssh/"
    sed -i '/IdentityAgent ~\\/\\.1password\\/agent\\.sock/d' "$USER_LOCATION/.ssh/config"
  else
    echo "SSH config directory not found at $SSH_CONFIG_MOUNT_PATH"
  fi
}

# get: git config --global gpg.ssh.program
# unset: git config --global --unset gpg.ssh.program

# Get git `gpg.ssh.program` of the user config
get_git_ssh_config() {
  local USERNAME="$1"
  local USER_LOCATION
  
  USER_LOCATION=$(get_user_location "$USERNAME")

  git config --file="$USER_LOCATION/.gitconfig" gpg.ssh.program
}

# Unset git `gpg.ssh.program` of the user config
unset_git_ssh_config() {
  local USERNAME="$1"
  local USER_LOCATION
  
  USER_LOCATION=$(get_user_location "$USERNAME")

  git config --file="$USER_LOCATION/.gitconfig" --unset gpg.ssh.program
  set_file_permissions "$USER_LOCATION/.gitconfig" "$USERNAME"
}

# Check if 1Password configured for git is available, if not, unset it
unset_git_op_agent() {
  local USERNAME="$1"

  local GIT_SSH_AGENT_PATH

  GIT_SSH_AGENT_PATH=$(get_git_ssh_config "$USERNAME")

  # check if ssh agent path is set, if not, return
  if [ -z "$GIT_SSH_AGENT_PATH" ]; then
    return
  fi

  # check if ssh agent path has 1Password agent (op-ssh-sign), if not, return
  if [[ "$GIT_SSH_AGENT_PATH" != *"op-ssh-sign"* ]]; then
    return
  fi

  # check if ssh agent path exists, if not, return
  if [ ! -f "$GIT_SSH_AGENT_PATH" ]; then
    return
  fi
  
  # unset git `gpg.ssh.program` of the user config
  unset_git_ssh_config "$USERNAME"
}
