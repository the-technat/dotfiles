#!/bin/bash
# requirements: brew, repo cloned

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_TOOLS=false

# environment variables
# apply to entire systemd/user session
ln -sf ${BASEDIR}/environment.d ~/.config

if  $INSTALL_TOOLS
then
  # zsh
  sudo apt install zsh -y
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  # git
  brew install git

  # vim
  brew install vim

  # gpg
  sudo apt install pcscd gnupg-agent gnupg2 scdaemon -y

  # kitty
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  sudo update-alternatives --config x-terminal-emulator # select the existing number

  # helm
  brew install helm
  helm repo add argo https://argoproj.github.io/argo-helm

  # kubectl
  brew install kubectl

  # telepresence
  sudo curl -fL https://app.getambassador.io/download/tel2/linux/amd64/latest/telepresence -o /usr/local/bin/telepresence
  sudo chmod a+x /usr/local/bin/telepresence

  # terraform
  brew install terraform terraform-ls
fi

# zsh
ln -sf ${BASEDIR}/zshrc ~/.zshrc
ln -sf ${BASEDIR}/zsh-custom ~/.oh-my-zsh

# kitty
ln -sf ${BASEDIR}/kitty ~/.config

# vim
ln -sf ${BASEDIR}/vimrc ~/.vimrc
ln -sf ${BASEDIR}/vim/ ~/.vim

# ssh
ln -sf ${BASEDIR}/sshconfig ~/.ssh/config
ln -sf ${BASEDIR}/sshkey ~/.ssh/id_yubikey

# git
ln -sf ${BASEDIR}/gitconfig ~/.gitconfig

# gpg
ln -sf ${BASEDIR}/gpg ~/.gpg
