require("config.lazy")

vim.opt.autowriteall = true
vim.opt.exrc = true

local termProg = os.getenv("TERM_PROGRAM")
if termProg == "Apple_Terminal" then
  vim.opt.termguicolors = false
  vim.cmd("colorscheme koehler")
end
