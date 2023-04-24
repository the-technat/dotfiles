#!/bin/bash
# Install script for GH codespaces

### Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform terraform-ls -y

### Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm ./get_helm.sh
helm repo add argo https://argoproj.github.io/argo-helm

### K3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

### Telepresence
sudo curl -fL https://app.getambassador.io/download/tel2/linux/amd64/latest/telepresence -o /usr/local/bin/telepresence
sudo chmod a+x /usr/local/bin/telepresence

### Docker
# should already be installed 

### Go
# should already be installed

## Link config files
ln -sf /workspaces/.codespaces/.persistedshare/dotfiles/git/.gitconfig $HOME/.gitconfig
ln -sf /workspaces/.codespaces/.persistedshare/dotfiles/zsh/.zshrc $HOME/.zshrc
ln -sf /workspaces/.codespaces/.persistedshare/dotfiles/zsh/.zsh-custom $HOME/.zsh-custom
ln -sf /workspaces/.codespaces/.persistedshare/dotfiles/systemd/.config/environment.d $HOME/.config/environment.d