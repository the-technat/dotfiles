# dotfiles

My engineering environment as code managed by chezmoi.

Supports `darwin` and some headless-`linux`-distros. The following distros are tested:
- Ubuntu
- Debian
- Rocky Linux
- Fedora
- Alpine
- Amazon Linux 
- Azure Linux

These distros should work no matter if you run them in a VM, a container or using WSL2.

## Install

```console
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
$HOME/.local/bin/chezmoi init --apply the-technat
```

Note: We assume that either this runs somewhere you can enter your password a couple of times or passwordless-sudo is configured.

### Post Configuration (macOS only)

Open Secretive and click through the wizard. The config it requires has already been added, so you can hit "I added it manually". Create an SSH key in Secretive, name it "github" and don't require authentication for it. Copy the path to this key and then create a symlink for commit signing:

```console
ln -sf ~/.ssh/ssh_signing.pub /Users/technat/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/PublicKeys/79312d1e83eec6fad1cd7841358a3ce2453e3c9.pub 
```

This is only required for signing git commits, every other tool will use the key from ssh-agent. Lastly don't forget to add the key as signing and authentication key in your Github account.

<details closed>
<summary>Concepts and details</summary>

## OS Support

As the headline suggests we support `darwin` and headless-`linux`. My idea with this was that I'm primarely using `darwin`-based systems where I'd like chezmoi to manage as much as possible so that I don't have to. This should include desktop tooling, helpers tools and even desktop settings. On the other hand I code regularlary on a remote linux system (e.g a VM in the cloud or a devcontainer). For this purpose chezmoi must be really good at porting over the experience I'm familiar with on my Mac to that remote system without taking too much time to do so and being reliable. That's why I exensively test my dotfiles against many popular linux distros to ensure that whatever OS the remote system has it should work out of the box within minutes.

## Tooling

I got two different package managers per OS. One is the default that's preinstalled on every OS and the other is [mise](https://mise.jdx.dev).

The system package manager is good at installing general tooling. It runs before we put our files in place and ensures a common baseline that we are going to need later. Mise on the other hand is very useful for installing development-specific tools where multiple versions of the same binary might be needed. Mise runs after we put our files in place and installs a handful of development tools that are assumed/used by aliases or have a config in our dotfiles. Any other development tools should be installed when needed.

Note: for macOS I count [homebrew](https://brew.sh) as system package manager as there's no one preinstalled.

## Devcontainers

We skip SSH and Git configs when we can detect that dotfiles are installed in a devcontainer. Devcontainers usually bring their own integrated solution how to authenticate against Git that mostly also relies on the SSH config, so we'd have to either be very specific about which directives we manage or ensure they never conflict.

## SSH

On my Mac I'm a fan of [Secretive](https://github.com/maxgoedjen/secretive) to store my SSH keys in the Security Enclace of my mac. Thus I have configured it's integration in my dotfiles and it's assumed that SSH keys are generated in there.

For remote linux systems there's a script that generates a default SSH key (unprotected) that could be used alongside a default SSH config that might be helpful.

</details>

## New ideas
- What about docker on remote linux?
- What about all the system packages in a devcontainer?
- Test on multiple WSL2 installations
- Do we want to set macOS UI settings?
- Support work machine
- Take inspiration from https://github.com/axinorm/macbook-setup and https://github.com/twpayne/dotfiles
- Simplify SSH key management to function independent on ephemeral / remote machines
