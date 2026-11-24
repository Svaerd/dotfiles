#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

mkdir -p "$CONFIG_DIR"

configs=(
  fastfetch
  fish
  hypr
  kitty
  lazygit
  niri
  noctalia
  nvim
  opencode
  starship.toml
  tmux
  warp-terminal
  yazi
)

for item in "${configs[@]}"; do
  ln -sfn "$DOTFILES_DIR/$item" "$CONFIG_DIR/$item"
done

ln -sfn "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

echo "Linked ${#configs[@]} configs and .zshrc from $DOTFILES_DIR"
