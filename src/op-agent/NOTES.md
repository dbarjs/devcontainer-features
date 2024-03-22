## Add support for Git commit signing

> All the steps below are based on the [1Password documentation](https://developer.1password.com/docs/ssh/git-commit-signing/) and the [1Password SSH docs](https://developer.1password.com/docs/ssh).

### Step 1: Configure your SSH key with 1Password and your Git account

You must have a SSH key configured with 1Password and register it on your Git account, like GitHub, GitLab, or Azure DevOps. For this, follow the steps of the [1Password SSH docs](https://developer.1password.com/docs/ssh/git-commit-signing).


### Step 2: Configure your `~/.gitconfig` file with the snippet below

```bash
[user]
  name = <your-name>
  email = <your-email>
  signingkey = <your-public-key>

[gpg]
  format = ssh

[gpg "ssh"]
  program = "/opt/1Password/op-ssh-sign"

[commit]
  gpgsign = true
```

You can also get a [custom snippet generated for 1Password for your SSH Key](Configure your `~/.gitconfig` file).

### Step 3: Disable `op-ssh-sign` agent on your devcontainer (extra)

> [!TIP] This is step is not necessary if you are using this feature on your devcontainer.

The Ubuntu and Linux distributions don't allow the devcontainer to access the 1Password agent with the `/opt/1Password/op-ssh-sign` program. So you need to disable this agent on your devcontainer. The VSCode agent will handle the SSH signing.

> [!IMPORTANT] The 1Password has a better integration support with the WSL, so, read this [article](https://developer.1password.com/docs/ssh/integrations/wsl) to configure the SSH agent on your WSL.

With the devcontainer terminal open, edit the `~/.gitignore` file and remove the following line:

```bash
[gpg "ssh"]
  program = "/opt/1Password/op-ssh-sign"
```

> [!CAUTION] It is important to not remove this program config on your local machine, only on the devcontainer.

> [!NOTE] The VSCode must automatically copy the `~/.gitconfig` file to the devcontainer, but if it doesn't, you should check if `dev.containers.copyGitConfig` is set to `true` in your `settings.json` file. Read more about the [VSCode devcontainer settings](https://code.visualstudio.com/docs/remote/containers-advanced#_settings).

## Add support for custom Git credentials for a whole devcontainer

The signature (configured on your `~/.gitconfig` file) is available for all your Git repositories, including the ones on your devcontainer. But, if you need to use a different Git account for a specific repository, you can create a custom `~/.gitconfig` file to be used in a whole devcontainer.

### Step 1: Create a custom `~/.gitconfig` file in your devcontainer

In your devcontainer, create and open the file `/workspaces/.gitconfig` and add the following snippet:

```bash
[user]
  name = <your-name>
  email = <your-email>
  signingkey = <your-public-key>
```

> [!TIP] You can use `code /workspaces/.gitconfig` to open the file in the VSCode editor.

### Step 2: Configure your `~/.gitconfig` file to include the custom file when you are in the devcontainer

In the *local* `~/.gitconfig` file, add the following snippet:

```bash
...

[includeIf "gitdir:/workspaces/"]
  path = /workspaces/.gitconfig
```

### Step 3: Rebuild your devcontainer

After update the local `~/.gitconfig` file, you need to rebuild your devcontainer to apply the changes (the VSCode will automatically copy the `~/.gitconfig` file to the devcontainer). You can do this by running the `Dev Containers: Rebuid Container` command in the VSCode command palette.

> [!TIP] Or, you can simply update the `~/.gitconfig` of your devcontainer to apply the changes (no need to rebuild or restart the devcontainer). This is useful for testing purposes. But remember to update the local `~/.gitconfig` file to keep the changes (the changes will be lost if you rebuild the devcontainer).

### Extra: Use the custom `/workspaces/.gitconfig` file for a custom matching pattern

> [!IMPORTANT] Make sure to write the right matching pattern url for your repository, this examples are only for SSH urls.

> [!TIP] Use the command `git config --get remote.origin.url` to get the url of your repository, or the command `git rev-parse --show-toplevel` to get the right location pattern.

Replace the `includeIf` config with the suggestion bellow: 

#### For GitHub repositories:

```bash
[includeIf "hasconfig:remote.*.url:git@github.com/**"]
```

For specific organizations:

```bash
[includeIf "hasconfig:remote.*.url:git@github.com:<organization-slug>/**"]
```

#### For Azure DevOps repositories:

```bash
[includeIf "hasconfig:remote.*.url:git@ssh.dev.azure.com:v3/**"]
```

For specific organizations:

```bash
[includeIf "hasconfig:remote.*.url:git@ssh.dev.azure.com:v3/<organization-slug>/**"]
```

#### For a custom directory

Use a custom directory pattern:

```bash
[includeIf "gitdir:/workspaces/<custom-directory>"]
  path = /workspaces/.gitconfig
```

#### Need more specific patterns?

Read Git conditional includes [documentation](https://git-scm.com/docs/git-config#_conditional_includes) for more information.

## Git authentication: add your Git credentials to specific domains

> [!IMPORTANT] Before you start, make sure you have already configured your SSH key with 1Password and your Git account following the [1Password SSH docs](https://developer.1password.com/docs/ssh/get-started).


### Create a custom `~/.ssh/config` file in your local machine

Edit the `~/.ssh/config` file and add the following snippet, adding your domain and the path to your private key:

```bash
IdentityAgent ~/.1password/agent.sock
	HashKnownHosts yes
```

> [!INFO] The `HashKnownHosts` option is only set to `yes` to keep the `Host *` configuration when this feature script clean the `IdentityAgent` configuration.

### Add custom host to your `~/.ssh/config` file

With this tip, you can define specific Git credentials for a SSH domain (like GitHub, GitLab, or Azure DevOps) for the 1Password show the exact SSH key in the [Authorization Prompt](https://developer.1password.com/docs/ssh/agent/compatibility#git-autofetch), instead of get a lot of keys to choose from.

1. Open the 1Password and [download your public key](https://developer.1password.com/docs/ssh/agent/advanced#create-an-ssh-agent-config-file), and save it in your `~/.ssh` directory with a custom name, like `github_key_rsa.pub` or `azure_key_rsa.pub`.

2. Edit the `~/.ssh/config` file and add the following snippet, adding your domain and the path to your public key:

```bash
Host <domain>
	IdentityFile <path-to-your-private-key>
	IdentitiesOnly yes
```

Example for Azure DevOps: 

```bash
Host *
	IdentityAgent ~/.1password/agent.sock
	HashKnownHosts yes

Host ssh.dev.azure.com
	IdentityFile ~/.ssh/azure_key_rsa.pub
	IdentitiesOnly yes
```

Now, when you try to clone a repository from Azure DevOps, the 1Password will only show the authentication prompt for the Azure key.
