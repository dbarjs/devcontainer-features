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
    return "/root"
  fi

  return "/home/$USERNAME"
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

  if ! [ -d $OMZSH_LOCATION ]; then
    echo "Installing oh-my-zsh..."
    check_packages wget
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
  fi
}


