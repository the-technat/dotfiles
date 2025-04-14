# dotfiles-v2

My engineering environment as code managed by chezmoi.

Supports `darwin` and headless-`linux`, including WSL2.

## Install

```console
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
chezmoi init --apply the-technat/dotfiles-v2
```

Note: We assume that either this runs somewhere a TTY is attached or passwordless-sudo is configured (as some scripts might use sudo to do stuff).

## New ideas
- Move ensure-deps.sh to before scripts
- Use mise to install dev tooling
- Support work machine
- Support ephemeral machines
- Assume default OS terminal (on everything except darwin)
- Use tmux + nvim for editing 
- Remove homebrew (it's too scary to me)
- Lazy-load packages (or don't install them at all in the beginning) 
- Take inspiration from https://github.com/axinorm/macbook-setup and https://github.com/twpayne/dotfiles
- Try to avoid using sudo as much as possible
- Simplify SSH key management to function independent on ephemeral / remote machines
- Try to identify devcontainers and differentiate them from other ephemeral machines
