#!/bin/bash

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
