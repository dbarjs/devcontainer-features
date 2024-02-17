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

initialize_zsh_plugins_config() {
  local ZSH_CONFIG_LOCATION="$1"
  
  # Check if a valid plugins config exists, if not, add an empty config
  if ! grep -q "^\s*plugins=\((\s*\S+\s*)*\)" "$ZSH_CONFIG_LOCATION"; then
    echo "plugins=( )" >> "$ZSH_CONFIG_LOCATION"
  fi
}

add_plugin_to_zsh_config_file() {
    local ZSH_CONFIG_LOCATION="$1"
    local PLUGIN_NAME="$2"

    initialize_zsh_plugins_config "$ZSH_CONFIG_LOCATION"

    # Check if the plugin already exists in the configuration
    if grep -q "^\s*plugins=\(.*\b${PLUGIN_NAME}\b.*\)\s*$" "$ZSH_CONFIG_LOCATION"; then
        echo "Plugin '$PLUGIN_NAME' is already configured."
        return
    fi

    # Use awk to update the .zshrc file, ensuring proper plugin addition
    awk -v np="$PLUGIN_NAME" '
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

set_theme_to_zsh_config_file() {
  local ZSH_CONFIG_LOCATION="$1"
  local THEME_NAME="$2"

  sed -i -e "s/ZSH_THEME=.*/ZSH_THEME=\"$THEME_NAME\"/g" "$ZSH_CONFIG_LOCATION"
}
