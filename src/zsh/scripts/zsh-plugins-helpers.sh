#!/bin/bash

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

# Function: is_zsh_plugin_cloned
# Description: Checks if a ZSH plugin is already cloned in the specified location.
# Parameters:
#   - PLUGIN_NAME: The name of the plugin to check.
#   - PLUGINS_LOCATION: The location where the plugins are stored.
# Returns:
#   - 0 if the plugin is already cloned.
#   - 1 if the plugin is not cloned.
is_zsh_plugin_cloned() {
  local PLUGIN_NAME="$1"
  local PLUGINS_LOCATION="$2"

  if [ -d "$PLUGINS_LOCATION/$PLUGIN_NAME" ]; then
    return 0
  else
    return 1
  fi
}

# Function: clone_zsh_plugin
# Description: Clones a Zsh plugin from a given URL and stores it in the specified location.
# Parameters:
#   - PLUGIN_URL: The URL of the Zsh plugin to clone.
#   - PLUGIN_NAME: The slug or name of the Zsh plugin.
#   - PLUGINS_LOCATION: The location where the cloned plugin will be stored.
# Returns: None
clone_zsh_plugin() {
  local PLUGIN_URL="$1"
  local PLUGIN_NAME="$2"
  local PLUGINS_LOCATION="$3"

  if ! is_zsh_plugin_cloned "$PLUGIN_NAME" "$PLUGINS_LOCATION"; then
    echo "Cloning plugin $PLUGIN_NAME..."

    git clone --depth 1 "$PLUGIN_URL" "$PLUGINS_LOCATION/$PLUGIN_NAME"
  fi
}

extract_plugin_list_from_zsh_config() {
  local ZSH_CONFIG_PATH="$1"

  local PLUGINS_LIST
  
  PLUGINS_LIST=$(awk '
  /^\s*plugins=\(/ {
    collect=1
    sub(/plugins=\(\s*/, "")
  }
  collect {
    line = $0
    gsub(/^[ \t]+|[ \t]+$/, "", line)
    if (/\)/) {
      gsub(/\).*/, "", line)
      collect=0
    }
    if (length(line) > 0) {
      if (plugins != "") plugins = plugins " "
      plugins = plugins line
    }
  }
  END { print plugins }
  ' "$ZSH_CONFIG_PATH" | tr ' ' '\n' | awk NF | paste -sd' ' -)

  echo "$PLUGINS_LIST"
}

add_plugin_to_zsh_config_file() {
    local ZSH_CONFIG_LOCATION="$1"
    local NEW_PLUGIN_NAME="$2"

    awk -v np="$NEW_PLUGIN_NAME" '
    /^\s*plugins=\(.*\)\s*$/ {
        if ($0 !~ np) {
            sub(/\)$/, " " np "&")
        }
        print
        next
    }
    /^\s*plugins=\(/ {
        in_plugins=1
    }
    in_plugins {
        if (/\)/) {
            in_plugins=0
            if ($0 !~ np) {
                sub(/\)/, " " np "&")
            }
        }
    }
    { print }
    ' "$ZSH_CONFIG_LOCATION" > "${ZSH_CONFIG_LOCATION}.tmp" && mv "${ZSH_CONFIG_LOCATION}.tmp" "$ZSH_CONFIG_LOCATION"
}

# Function to install a ZSH plugin by URL or slug.
# Parameters:
#   - PLUGIN_NAME_OR_URL: The slug or URL of the plugin.
#   - ZSH_CONFIG_LOCATION: The location of the ZSH configuration.
#   - PLUGINS_LOCATION: The location where the plugins are stored.
install_zsh_plugin_by_url_or_slug() {
  local PLUGIN_NAME_OR_URL="$1"
  local ZSH_CONFIG_LOCATION="$2"
  local PLUGINS_LOCATION="$3"

  # If the plugin is not provided, return
  if [ -z "$PLUGIN" ]; then
    return
  fi

  echo "Installing ZSH plugin: $PLUGIN_NAME on $PLUGINS_LOCATION"

  local PLUGIN_NAME
  local PLUGIN_URL

  if is_plugin_url "$PLUGIN_NAME_OR_URL"; then
    PLUGIN_URL="$PLUGIN_NAME_OR_URL"
    PLUGIN_NAME=$(basename "$PLUGIN_URL")

    clone_zsh_plugin "$PLUGIN_URL" "$PLUGIN_NAME" "$PLUGINS_LOCATION"
  else
    PLUGIN_NAME="$PLUGIN_NAME_OR_URL"
  fi

  add_plugin_to_zsh_config_file "$ZSH_CONFIG_LOCATION" "$PLUGIN_NAME"
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

  echo "Installing ZSH plugins..."

  for PLUGIN in $PLUGIN_LIST; do
    install_zsh_plugin_by_url_or_slug "$PLUGIN" "$ZSH_CONFIG_LOCATION" "$PLUGINS_LOCATION"
  done
}
