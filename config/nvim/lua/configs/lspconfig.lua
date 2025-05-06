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
