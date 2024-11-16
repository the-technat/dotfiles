#!/bin/sh
# https://www.chezmoi.io/reference/configuration-file/hooks/
# this script runs every time the source state is read, so the faster is exits, the less you have to wait

if ! command -v "brew" > /dev/null; then
  case "$(uname -s)" in
    Darwin)
       /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
      ;;
    *)
      echo "Not installing homebrew on non-darwin systems"
      exit 1
      ;;
  esac
fi