#!/bin/bash

# Get Oh My ZSH location
get_omzsh_location() {
  local USERLOCATION="$1"

  echo "$USERLOCATION/.oh-my-zsh"
}

# Get Oh My ZSH plugins location
get_omzsh_plugins_location() {
  local OMZSH_LOCATION="$1"

  echo "$OMZSH_LOCATION/custom/plugins"
}

# Get Oh My ZSH themes location
get_omzsh_themes_location() {
  local OMZSH_LOCATION="$1"

  echo "$OMZSH_LOCATION/custom/themes"
}

clone_omz_plugin() {
  local PLUGIN_URL="$1"
  local OMZSH_LOCATION="$2"

  # Check if plugin URL is valid
  if ! [[ "$PLUGIN_URL" == *"/"* ]]; then
    echo "Invalid plugin URL: $PLUGIN_URL"
    return
  fi
  
  local PLUGIN_NAME
  
  PLUGIN_NAME=$(basename "$PLUGIN_URL" .git)

  if ! is_zsh_plugin_cloned "$PLUGIN_NAME" "$(get_omzsh_plugins_location "$OMZSH_LOCATION")"; then
    echo "Cloning plugin $PLUGIN_NAME..."

    git clone --depth 1 "$PLUGIN_URL" "$(get_omzsh_plugins_location "$OMZSH_LOCATION")/$PLUGIN_NAME"
  fi
}

# Install the default Oh My ZSH .zshrc file
install_omzsh_rc_template () {
  local OMZSH_LOCATION="$1"
  local ZSH_CONFIG_LOCATION="$2"

  local ZSHRC_TEMPLATE_LOCATION="$OMZSH_LOCATION/templates/zshrc.zsh-template"

  # Check if .zshrc exists
  if ! [ -f "$ZSH_CONFIG_LOCATION" ]; then
    echo -e "$(cat "${ZSHRC_TEMPLATE_LOCATION}")\nDISABLE_AUTO_UPDATE=true\nDISABLE_UPDATE_PROMPT=true" > "$ZSH_CONFIG_LOCATION"
  fi
}
