#!/bin/sh
# very basic test script that ensures that chezmoi has done most of what we expect

set -e # -e: exit on error
zshPath=$(command -v zsh)
echo $zshPath

## git
# $zshPath -i -c "git config --list"


## nvim

## 