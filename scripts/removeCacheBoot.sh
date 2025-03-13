#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo." >&2
  exit 1
fi

# Confirmation prompt
read -p "This will collect garbage and rebuild the system. Proceed? (y/N): " confirm
case "$confirm" in
[yY][eE][sS] | [yY])
  echo "Starting garbage collection..."
  nix-collect-garbage -d

  echo "Rebuilding system configuration..."
  nixos-rebuild boot

  echo "All tasks completed successfully."
  ;;
*)
  echo "Operation cancelled."
  exit 0
  ;;
esac
