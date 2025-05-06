#!/bin/bash
set -eo pipefail

# Cores para feedback
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_DIR="$HOME/dotfiles"  # Caminho absoluto para o diretório dotfiles

# Verificar se o diretório do repositório existe
if [[ ! -d "$REPO_DIR" ]]; then
  echo -e "${RED}Erro: Diretório $REPO_DIR não encontrado!${NC}" >&2
  exit 1
fi

# Instalar Stow se necessário
install_stow() {
  if ! command -v stow &>/dev/null; then
    echo -e "${YELLOW}Instalando GNU Stow...${NC}"
    
    if command -v pacman &>/dev/null; then
      sudo pacman -S --needed --noconfirm stow
    elif command -v apt &>/dev/null; then
      sudo apt update && sudo apt install -y stow
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y stow
    else
      echo -e "${RED}Erro: Gerenciador de pacotes não suportado!${NC}" >&2
      exit 1
    fi
  fi
}

# Criar backup de arquivos existentes
backup_existing() {
  local backup_dir="$REPO_DIR/backup/$(date +'%Y%m%d_%H%M%S')"
  mkdir -p "$backup_dir"
  
  echo -e "${YELLOW}⏳ Criando backup em $backup_dir...${NC}"
  
  # Backup para .config
  for item in "$REPO_DIR"/config/*; do
    local name=$(basename "$item")
    local target="$HOME/.config/$name"
    
    if [[ -e "$target" && ! -L "$target" ]]; then
      echo -e "${YELLOW}Arquivo existente: $target. Deseja sobrescrever? (s/n)${NC}"
      read -r answer
      if [[ "$answer" != "s" ]]; then
        echo -e "${RED}Operação de backup cancelada.${NC}"
        continue
      fi
      cp -vr "$target" "$backup_dir/config_$name"
    fi
  done
  
  # Backup para arquivos da home
  for item in "$REPO_DIR"/shell/.*; do
    local name=$(basename "$item")
    [[ "$name" == "." || "$name" == ".." ]] && continue
    
    local target="$HOME/$name"
    if [[ -e "$target" && ! -L "$target" ]]; then
      echo -e "${YELLOW}Arquivo existente: $target. Deseja sobrescrever? (s/n)${NC}"
      read -r answer
      if [[ "$answer" != "s" ]]; then
        echo -e "${RED}Operação de backup cancelada.${NC}"
        continue
      fi
      cp -v "$target" "$backup_dir/home_$name"
    fi
  done
}

# Aplicar configurações
apply_configs() {
  echo -e "${YELLOW}🔗 Criando symlinks...${NC}"
  
  # Usar o caminho absoluto para o diretório de config
  cd "$REPO_DIR"

  # Stow para .config com o diretório configurado
  for package in "$REPO_DIR/config"/*; do
    if [[ -d "$package" ]]; then
      name=$(basename "$package")
      echo -e "${YELLOW}🔗 Aplicando pacote: $name${NC}"
      stow -v --target="$HOME/.config" --dir="$REPO_DIR/config" "$name"  # Corrigido para usar o diretório correto
    fi
  done
  
  # Stow para arquivos da home
  stow -v --ignore='README\.md|LICENSE' --target="$HOME" --dir="$REPO_DIR/shell" shell
  
  # Hyprland reload se estiver rodando
  if pidof hyprland >/dev/null; then
    echo -e "${YELLOW}🔄 Recarregando Hyprland...${NC}"
    hyprctl reload
  fi
}

main() {
  install_stow
  backup_existing
  apply_configs
  
  echo -e "\n${GREEN}✅ Instalação concluída com sucesso!${NC}"
  echo -e "Backups salvos em: ${YELLOW}$REPO_DIR/backup/${NC}"
}

main

