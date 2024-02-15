
# ZSH for Dev Containers (zsh)

A feature that installs ZSH with Oh My ZSH, command history, plugins, and themes.

## Example Usage

```json
"features": {
    "ghcr.io/dbarjs/devcontainer-features/zsh:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| commandHistoryLocation | Location to store command history | string | /commandhistory/ |
| omzPluginList | Space separated list of Oh-My-ZSH custom plugin Git URLs that will be cloned | string | git https://github.com/zsh-users/zsh-autosuggestions https://github.com/zsh-users/zsh-syntax-highlighting https://github.com/agkozak/zsh-z |
| username | The username to install ZSH for, by default uses 'remoteUser' or 'containerUser' from config | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/dbarjs/devcontainer-features/blob/main/src/zsh/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
