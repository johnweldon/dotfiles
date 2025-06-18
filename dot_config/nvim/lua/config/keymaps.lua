-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Claude Max optimized keymaps for Avante
map("n", "<leader>aa", function()
  require("avante.api").ask()
end, { desc = "Claude Max: Ask" })
map("v", "<leader>aa", function()
  require("avante.api").ask()
end, { desc = "Claude Max: Ask with selection" })
map("n", "<leader>ar", function()
  require("avante.api").refresh()
end, { desc = "Claude Max: Refresh" })
map("n", "<leader>ae", function()
  require("avante.api").edit()
end, { desc = "Claude Max: Edit" })
map("v", "<leader>ae", function()
  require("avante.api").edit()
end, { desc = "Claude Max: Edit selection" })

-- Additional Claude Max workflow keymaps
map("n", "<leader>ac", "<cmd>AvanteClear<cr>", { desc = "Claude Max: Clear history" })
map("n", "<leader>at", "<cmd>AvanteToggle<cr>", { desc = "Claude Max: Toggle sidebar" })
map("n", "<leader>af", "<cmd>AvanteFocus<cr>", { desc = "Claude Max: Focus sidebar" })
