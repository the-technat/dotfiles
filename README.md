# dotfiles

My engineering environment as code managed by chezmoi.

Supports `darwin` and headless-`linux`-distros. The following distros are tested:
- Ubuntu
- Debian
- Rocky Linux
- Fedora
- Amazon Linux 
- Azure Linux

These distros should work no matter if you run them in a VM, a container or using WSL2.

## Install

```console
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
$HOME/.local/bin/chezmoi init --apply the-technat
```

**Note**: We assume that either this runs somewhere you can enter your password a couple of times (e.g TTY attached) or passwordless-sudo is pre-configured. This implies that the user we run this for has to exist already.

### Post Configuration (macOS only)

Open Secretive and click through the setup wizard. The config it requires has already been added, so you can click "I Added it Manually". Create an SSH key in Secretive named "github" and choose "don't require authentication" for it. Copy the path to this key to the clipboard and then create a symlink for commit signing:

```console
ln -sf /Users/technat/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/PublicKeys/79312d1e83eec6fad1cd7841358a3ce2453e3c9.pub ~/.ssh/ssh_signing.pub 
```

This is only required for signing git commits, every other tool will use the key from macOS's ssh-agent. The config for git commit signing is managed via dotfiles, but the key location is non-determinstic, hence this symlink. Don't forget to add the key as signing and authentication key in your Github account!

<details closed>
<summary>Concepts and details</summary>

## OS Support

As the headline suggests we support `darwin` and headless-`linux`. My idea with this was that I'm primarely using `darwin`-based systems where I'd like chezmoi to manage all my engineering environment, including desktop tooling. 
On the other hand I would like to be able to code on a remote linux system (e.g a VM in the cloud or a devcontainer) in the same way I do on my Mac. 
For this purpose my dotfiles must be really good at porting over the experience I'm familiar with on my Mac to that remote system without taking too much time to do so and being reliable. 
That's why I exensively test my dotfiles against many popular linux distros to ensure that whatever OS the remote system has it should work out of the box within minutes.

## Permissions

Dotfiles are installed for the user that kicks off the bootstrap. But there are some exceptions where elevated privileges are required:
- to change the default shell for the user 
- to install system-wide packages required by other local dev tooling 
- to install homebrew
- to install code-server systemd wide (only `linux`)

To do so we assume that the bootstraping either has access to passwordless-sudo or is run in a terminal where the password can be entered multiple times during the boostrap (e.g a TTY is attached).

## Tooling

I got two different package managers per OS. One is the default that's preinstalled on every OS and the other is Homebrew. 

The system package manager is good at installing general tooling and dependencies required by Homebrew. 
It runs at the beginning ensuring a common baseline that we are going to need afterwards.

Homebrew runs after the system package manager and installs development-specific tools that don't exist 
in system package managers or where I need a more recent versions than otherwise available. 

The list of tools we install that way is rather small and limited to tools that have a config in my dotfiles 
or tools that are referenced in an alias or similiar. 

Any other development tooling should be installed manually at the time it's needed using it's respective framework (see below for a list of programming languages).

You can see the full list of packages installed in the [home/.chezmoidata/packages.yaml](home/.chezmoidata/packages.yaml) file.

Updates are handeled by the system package manager or homebrew itself. chezmoi may sometimes trigger an update but
in general it's the responsibility of the user to regurarly update tools using the package managers.

### Darwin

For `darwin` I count [homebrew](https://brew.sh) as the system package manager as there's no one 
preinstalled and no other package manager used.

As notes previously already, on Darwin we also install `casks` for development-tasks. Something we won't be doing on linux.

## IDE

I'm using VSCodium as my primary IDE alongside NeoVim for some terminal-based editing. For my `darin`-systems homebrew takes care of installing these IDEs and configuration is part of my dotfiles.

For headless-`linux` there is no homebrew package for VSCodium since this is a desktop-application. In these cases I had great success with [code-server](https://github.com/coder/code-server) as a 1:1 replacement for VSCodium. It's config is also part of the dotfiles and it's installation is done by a script that is executed once in the beginning.

## Terminal

To have a more or less consistent terminal experience and to be productive I use tmux in combination 
with NeoVim to do most stuff. 
This will always be the same no mather the OS. 
There are some things however tmux can't control and that are dependant on the terminal emulator used:

- color theme
- font
- shortcuts to increase/decrease font

On `darwin` these settings can be controlled since we install [ghostty](https://ghostty.org), but on 
linux-based systems you either have to ignore these things or configure them manually if needed. 
In cases where you use ssh into a box this won't apply of course.

Note that the config for ghostty is placed in the proper directory. If you wish to use ghostty on linu too, you can simply install it.

## ZSH

I use zsh on all my systems for concistency. There are three important files:

- `.zshenv`: contains env vars that are loaded everywhere and don't change when reinvoked
- `.zprofile`: contains setup scripts that should only run once, usually tools that export env vars
- `.zshrc`: contains oh-my-zsh and aliases/functions that should be run on every shell invocation

## Devcontainers


We skip SSH and Git configs when we can detect that dotfiles are installed in a devcontainer. Devcontainers usually bring their own integrated solution how to authenticate against Git that mostly also relies on the SSH config, so we'd have to either be very specific about which directives we manage or ensure they never conflict.

We also don't install code-server nor homebrew and tools on devcontainers since they mostly bring their own development tools with them.

So theoretically only the shell configs are placed on a devcontainer. And even the shell configs contain some if-statements to ensure we don't setup things that homebrew would have installed.

## SSH

On `darwin` I'm a fan of [Secretive](https://github.com/maxgoedjen/secretive) to store my SSH keys in the Security Enclace. Thus I have configured it's integration in my dotfiles and it's assumed that SSH keys are generated in there.

For remote linux systems there's a script that generates a default SSH key (unprotected) that could be used alongside a default SSH config that might be helpful.

If you want to extend the ssh config without commiting stuff to the repository, add a new file in `~/.ssh/config.d/`.

## Git

The gitconfig assumes the above SSH setup. Apart from this, you can add custom git config 
to `~/.gitcustom` and it's included without the need to commit something to the repo and thus applying to all machines.

## Container Engine

On `darwin` Homebrew installs [Orbstack](https://orbstack.dev) to use, on headless linux we don't touch this bit since it requires root privileges to install and on many devcontainers there's a docker daemon ready to use.  

## Programming Langugages

### Java

We use sdkman to manage java versions. It's installed and hooked up in zsh automatically.

There is no java version preinstalled using sdkman, install them when needed.

### Python

We use uv to manage python versions. It's installed and hooked up in zsh automatically. 
There might be some python versions installed by homebrew as transitive dependencies from other tools, but we never make us of them directly.

There is no python version preinstalled using uv, install them when needed.

### Node

We use nvm to manage node versions. It's installed and hooked up in zsh automatically. 
Any node version installed by homebrew is a transitive dependency not used directly.

There should be no preinstalled node version installed via nvm, install them when needed.

### Go

The latest version of go is installed and ready to use.

</details>
