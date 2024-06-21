#!/bin/sh
# https://www.chezmoi.io/user-guide/advanced/install-your-password-manager-on-init/
# Script runs every time the source state is read, so the faster is exits, the less you have to wait

VERSION=2024.6.0 # see https://github.com/bitwarden/clients/releases
INSTALL_DIR="~/.local/bin"

install() {
  case "$(uname -s)" in
    Darwin)
        # commands to install password-manager-binary on Darwin
        brew install bitwarden-cli
        ;;
    Linux)
      curl -sSL -o /tmp/bw.zip https://github.com/bitwarden/clients/releases/download/cli-v"$VERSION"/bw-linux-"$VERSION".zip
      unzip -qq /tmp/bw.zip -d /tmp
      mkdir -p $INSTALL_DIR
      install -m 555 /tmp/bw $INSTALL_DIR/bw
      rm -rf /tmp/bw.zip /tmp/bw
      ;;
    *)
        echo "unsupported OS"
        exit 1
        ;;
  esac
}

# make intelligent decisions about when to install and when not
if ! command -v "bw" > /dev/null; then
  install
elif ! bw --version | grep -q "$VERSION"; then
  install
fi

# register the user if not already (if there's stdout/stdin)
if bw status |grep -q "unauthenticated" &&  -t 1; then
  echo "Login to bitwarden for the first time:"
  bw login --apikey
fi

# unlock if not already unlocked
if bw status |grep -q "locked"; then
  echo "Bitwarden is not unlocked, each template will ask for it's password..."
  echo "Use: export BW_SESSION=\$(bw unlock --raw)"
fi

