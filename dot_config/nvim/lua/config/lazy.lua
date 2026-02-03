local lib = require("lib")

local colorscheme_16color = "industry"
local cterm = lib.cterm

local function get_colorscheme()
  if lib.is_16color_terminal() then
    vim.opt.termguicolors = false
    vim.opt.statusline = " %f %m%r%h %= %y %l:%c %p%% "
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = colorscheme_16color,
      callback = function()
        vim.api.nvim_set_hl(0, "Comment", { ctermfg = cterm.green })
        vim.api.nvim_set_hl(0, "CursorLine", {})
        vim.api.nvim_set_hl(0, "CursorLineNr", { ctermfg = cterm.bright_yellow })
        vim.api.nvim_set_hl(0, "LineNr", { ctermfg = cterm.white })
        vim.api.nvim_set_hl(0, "Title", { ctermfg = cterm.cyan })
      end,
    })
    return colorscheme_16color
  end

  return "tokyonight"
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        colorscheme = get_colorscheme(),
      },
      priority = 10000,
      lazy = false,
      config = true,
    },
    -- import any extras modules here
    -- { import = "lazyvim.plugins.extras.lang.typescript" },
    -- { import = "lazyvim.plugins.extras.lang.json" },
    -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Setup LazyVim and create LazyExtras command
vim.schedule(function()
  local ok, lazyvim = pcall(require, "lazyvim")
  if ok then
    lazyvim.setup({
      colorscheme = get_colorscheme(),
    })

    vim.schedule(function()
      if vim.api.nvim_get_commands({})["LazyExtras"] == nil then
        local extras_ok, extras = pcall(require, "lazyvim.util.extras")
        if extras_ok then
          vim.api.nvim_create_user_command("LazyExtras", function()
            extras.show()
          end, { desc = "Manage LazyVim extras" })
        end
      end
    end)
  end
end)
