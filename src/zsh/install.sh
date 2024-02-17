#!/bin/bash

set -e

USERNAME=${USERNAME:-$_REMOTE_USER}
CONFIGURE_COMMAND_HISTORY="${CONFIGURECOMMANDHISTORY:-"true"}"
OMZ_PLUGIN_CLONE_LIST="${OMZPLUGINCLONELIST:-""}"
ZSH_PLUGIN_LIST="${ZSHPLUGINLIST:-"git"}"
RESTORE_ZSH_CONFIG="${RESTOREZSHCONFIG:-"true"}"
INSTALL_SPACESHIP_THEME="${INSTALLSPACESHIPTHEME:-"true"}"
COMMAND_HISTORY_LOCATION="${COMMANDHISTORYLOCATION:-"/commandhistory"}"

echo "installing $USERNAME"

# Import helper scripts
source "scripts/env-helpers.sh"
source "scripts/command-history-helpers.sh"
source "scripts/omzsh-helpers.sh"
source "scripts/zshrc-helpers.sh"
source "scripts/spaceship-theme-helpers.sh"

# Check if root
check_root

echo "Configuring ZSH for user: $USERNAME"

# Check if required packages are installed
check_packages git ca-certificates zsh

# Get user location
USER_LOCATION=$(get_user_location "$USERNAME")

# Get config locations
BASH_CONFIG_LOCATION="$USER_LOCATION/.bashrc"
ZSH_CONFIG_LOCATION="$USER_LOCATION/.zshrc"
OMZSH_LOCATION=$(get_omzsh_location "$USER_LOCATION")

# Check ZSH installation
check_oh_my_zsh "$OMZSH_LOCATION"

# Restore ZSH config with OMZ default .zshrc
if [ "$RESTORE_ZSH_CONFIG" = "true" ]; then
  install_omzsh_rc_template "$OMZSH_LOCATION" "$ZSH_CONFIG_LOCATION"
fi

# Config command history
if [ "$CONFIGURE_COMMAND_HISTORY" = "true" ]; then
  # set command history location (default: /commandhistory)
  create_command_history_location "$COMMAND_HISTORY_LOCATION"
  set_directory_permissions "$COMMAND_HISTORY_LOCATION" "$USERNAME"

  # config bash history
  config_bash_history "$BASH_CONFIG_LOCATION" "$COMMAND_HISTORY_LOCATION"

  # config zsh history
  config_zsh_history "$ZSH_CONFIG_LOCATION" "$COMMAND_HISTORY_LOCATION"
fi

# Clone OMZ plugins
if [ -n "$OMZ_PLUGIN_CLONE_LIST" ]; then
  for PLUGIN_URL in $OMZ_PLUGIN_CLONE_LIST; do
    clone_omz_plugin "$PLUGIN_URL" "$OMZSH_LOCATION"
  done
fi

# Add ZSH plugins to .zshrc
if [ -n "$ZSH_PLUGIN_LIST" ]; then
  for PLUGIN_NAME in $ZSH_PLUGIN_LIST; do
    add_plugin_to_zsh_config_file "$ZSH_CONFIG_LOCATION" "$PLUGIN_NAME"
  done
fi

# Configure Spaceship theme 
if [ "$INSTALL_SPACESHIP_THEME" = "true" ]; then
  install_spaceship_theme "$(get_omzsh_themes_location "$OMZSH_LOCATION")" "$ZSH_CONFIG_LOCATION"
  set_theme_to_zsh_config_file "$ZSH_CONFIG_LOCATION" "spaceship"
fi

# Set permission for installed OMZ plugins and themes
set_directory_permissions "$OMZSH_LOCATION" "$USERNAME"

# Set permission for ZSH config file
set_file_permissions "$ZSH_CONFIG_LOCATION" "$USERNAME"
