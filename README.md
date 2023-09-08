# dotfiles

Managed by [chezmoi](https://chezmoi.io)

## Tools

As much as possible is installed using scripts in the `.chezmoiscripts` dir.

### Scripts

Scripts that install tools must be:
- as platform agnostic as possible (e.g use binaries/curl if possible)
- install pinned versions or only run once and then track lifecycle through package managers
- differntiate between the shell environment and the desktop env -> it must be possible to install all the tooling on a remote server as well
