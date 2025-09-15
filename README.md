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

Note: We assume that either this runs somewhere you can enter your password a couple of times or passwordless-sudo is configured. This implies that the user we want dotfiles for also exists already.

### Post Configuration (macOS only)

Open Secretive and click through the wizard. The config it requires has already been added, so you can hit "I Added it Manually". Create an SSH key in Secretive, name it "github" and don't require authentication for it. Copy the path to this key and then create a symlink for commit signing:

```console
ln -sf ~/.ssh/ssh_signing.pub /Users/technat/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/PublicKeys/79312d1e83eec6fad1cd7841358a3ce2453e3c9.pub 
```

This is only required for signing git commits, every other tool will use the key from ssh-agent. Lastly don't forget to add the key as signing and authentication key in your Github account.

<details closed>
<summary>Concepts and details</summary>

## OS Support

As the headline suggests we support `darwin` and headless-`linux`. My idea with this was that I'm primarely using `darwin`-based systems where I'd like chezmoi to manage all my engineering environment, including desktop tooling. On the other hand I code regularlary on a remote linux system (e.g a VM in the cloud or a devcontainer). For this purpose chezmoi must be really good at porting over the experience I'm familiar with on my Mac to that remote system without taking too much time to do so and being reliable. That's why I exensively test my dotfiles against many popular linux distros to ensure that whatever OS the remote system has it should work out of the box within minutes.

## Permissions

Dotfiles are installed for the user that kicks off the bootstrap. But there are some exceptions where elevated privileges are required:
- to change the default shell for the user
- to install system-wide packages 

To do so we assume that the bootstraping either has access to passwordless-sudo or is run in a terminal where the password can be entered multiple times during the boostrap.

## Styling / Terminal experience

To have a more or less consistent terminal experience and to be really productive I use tmux in combination 
with neovim to do most stuff. 
This will always be the same no mather the OS. 
There are some things however tmux can't control and that are dependant on the terminal emulator used:

- color theme
- font
- shortcuts to increase/decrease font

On `darwin` these settings can be controlled since we install [ghostty](https://ghostty.org), but on 
linux-based systems you either have to ignore these things or configure them manually if needed. 
In cases where you use ssh into a box this won't apply of course.

## Tooling

I got two different package managers per OS. One is the default that's preinstalled on every OS and the other is Homebrew. 

The system package manager is good at installing general tooling and dependencies required by Homebrew. 
It runs at the beginning ensuring a common baseline that we are going to need afterwards.
Homebrew runs after the system package manager and installs development-specific tools that don't exist 
in system package managers or where I need a more recent versions than otherwise available. 
The list of tools we install that way is rather small and limited to tools that have a config in my dotfiles 
or tools that are referenced in an alias or similiar. 
Any other development tooling should be installed manually at the time it's needed.

You can see the full list of packages installed in the [home/.chezmoidata/packages.yaml](home/.chezmoidata/packages.yaml) file.

Updates are handeled by the system package manager or homebrew itself. chezmoi may sometimes trigger an update but
in general it's the responsibility of the user to regurarly update tools using the package managers.

### Alpine Specials

Homebrew isn't installed and supported on alpine and thus skipped. Install tools manually if needed.

### Darwin

For `darwin` I count [homebrew](https://brew.sh) as the system package manager as there's no one 
preinstalled and no other package manager used.

## Devcontainers

We skip SSH and Git configs when we can detect that dotfiles are installed in a devcontainer. Devcontainers usually bring their own integrated solution how to authenticate against Git that mostly also relies on the SSH config, so we'd have to either be very specific about which directives we manage or ensure they never conflict.

## SSH

On `darwin` I'm a fan of [Secretive](https://github.com/maxgoedjen/secretive) to store my SSH keys in the Security Enclace. Thus I have configured it's integration in my dotfiles and it's assumed that SSH keys are generated in there.

For remote linux systems there's a script that generates a default SSH key (unprotected) that could be used alongside a default SSH config that might be helpful.

If you want to extend the ssh config without commiting stuff to the repository, add a new file in `~/.ssh/config.d/`.

## Git

The gitconfig assumes the above SSH setup. Apart from this, you can add custom git config 
to `~/.gitcustom` and it's included without the need to commit something to the repo and thus applying to all machines.

</details>
