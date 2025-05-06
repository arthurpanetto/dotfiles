#!/bin/bash

REPO_DIR="$HOME/dotfiles"

echo "🔁 Removendo symlinks criados..."

# Remove links de ~/.config
for path in "$REPO_DIR"/config/*; do
  target="$HOME/.config/$(basename "$path")"
  [[ -L "$target" ]] && rm -v "$target"
done

# Remove links da home
for path in "$REPO_DIR"/shell/.*; do
  name=$(basename "$path")
  [[ "$name" != "." && "$name" != ".." ]] || continue
  [[ -L "$HOME/$name" ]] && rm -v "$HOME/$name"
done

echo "✅ Symlinks removidos."
