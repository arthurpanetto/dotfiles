#!/bin/bash
set -e

REPO_DIR="$HOME/dotfiles"

# Instalar Stow se não estiver instalado
if ! command -v stow &>/dev/null; then
  echo "Instalando Stow..."
  sudo pacman -S --needed stow
fi

# Usar Stow para criar symlinks
cd "$REPO_DIR"
stow -v --target="$HOME/.config" config
stow -v --target="$HOME" shell

# Opcional: Reload no Hyprland
if pidof hyprland >/dev/null; then
  echo "Reloading Hyprland..."
  hyprctl reload
fi

echo "✅ Instalação completa!"
