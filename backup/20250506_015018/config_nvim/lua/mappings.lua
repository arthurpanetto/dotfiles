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
