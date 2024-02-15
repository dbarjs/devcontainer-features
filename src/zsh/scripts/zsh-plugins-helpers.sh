#!/bin/bash

# Function: get_zshrc_content
# Description: Retrieves the content of the zsh configuration file.
# Parameters:
#   - ZSH_CONFIG_LOCATION: The location of the zsh configuration file.
# Returns:
#   - The content of the zsh configuration file, or "bad config location" if the file does not exist.
get_zshrc_content() {
  local ZSH_CONFIG_LOCATION="$1"

  if ! [ -f "$ZSH_CONFIG_LOCATION" ]; then
    echo "bad config location"
    return
  fi

  cat "$ZSH_CONFIG_LOCATION"
}


# Function: is_plugin_url
# Description: Checks if a given plugin URL is valid.
# Parameters:
#   - PLUGIN_URL: The plugin URL to check.
# Returns:
#   - 0 if the plugin URL is a valid URL.
#   - 1 if the plugin URL is not a valid URL.
is_plugin_url() {
  local PLUGIN_URL="$1"

  if [[ "$PLUGIN_URL" == *"/"* ]]; then
    return 0  # Plugin is URL
  else
    return 1  # Plugin is not URL
  fi
}

# Extracts the raw plugin list from the Zsh configuration content.
# Parameters:
#   - ZSH_CONFIG_CONTENT: The content of the Zsh configuration file.
# Returns: None
#   - The raw plugin list extracted from the Zsh configuration content.
get_raw_plugin_list() {
  local ZSH_CONFIG_CONTENT="$1"
  echo "$ZSH_CONFIG_CONTENT" | awk '/plugins=\(/,/)/ {if (!/\)/ ) print $0}'
}

