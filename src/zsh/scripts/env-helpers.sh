#!/bin/bash

# Check if script is running as root
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
  fi
}

# Checks if packages are installed and installs them if not
check_packages() {
  if ! dpkg -s "$@" >/dev/null 2>&1; then
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
      echo "Running apt-get update..."
      apt-get update -y
    fi
    apt-get -y install --no-install-recommends "$@"
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

# Ensures ZSH config file exists
check_zsh_config_file() {
  local ZSH_CONFIG_LOCATION="$1"

  if ! [ -f "$ZSH_CONFIG_LOCATION" ]; then
    mkdir -p "$(dirname "$ZSH_CONFIG_LOCATION")" && touch "$ZSH_CONFIG_LOCATION"
  fi
}

# Ensures ZSH is installed
check_zsh() {
  local ZSH_CONFIG_LOCATION="$1"

  if ! type zsh >/dev/null 2>&1; then
    check_packages zsh
  fi

  check_zsh_config_file "$ZSH_CONFIG_LOCATION"
}

# Ensures Oh My ZSH is installed
check_oh_my_zsh() {
  local OMZSH_LOCATION="$1"

  if ! [ -d "$OMZSH_LOCATION" ]; then
    check_packages wget
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
  fi
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

# Set directory permissions for a user
set_directory_permissions() {
  local DIRECTORY="$1"
  local USERNAME="$2"

  chown -R "$USERNAME:$(get_user_group_name "$USERNAME")" "$DIRECTORY"
}

# Set file permissions for a user
set_file_permissions() {
  local FILE="$1"
  local USERNAME="$2"

  chown "$USERNAME:$(get_user_group_name "$USERNAME")" "$FILE"
}
