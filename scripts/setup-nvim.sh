#!/bin/bash

# Instalação de dependências
echo "Instalando dependências do sistema..."
sudo pacman -S --needed --noconfirm neovim ripgrep gcc make clang lldb
yay -S --noconfirm nerd-fonts-jetbrains-mono

# Limpeza de configurações anteriores
echo "Limpando configurações anteriores..."
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim

# Clonar NvChad starter
echo "Instalando NvChad..."
git clone https://github.com/NvChad/starter ~/.config/nvim

# Criar pastas necessárias
mkdir -p ~/.config/nvim/lua/plugins/configs
mkdir -p ~/.config/nvim/lua/configs

# Configuração do plugin Mason com LSPs
echo "Configurando Mason e LSPs..."
cat > ~/.config/nvim/lua/plugins/init.lua << 'EOF'
return {
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "clang-format",
        "cpptools",
        "codelldb",
      },
    },
  },
}
EOF

# LSP para C/C++
cat > ~/.config/nvim/lua/configs/lspconfig.lua << 'EOF'
local lsp_defaults = require("nvchad.configs.lspconfig")
local on_attach = lsp_defaults.on_attach
local capabilities = lsp_defaults.capabilities

local lspconfig = require("lspconfig")

lspconfig.clangd.setup({
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    vim.keymap.set("n", "<leader>cr", "<cmd>ClangdSwitchSourceHeader<cr>", { buffer = bufnr, desc = "Alternar entre header/source" })
  end,
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=never",
    "--query-driver=/usr/bin/clang",
  },
  filetypes = { "c", "cpp", "objc", "objcpp" },
})
EOF

# Autoformatação com conform.nvim
cat > ~/.config/nvim/lua/configs/conform.lua << 'EOF'
local options = {
  formatters_by_ft = {
    c = { "clang_format" },
    cpp = { "clang_format" },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
EOF

# Mapeamentos
cat > ~/.config/nvim/lua/mappings.lua << 'EOF'
require "nvchad.mappings"

local map = vim.keymap.set

map("n", "<leader>rr", function()
  local ft = vim.bo.filetype
  local cmd = (ft == "cpp") and "g++ -std=c++20" or "gcc -std=c17"
  local output = vim.fn.expand("%:r")
  vim.cmd(":!" .. cmd .. " % -o " .. output .. " && ./" .. output)
end, { desc = "Compilar e executar" })

map("n", "<leader>db", function()
  local output = vim.fn.expand("%:r")
  vim.cmd(":TermExec cmd='lldb " .. output .. "'")
end, { desc = "Debug com LLDB" })

map("n", "<leader>fm", ":Format<CR>", { desc = "Formatar arquivo" })

map("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "Alternar header/source" })
EOF

echo "----------------------------------------"
echo "Configuração concluída com sucesso!"
echo "Ao abrir o Neovim pela primeira vez:"
echo "1. Os LSPs serão instalados automaticamente"
echo "2. Configure um tema com <Space>th"
echo "3. Atalhos disponíveis:"
echo "   - <leader>rr: Compilar e executar"
echo "   - <leader>fm: Formatar código"
echo "   - <leader>db: Debug com LLDB"
echo "   - <leader>ch: Alternar entre header/source"
echo "----------------------------------------"

