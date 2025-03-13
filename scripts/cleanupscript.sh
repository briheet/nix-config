#!/bin/bash

shopt -s nullglob

# Move PNG files if they exist
if compgen -G "*.png" >/dev/null; then
  mv ./*.png /home/briheet/Pictures/Screenshots/
fi

# Remove swap files if they exist
if ls ~/.local/state/nvim/swap/*.swp 1>/dev/null 2>&1; then
  rm -rf ~/.local/state/nvim/swap/*.swp
fi
