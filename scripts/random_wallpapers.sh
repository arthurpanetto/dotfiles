#!/usr/bin/env bash

# Configurações
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"
WALLPAPER_DIR="/home/yuuki/Wallpapers"
MONITOR="HDMI-A-1"  # Nome correto do monitor conforme seu config

# Gerar lista de wallpapers pré-carregados
WALLPAPERS=($(grep -E "^preload = " "$CONFIG_FILE" | cut -d' ' -f3))

# Selecionar wallpaper aleatório
SELECTED_WALLPAPER=${WALLPAPERS[$RANDOM % ${#WALLPAPERS[@]}]}

# Aplicar o wallpaper
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$SELECTED_WALLPAPER"
hyprctl hyprpaper wallpaper "$MONITOR,$SELECTED_WALLPAPER"
