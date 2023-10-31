# dotfiles

Managed by [chezmoi](https://chezmoi.io)

## OS Support

Currently it's well tested on Pop OS and Ubuntu Server. Some scripts also consider Amazon Linux, but not all.

Everything that's a static binary works on all OSes out of the box of course.

Maybe one day in the future I'll add support for Arch Linux or extend the stuff to Debian/Rocky, depending on the needs.

## Tools

As much as possible is installed using scripts in the `.chezmoiscripts` dir.

### Scripts

Scripts that install tools must be:
- as platform agnostic as possible (e.g use binaries/curl if possible)
- install pinned versions or only run once and then track lifecycle through package managers
- differentiate between the shell environment and the desktop env -> it must be possible to install all the tooling on a remote server as well
