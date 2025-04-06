# dotfiles-v2

My engineering environment as code managed by chezmoi.

This will be my new dotfiles repo. I created a new one since there will be so many changes it's hard to track and be backwards-compatible.

## New ideas
- Use mise to install dev tooling
- Support work machine
- Support ephemeral machines
- Support bash and zsh, remove oh-my-* frameworks (to keep the shell down to the essentials)
- Assume default OS terminal
- Use tmux + nvim for editing 
- Remove homebrew (it's too scary to me)
- Lazy-load packages (or don't install them at all in the beginning) 
- Take inspiration from https://github.com/axinorm/macbook-setup and https://github.com/twpayne/dotfiles
- Try to avoid using sudo as much as possible
- Simplify SSH key management to function independent on ephemeral / remote machines
- Try to identify devcontainers and differentiate them from other ephemeral machines
