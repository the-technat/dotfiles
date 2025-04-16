#!/usr/bin/env zsh
# very basic test script that ensures that chezmoi has done most of what we expect
set -e # -e: exit on error
zshPath=$(command -v zsh)

## zsh
zsh -i -c "echo hello"

## git
gitMail=$(zsh -i -c "git config --global user.email")
if [[ ! $gitMail =~ "technat.ch" ]]; then
  echo "git config has not been set properly"
  exit 1
fi

## nvim
zsh -i -c "nvim --version"

## check some aliases 
zsh -i -c "command -v ghh"
zsh -i -c "command -v ssh"
zsh -i -c "command -v vim"

## mise
zsh -i -c "mise --version"