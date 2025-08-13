-- Shared black background theme
local black_bg = "#000000"
local black_bg_alt = "#0a0a0a"

return {
  -- Tokyo Night colorscheme (primary)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "dark",
        floats = "dark",
      },
      on_colors = function(colors)
        colors.bg = black_bg
        colors.bg_dark = black_bg
        colors.bg_float = black_bg
        colors.bg_popup = black_bg
        colors.bg_sidebar = black_bg
        colors.bg_statusline = black_bg
      end,
      on_highlights = function(highlights)
        local bg_highlights = {
          "Normal",
          "NormalFloat",
          "NormalNC",
          "NormalSB",
          "Folded",
          "FoldColumn",
          "SignColumn",
          "StatusLine",
          "StatusLineNC",
          "VertSplit",
        }
        for _, hl in ipairs(bg_highlights) do
          highlights[hl] = { bg = black_bg }
        end
        highlights.ColorColumn = { bg = black_bg_alt }
      end,
    },
  },

  -- Catppuccin colorscheme (alternative)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
      },
      color_overrides = {
        mocha = {
          base = black_bg,
          mantle = black_bg,
          crust = black_bg_alt,
        },
      },
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        telescope = true,
        trouble = true,
        which_key = true,
      },
    },
  },

  -- Set default colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
