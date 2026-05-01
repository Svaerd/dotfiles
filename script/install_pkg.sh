#!/bin/bash
packages=(
  bat
  btop
  neovim
  cliphist
  cmake
  fastfetch
  fd
  fzf
  gtrash-bin
  gthumb
  kitty
  keyd
  kdeconnect
  lazygit
  lua
  npm
  ripgrep
  wl-clipboard
  zoxide
  yazi
  steam
  starship
  vesktop
  zapzap
  fprintd
  warp-terminal-bin
  obsidian
)

for package in "${packages[@]}"; do
  yay -S --noconfirm --needed "${package}"
done
