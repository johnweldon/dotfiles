require("config.lazy")

vim.opt.autowriteall = true
vim.opt.exrc = true

-- Apple Terminal specific settings
local termProg = os.getenv("TERM_PROGRAM")
if termProg == "Apple_Terminal" then
  vim.opt.termguicolors = false
  vim.cmd("colorscheme koehler")
end

-- Source local configuration if it exists (not managed by chezmoi)
local local_config = vim.fn.stdpath("config") .. "/.local.lua"
if vim.fn.filereadable(local_config) == 1 then
  local ok, err = pcall(dofile, local_config)
  if not ok then
    vim.notify("Error loading .local.lua: " .. err, vim.log.levels.ERROR)
  end
end
