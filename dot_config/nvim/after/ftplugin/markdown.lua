vim.opt_local.textwidth = 80
vim.opt_local.colorcolumn = "80"

-- Route gq through Vim's internal formatter, not conform/prettier.
-- LazyVim sets formatexpr globally to conform.formatexpr(), and our
-- prettier runs with --prose-wrap preserve, so gq would otherwise no-op
-- on markdown.
vim.opt_local.formatexpr = ""
vim.opt_local.formatprg = ""

-- Ensure proper formatting options for text wrapping.
vim.opt_local.formatoptions:append("t") -- auto-wrap text using textwidth
vim.opt_local.formatoptions:remove("l") -- allow gq to wrap already-long lines
vim.opt_local.formatoptions:append("n") -- use formatlistpat for list indent
vim.opt_local.formatoptions:append("q") -- allow gq to format comments (blockquotes)

-- Recognize markdown list markers: -, *, +, 1., 1) (with nesting).
vim.opt_local.formatlistpat = [[^\s*\(\d\+[.)]\|[-*+]\)\s\+]]

-- Treat '>' as a blockquote prefix so gq preserves it on wrap.
vim.opt_local.comments = "b:>"

-- Convenience: wrap the current paragraph/list item.
vim.keymap.set("n", "<leader>gq", "gqip", {
  buffer = true,
  desc = "Wrap current paragraph at textwidth",
})
