vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

require'lspconfig'.pyright.setup {}

vim.cmd 'colorscheme zaibatsu'
