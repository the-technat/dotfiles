# dotfiles

My engineering environment as code managed by chezmoi.

Supports `darwin` and some headless-`linux`-distros. The following distros are tested:
- Ubuntu
- Debian
- Rocky Linux
- Fedora
- Alpine
- Amazon Linux 
- Azure Linux

These distros should work no matter if you run them in a VM, a container or using WSL2.

## Install

```console
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
$HOME/.local/bin/chezmoi init --apply the-technat
```

Note: We assume that either this runs somewhere you can enter your password a couple of times or passwordless-sudo is configured.

### Post Configuration (macOS only)

Open Secretive and click through the wizard. The config it requires has already been added, so you can hit "I added it manually". Create an SSH key in Secretive, name it "github" and don't require authentication for it. Copy the path to this key and then create a symlink for commit signing:

```console
ln -sf /Users/technat/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/PublicKeys/79312d1e83eec6fad1cd7841358a3ce2453e3c9.pub ~/.ssh/ssh_signing.pub
```

This is only required for signing git commits, every other tool will use the key from ssh-agent. Lastly don't forget to add the key as signing and authentication key in your Github account.

## New ideas
- Recheck if dotfiles really work in devcontainers
- Test on multiple WSL2 installations
- Some mise tools fail to install
- Get net-tools and bind-dnsutils and tcpdump to systems
- Do we want to set macOS UI settings?
- Support work machine
- Take inspiration from https://github.com/axinorm/macbook-setup and https://github.com/twpayne/dotfiles
- Simplify SSH key management to function independent on ephemeral / remote machines
- Migrate banana & WALL-E over to new dotfiles repo
