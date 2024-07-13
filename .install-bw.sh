#!/bin/sh
# https://www.chezmoi.io/user-guide/advanced/install-your-password-manager-on-init/
# Script runs every time the source state is read, so the faster is exits, the less you have to wait

VERSION=1.11.1 # see https://github.com/doy/rbw/releases
INSTALL_DIR="$HOME/.local/bin"

installBW() {
  case "$(uname -s)" in
    Darwin)
      # commands to install password-manager-binary on Darwin
      brew install bitwarden-cli
      ;;
    Linux)
      if ! command -v "unzip" > /dev/null; then
        sudo apt install unzip -y 2>&1 /dev/null
      fi
      curl -fsSL -o /tmp/rbw.tar.gz https://github.com/doy/rbw/releases/download/$VERSION/rbw_"$VERSION"_linux_amd64.tar.gz
      tar -C /tmp -xzf /tmp/rbw.tar.gz
      mkdir -p $INSTALL_DIR
      install -m 555 /tmp/rbw $INSTALL_DIR
      install -m 555 /tmp/rbw-agent $INSTALL_DIR
      rm -rf /tmp/bw.zip /tmp/rbw
      ;;
    *)
      echo "unsupported OS"
      exit 1
      ;;
  esac
}

# make intelligent decisions about when to install and when not
if ! command -v "rbw" > /dev/null; then
  installBW
elif ! rbw --version | grep -q "$VERSION"; then
  installBW
fi

# register the user if not already (if there's stdout/stdin)
if rbw status |grep -q "unauthenticated"; then
  echo "Login to bitwarden for the first time:"
  rbw login --apikey
fi

# unlock if not already unlocked
if ! rbw status |grep -q "unlocked"; then
  echo "Bitwarden is not unlocked, each template will ask for the master password..."
  echo "Use: export BW_SESSION=\$(rbw unlock --raw)"
fi

