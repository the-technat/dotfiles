# dotfiles-v2

My engineering environment as code managed by chezmoi.

Supports `darwin` and some headless-`linux`, including WSL2. The following linux-distros are tested:
- Ubuntu
- Debian
- Rocky Linux
- CentOS
- Fedora

## Install

```console
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
chezmoi init --apply the-technat/dotfiles-v2
```

Note: We assume that either this runs somewhere you can enter your password a couple of times or passwordless-sudo is configured.

## New ideas
- Support work machine
- Support ephemeral machines
- check race-condition between code and homebrew
- some distros prompt for confirmation to install packages
- reduce DNFs output
- link / modify vscode settings in here too
- Assume default OS terminal (on everything except darwin)
- Use tmux + nvim for editing 
- Take inspiration from https://github.com/axinorm/macbook-setup and https://github.com/twpayne/dotfiles
- Try to avoid using sudo as much as possible
- Simplify SSH key management to function independent on ephemeral / remote machines
- Try to identify devcontainers and differentiate them from other ephemeral machines
