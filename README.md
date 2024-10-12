# dotfiles

My engineering environment as code managed by [chezmoi](https://chezmoi.io). 

## Scope

My main computers are Mac's running either Intel or Apple Silicon. chezmoi is designed to configure the engineering part of my mac by installing all desktop and cli tools I need for coding, configuring my shell with colors and aliases as well as injecting credentials into some of the tools. It's not desinged to configure my Mac's in general, do basic settings and get productivity tools like a clipboard manager or a VPN client. This is still manual work.

For various side-usages chezmoi can also configure linux systems that are based on `amd64` arch. There we skip all the desktop tools and don't inject any credentials since these linux systems are mostly remote systems where we don't want long-living credentials. If we need credentials, bring them along form your mac (agent-forwarding and the like).

### Exceptions

Since the world isn't perfectly as code, some exceptions to my "as-code" workflow exist:

- VS Code Settings are synced via Github Settings Sync

## Usage

chezmoi is the first and only tool I install manually using this command:

```console
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin init --apply the-technat
```

A note for MacOS: before you can use chezmoi it will prompt you for the installation of XCode command line tools, do that and then rerun chezmoi

## Concepts

### Tools

Tools are installed using [homebrew](https://brew.sh). This has the benefit that updating the tools is as simple as running a `brew upgrade` and that I can also easily install desktop tools on Mac. I'm still a bit sceptical about the security of homebrew, but since it has almost 100% adoption in the Mac world, it's a no-brainer to still choose it.

Homebrew currently doesn't support `arm64`-based linux distros, but we can live with that.

### Git Auth

My dotfiles setup git to use the github-cli for authentication against Github. On first use you need to sign-in using a device-code.

### SSH

There is a script that generates a ssh-key on first run, tied to this host. The key is already setup in git for commit signing and for use with ssh. The only thing left is to add the key to your github account (or wherever you want to use it).

