# dotfiles

Managed by [chezmoi](https://chezmoi.io)

## Tools

As much as possible is installed using scripts in the `.chezmoiscripts` dir. But since we don't manage Gnome (for most parts), graphical software is sometimes installed via other mechanisms.

For example the following tools are installed via the PopOS Shop:

- flameshot
- ungoogled-chromium
- kitty
- vscode

### Scripts

Scripts that install tools must be:
- as platform agnostic as possible (e.g use binaries/curl if possible)
- install pinned versions
