#!/bin/sh
# https://www.chezmoi.io/reference/configuration-file/hooks/
# this script runs every time the source state is read, so the faster is exits, the less you have to wait

## git
if ! command -v "git" > /dev/null; then
  case "$(uname -s)" in
    Darwin)
      xcode-select --install
      ;;
    Linux)
      . /etc/os-release
      case $ID in
        debian|ubuntu|mint)
          export DEBIAN_FRONTEND=noninteractive
          sudo apt -qq -y install git < /dev/null > /dev/null
          ;;
        rocky|fedora|rhel|centos)
          sudo dnf -y install git 
          ;;
        archarm|arch)
          sudo pacman -S --noconfirm git 
          ;;
        *)
          echo -n "unsupported linux distro, install git manually"
          ;;
      esac
    ;;
    *)
      echo "Unknown OS, install git manually"
      exit 1
      ;;
  esac
fi

## zsh
if ! command -v "zsh" > /dev/null; then
  case "$(uname -s)" in
    Darwin)
      echo "zsh is preinstalled on darwin"
      ;;
    Linux)
      . /etc/os-release
      case $ID in
        debian|ubuntu|mint)
          export DEBIAN_FRONTEND=noninteractive
          sudo apt -qq -y install zsh < /dev/null > /dev/null
          ;;
        rocky|fedora|rhel|centos)
          sudo dnf -y install zsh 
          ;;
        archarm|arch)
          sudo pacman -S --noconfirm zsh 
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

## mise
export MISE_INSTALL_PATH=$HOME/.local/bin/mise
if ! command -v "$MISE_INSTALL_PATH" > /dev/null; then
   curl https://mise.run | sh > /dev/null
fi

## homebrew (darwin only)
if ! command -v "brew" > /dev/null; then
  case "$(uname -s)" in
    Darwin)
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"  > /dev/null
      ;;
    *)
      echo "homebrew is currently only installed on Darwin"
      ;;
  esac
fi