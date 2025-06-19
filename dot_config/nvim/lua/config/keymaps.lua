-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Avante keymaps
map("n", "<leader>aa", function()
  require("avante.api").ask()
end, { desc = "Avante: Ask" })
map("v", "<leader>aa", function()
  require("avante.api").ask()
end, { desc = "Avante: Ask with selection" })
map("n", "<leader>ar", function()
  require("avante.api").refresh()
end, { desc = "Avante: Refresh" })
map("n", "<leader>ae", function()
  require("avante.api").edit()
end, { desc = "Avante: Edit" })
map("v", "<leader>ae", function()
  require("avante.api").edit()
end, { desc = "Avante: Edit selection" })

-- Additional Avante workflow keymaps
map("n", "<leader>ac", "<cmd>AvanteClear<cr>", { desc = "Avante: Clear history" })
map("n", "<leader>at", "<cmd>AvanteToggle<cr>", { desc = "Avante: Toggle sidebar" })
map("n", "<leader>af", "<cmd>AvanteFocus<cr>", { desc = "Avante: Focus sidebar" })

-- Provider switching keymaps
map("n", "<leader>apc", function()
  require("avante.config").override({ provider = "claude" })
  vim.notify("Switched to Claude provider", vim.log.levels.INFO)
end, { desc = "Avante: Switch to Claude" })
map("n", "<leader>apo", function()
  require("avante.config").override({ provider = "openai" })
  vim.notify("Switched to OpenAI provider", vim.log.levels.INFO)
end, { desc = "Avante: Switch to OpenAI" })
map("n", "<leader>apl", function()
  require("avante.config").override({ provider = "ollama" })
  vim.notify("Switched to Ollama provider", vim.log.levels.INFO)
end, { desc = "Avante: Switch to Ollama" })
