# dotfiles

My engineering environment as code managed by [chezmoi](https://chezmoi.io). 

## Scope

My main computers are Mac's running either Intel or Apple Silicon. chezmoi is designed to configure the engineering part of my mac by installing all desktop and cli tools I need for coding, configuring my shell with colors and aliases as well as injecting credentials into some of the tools. It's not desinged to configure my Mac's in general, do basic settings and get productivity tools like a clipboard manager or backup software to work. This is still manual work.

For various side-usages chezmoi can also configure linux systems. There we skip all the desktop tools and don't inject any credentials since these linux systems are mostly remote systems where we don't want long-living credentials. If we need credentials, bring them along form your mac (agent-forwarding and the like).

### Exceptions

Since the world isn't perfectly as code, some exceptions to my "as-code" workflow exist:

- VS Code Settings are synced via Github Settings Sync

## Usage

chezmoi is the first and only tool I install manually using these commands:

```console
# the default location for chezmoi is not in my PATH, so we install to another location
sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin 
chezmoi init --apply the-technat
```

A note for MacOS: before you can use chezmoi it will prompt you for the installation of XCode command line tools, do that and then rerun chezmoi again.

## Concepts

### Tools

Tools are installed using [homebrew](https://brew.sh). This has the benefit that updating the tools is as simple as running a `brew upgrade` and that I can also easily install desktop tools on Mac. I'm still a bit sceptical about the security of homebrew, but since it has almost 100% adoption in the Mac world, it's a no-brainer to still choose it.

On Linux we use the distro's respective package manager to install tools we need.

### SSH

For Mac OS: there's an app called [Secretive](https://github.com/maxgoedjen/secretive) that is responsible for holding RSA keys in the Secure Enclave of your Mac. 
The tool is already integrated into your ssh-agent/client. Just start generating secrets and add them to wherever you want, they will automatically be available in your ssh-agent. Note that these secrets won't survive a reinstalltion of MacOS and can't be transfered to another Mac.

If you want to use git commit signing, symlink the pubkey you want to use to `~/.ssh/ssh_signing.pub` so that git can find it. No other manual actions are needed.

For linux: the ssh-agent is started by oh-my-zsh but otherwise nothing has been generated/configured.

### Containers

Mac OS uses [colima](https://github.com/abiosoft/colima) to run containers. A default instance is automatically configured and started. Use templates to start more instances with different configurations.

### Git

Git config is only applied on Mac OS as some linus use-cases bring their own gitconfig with them.