# Function: format_plugin_list
# Description: Formats a raw plugin list by removing unnecessary characters and spaces.
# Parameters:
#   - RAW_PLUGIN_LIST: The raw plugin list to be formatted.
# Returns:
#   - The formatted plugin list.
format_plugin_list() {
  local RAW_PLUGIN_LIST="$1"
  echo "$RAW_PLUGIN_LIST" | tr '\n' ' ' | sed 's/plugins=(//;s/)//' | sed 's/  */ /g' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

# Function: add_plugin_to_list
# Description: Adds a new plugin to the plugin list, ensuring uniqueness and alphabetical order.
# Parameters:
#   - PLUGIN_LIST: The existing plugin list.
#   - NEW_PLUGIN: The new plugin to be added.
# Returns:
#   The updated plugin list with the new plugin added.
add_plugin_to_list() {
  local PLUGIN_LIST="$1"
  local NEW_PLUGIN="$2"
  echo "$PLUGIN_LIST $NEW_PLUGIN" | tr ' ' '\n' | sort | uniq | tr '\n' ' ' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

# Function: get_installed_zsh_plugins
# Description: Retrieves the list of installed Zsh plugins based on the provided Zsh configuration file.
# Parameters:
#   - ZSH_CONFIG_LOCATION: The location of the Zsh configuration file.
# Returns:
#   - The formatted list of installed Zsh plugins.
get_installed_zsh_plugins() {
  local ZSH_CONFIG_LOCATION="$1"

  local ZSH_CONFIG_CONTENT
  local RAW_PLUGIN_LIST
  local FORMATTED_PLUGIN_LIST
  
  ZSH_CONFIG_CONTENT=$(get_zshrc_content "$ZSH_CONFIG_LOCATION")
  RAW_PLUGIN_LIST=$(get_raw_plugin_list "$ZSH_CONFIG_CONTENT")
  FORMATTED_PLUGIN_LIST=$(format_plugin_list "$RAW_PLUGIN_LIST")

  echo "plugins: $FORMATTED_PLUGIN_LIST"
}

# Function to format the plugins inline in the .zshrc file
# Arguments:
#   1. ZSH_CONFIG_LOCATION: The location of the .zshrc file
# Returns:
#   None
format_plugins_inline() {
  local ZSH_CONFIG_LOCATION="$1"

  local ZSH_CONFIG_CONTENT
  local RAW_PLUGIN_LIST
  local FORMATTED_PLUGIN_LIST

  if ! [ -f "$ZSH_CONFIG_LOCATION" ]; then
    echo "bad config location"
    return
  fi

  ZSH_CONFIG_CONTENT=$(get_zshrc_content "$ZSH_CONFIG_LOCATION")
  RAW_PLUGIN_LIST=$(get_raw_plugin_list "$ZSH_CONFIG_CONTENT")
  FORMATTED_PLUGIN_LIST=$(format_plugin_list "$RAW_PLUGIN_LIST")

  # Replace the old plugins list with the new one in the .zshrc file
  perl -i -pe "BEGIN{undef $/;} s/plugins=\(.*?\)/plugins=($FORMATTED_PLUGIN_LIST)/smg" "$ZSH_CONFIG_LOCATION"
}

#
# Function: is_plugin_added_to_config
# Description: Checks if a plugin is added to the plugin list in the configuration.
#
# Parameters:
#   - PLUGIN_LIST: The list of plugins in the configuration.
#   - PLUGIN_TO_CHECK: The plugin to check if it is added to the configuration.
#
# Returns:
#   - 0: If the plugin is installed.
#   - 1: If the plugin is not installed.
#
is_plugin_added_to_config() {
  local PLUGIN_LIST="$1"
  local PLUGIN_TO_CHECK="$2"
  
  if echo "$PLUGIN_LIST" | grep -q -w "$PLUGIN_TO_CHECK"; then
    return 0  # Plugin is installed
  else
    return 1  # Plugin is not installed
  fi
}

# Function: is_zsh_plugin_cloned
# Description: Checks if a ZSH plugin is already cloned in the specified location.
# Parameters:
#   - PLUGIN_SLUG: The name of the plugin to check.
#   - PLUGINS_LOCATION: The location where the plugins are stored.
# Returns:
#   - 0 if the plugin is already cloned.
#   - 1 if the plugin is not cloned.
is_zsh_plugin_cloned() {
  local PLUGIN_SLUG="$1"
  local PLUGINS_LOCATION="$2"

  if [ -d "$PLUGINS_LOCATION/$PLUGIN_SLUG" ]; then
    echo "Plugin $PLUGIN_SLUG is already cloned. Skipping..."
    return 0  # Plugin is cloned
  else
    return 1  # Plugin is not cloned
  fi
}

# Function: clone_zsh_plugin
# Description: Clones a Zsh plugin from a given URL and stores it in the specified location.
# Parameters:
#   - PLUGIN_URL: The URL of the Zsh plugin to clone.
#   - PLUGIN_SLUG: The slug or name of the Zsh plugin.
#   - PLUGINS_LOCATION: The location where the cloned plugin will be stored.
# Returns: None
clone_zsh_plugin() {
  local PLUGIN_URL="$1"
  local PLUGIN_SLUG="$2"
  local PLUGINS_LOCATION="$3"

  if ! is_zsh_plugin_cloned "$PLUGIN_SLUG" "$PLUGINS_LOCATION"; then
    echo "Cloning plugin $PLUGIN_SLUG..."

    git clone --depth 1 "$PLUGIN_URL" "$PLUGINS_LOCATION/$PLUGIN_SLUG"
  fi
}

# Function to configure a Zsh plugin.
# Parameters:
#   - PLUGIN_SLUG: The slug of the plugin to configure.
#   - ZSH_CONFIG_LOCATION: The location of the Zsh configuration file.
config_zsh_plugin() {
  local PLUGIN_SLUG="$1"
  local ZSH_CONFIG_LOCATION="$2"

  local ZSH_CONFIG_CONTENT
  local RAW_PLUGIN_LIST
  local FORMATTED_PLUGIN_LIST
  local NEW_PLUGIN_LIST

  # Get the content of the Zsh configuration file.
  ZSH_CONFIG_CONTENT=$(get_zshrc_content "$ZSH_CONFIG_LOCATION")

  # Get the raw plugin list from the Zsh configuration content.
  RAW_PLUGIN_LIST=$(get_raw_plugin_list "$ZSH_CONFIG_CONTENT")

  # Format the plugin list for easier manipulation.
  FORMATTED_PLUGIN_LIST=$(format_plugin_list "$RAW_PLUGIN_LIST")

  # Check if the plugin is already added to the configuration.
  if is_plugin_added_to_config "$FORMATTED_PLUGIN_LIST" "$PLUGIN_SLUG"; then
    echo "Plugin $PLUGIN_SLUG is already installed. Skipping..."
    return
  fi

  # Add the plugin to the list of plugins.
  NEW_PLUGIN_LIST=$(add_plugin_to_list "$FORMATTED_PLUGIN_LIST" "$PLUGIN_SLUG")

  # Update the Zsh configuration file with the new plugin list.
  sed -i "s/^plugins=(.*$/plugins=($NEW_PLUGIN_LIST)/" "$ZSH_CONFIG_LOCATION"
}

# Function to install a ZSH plugin by URL or slug.
# Parameters:
#   - PLUGIN_SLUG_OR_URL: The slug or URL of the plugin.
#   - ZSH_CONFIG_LOCATION: The location of the ZSH configuration.
#   - PLUGINS_LOCATION: The location where the plugins are stored.
install_zsh_plugin_by_url_or_slug() {
  local PLUGIN_SLUG_OR_URL="$1"
  local ZSH_CONFIG_LOCATION="$2"
  local PLUGINS_LOCATION="$3"

  # If the plugin is not provided, return
  if [ -z "$PLUGIN" ]; then
    return
  fi

  echo "Installing ZSH plugin: $PLUGIN_SLUG on $PLUGINS_LOCATION"

  local PLUGIN_SLUG
  local PLUGIN_URL

  if is_plugin_url "$PLUGIN_SLUG_OR_URL"; then
    PLUGIN_URL="$PLUGIN_SLUG_OR_URL"
    PLUGIN_SLUG=$(basename "$PLUGIN_URL")

    clone_zsh_plugin "$PLUGIN_URL" "$PLUGIN_SLUG" "$PLUGINS_LOCATION"
  else
    PLUGIN_SLUG="$PLUGIN_SLUG_OR_URL"
  fi
  
  if ! is_zsh_plugin_cloned "$PLUGIN_SLUG" "$PLUGINS_LOCATION"; then
    echo "Plugin $PLUGIN_SLUG is not cloned. Skipping..."
    return
  fi

  config_zsh_plugin "$PLUGIN_SLUG" "$ZSH_CONFIG_LOCATION"
}

# Install ZSH plugins by URL or slug list
#
# This function installs ZSH plugins based on a list of plugin URLs. It takes three parameters:
# - PLUGIN_LIST: A space-separated list of plugin URLs or slugs.
# - PLUGINS_LOCATION: The location where the plugins will be installed.
# - ZSH_CONFIG_LOCATION: The location of the ZSH configuration file.
#
# If PLUGIN_LIST is empty, the function returns without performing any installation.
# For each plugin URL in PLUGIN_LIST, the function calls the install_zsh_plugin_by_url_or_slug function to install the plugin.
#
# Example usage:
# install_zsh_plugin_list "https://github.com/zsh-users/zsh-autosuggestions" "/path/to/plugins" "/path/to/zshrc"
#
install_zsh_plugin_list() {
  local PLUGIN_LIST="$1"
  local PLUGINS_LOCATION="$2"
  local ZSH_CONFIG_LOCATION="$3"

  # If the plugin list is empty, return
  if [ -z "$PLUGIN_LIST" ]; then
    echo "No plugins to install."
    return
  fi

  # Format the plugins inline in the .zshrc file
  format_plugins_inline "$ZSH_CONFIG_LOCATION"

  echo "Installing ZSH plugins..."

  for PLUGIN_URL in $PLUGIN_LIST; do
    install_zsh_plugin_by_url_or_slug "$PLUGIN_URL" "$ZSH_CONFIG_LOCATION" "$PLUGINS_LOCATION"
  done
}
