#!/bin/sh
# https://www.chezmoi.io/reference/configuration-file/hooks/
# this script runs every time the source state is read, so the faster is exits, the less you have to wait

if ! command -v "zsh" > /dev/null; then
  case "$(uname -s)" in
    Darwin)
      echo "zsh is default on darwin"
      ;;
    Linux)
      . /etc/os-release
      case $ID in
        debian|ubuntu|mint)
          sudo apt install zsh -y
          ;;
        fedora|rhel|centos)
          sudo dnf install zsh -y
          ;;
        *)
          echo -n "unsupported linux distro, install zsh manually"
          ;;
      esac
    ;;
    *)
      echo "Unknown OS, install zsh manually"
      exit 1
      ;;
  esac
fi