#!/bin/bash

set -e

USERNAME="${USERNAME:-"node"}"
COMMAND_HISTORY_LOCATION="${COMMANDHISTORYLOCATION:-"/commandhistory/"}"
OMZ_PLUGIN_LIST="${OMZPLUGINLIST:-""}"


# Import helper scripts
source "./scripts/env-helpers.sh"
source "./scripts/command-history-helpers.sh"
source "./scripts/omzsh-helpers.sh"
source "./scripts/zsh-plugins-helpers.sh"
source "./scripts/zsh-themes-helpers.sh"

# Check if root
check_root

echo "Configuring ZSH for user: $USERNAME"

# Get user location
USER_LOCATION=$(get_user_location "$USERNAME")

# Get config locations
BASH_CONFIG_LOCATION="$USER_LOCATION/.bashrc"
ZSH_CONFIG_LOCATION="$USER_LOCATION/.zshrc"
OMZSH_LOCATION=$(get_omzsh_location "$USER_LOCATION")

# Check ZSH installation
check_zsh "$ZSH_CONFIG_LOCATION"

# Config command history
create_command_history_location "$COMMAND_HISTORY_LOCATION"
config_bash_history "$BASH_CONFIG_LOCATION" "$COMMAND_HISTORY_LOCATION"
config_zsh_history "$ZSH_CONFIG_LOCATION" "$COMMAND_HISTORY_LOCATION"

# Check Oh My ZSH installation
check_oh_my_zsh "$OMZSH_LOCATION"

# Install plugins
install_zsh_plugin_list "$OMZ_PLUGIN_LIST" "$(get_omzsh_plugins_location "$OMZSH_LOCATION")" "$ZSH_CONFIG_LOCATION"

# Install themes
install_spaceship_theme "$(get_omzsh_themes_location "$OMZSH_LOCATION")" "$ZSH_CONFIG_LOCATION"
