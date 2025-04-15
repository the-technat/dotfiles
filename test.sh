#!/bin/sh
# very basic test script that ensures that chezmoi has done most of what we expect

set -e # -e: exit on error

## zsh
zshPath=$(command -v zsh)
if [ -n "$zshPath" ]; then
  echo "zsh not found"
fi

## git
# $zshPath -i -c "git config --list"


## nvim

## 