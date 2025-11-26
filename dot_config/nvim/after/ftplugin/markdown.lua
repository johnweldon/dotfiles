vim.opt_local.textwidth = 80
vim.opt_local.colorcolumn = "80"

-- Ensure proper formatting options for text wrapping
vim.opt_local.formatoptions:append("t") -- Auto-wrap text using textwidth
vim.opt_local.formatoptions:remove("l") -- Allow gq to wrap already long lines

-- Use internal vim wrapping with <leader>gq
vim.keymap.set("n", "<leader>gq", function()
  local save_formatprg = vim.bo.formatprg
  local save_formatexpr = vim.bo.formatexpr
  vim.bo.formatprg = ""
  vim.bo.formatexpr = ""
  vim.cmd("normal! gqip")
  vim.bo.formatprg = save_formatprg
  vim.bo.formatexpr = save_formatexpr
end, { buffer = true, desc = "Wrap current paragraph at textwidth" })
