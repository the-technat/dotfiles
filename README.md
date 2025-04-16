# dotfiles-v2

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
$HOME/.local/bin/chezmoi init --apply the-technat/dotfiles-v2
```

Note: We assume that either this runs somewhere you can enter your password a couple of times or passwordless-sudo is configured.

## New ideas
- Check if VSCode settings are applied corretly
- Do we want to set macOS UI settings?
- Support work machine
- Support ephemeral machines
- Assume default OS terminal (on everything except darwin)
- Use tmux + nvim for editing 
- Take inspiration from https://github.com/axinorm/macbook-setup and https://github.com/twpayne/dotfiles
- Simplify SSH key management to function independent on ephemeral / remote machines
- Try to identify devcontainers and differentiate them from other ephemeral machines (deal with their git/ssh magic)
- Migrate banana & WALL-E over to new dotfiles repo
