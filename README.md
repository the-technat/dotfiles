# dotfiles

Managed by [chezmoi](https://chezmoi.io). Installs everything related to my engineering environment.

Exceptions: VS Code (using settings sync via Github)

## OS Support

Currently it's well tested on various flavors of Ubuntu. Some scripts also consider Amazon Linux, but not all.

Everything that's a static binary works on all OSes out of the box of course.

I'll soon add support for `darwin/arm64` and `darwin/x86_64` to the scripts as well as install homebrew.

## Tools

As much as possible is installed using scripts in the `.chezmoiscripts` dir.

Scripts that install tools are:
- as platform agnostic as possible (e.g use binaries/curl if possible)
- install pinned versions or only run once and then track lifecycle through package managers

## Interactive

Stuff shouldn't prompt for interactive inputs since my engineering environment could also be installed in an ephemeral environment or without a GUI/desktop toolchain. If something needs my interaction (like the bitwarden cli), it should do so conditionally using the `if_desktop` toggle.
