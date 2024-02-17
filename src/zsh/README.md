
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
| commandHistoryLocation | Location to store command history | string | /commandhistory |
| omzPluginCloneList | Space separated list of Oh-My-ZSH custom plugin Git URLs that will be cloned | string | https://github.com/zsh-users/zsh-autosuggestions https://github.com/zsh-users/zsh-syntax-highlighting https://github.com/agkozak/zsh-z |
| zshPluginList | Space separated list of ZSH plugin names that will be installed | string | git zsh-autosuggestions zsh-syntax-highlighting zsh-z |
| configureCommandHistory | Whether to configure ZSH to use the command history feature | string | true |
| restoreZshConfig | Whether to overwrite the ZSH configuration file with the default OMZ configuration | string | true |
| installSpaceshipTheme | Whether to install the Spaceship theme | string | true |
| username | The username to install ZSH for, by default uses 'remoteUser' or 'containerUser' from config | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/dbarjs/devcontainer-features/blob/main/src/zsh/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
