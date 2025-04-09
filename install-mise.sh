#!/bin/sh
# https://www.chezmoi.io/reference/configuration-file/hooks/
# this script runs every time the source state is read, so the faster is exits, the less you have to wait

if ! command -v "mise" > /dev/null; then
  curl https://mise.run | sh
fi