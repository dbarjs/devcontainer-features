#!/bin/bash

# Get Oh My ZSH location
get_omzsh_location() {
  local USERLOCATION="$1"

  return "$USERLOCATION/.oh-my-zsh"
}

# Get Oh My ZSH plugins location
get_omzsh_plugins_location() {
  local OMZSH_LOCATION="$1"

  return "$OMZSH_LOCATION/custom/plugins"
}

# Get Oh My ZSH themes location
get_omzsh_themes_location() {
  local OMZSH_LOCATION="$1"

  return "$OMZSH_LOCATION/custom/themes"
}
