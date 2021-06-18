if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" ALE
let b:ale_completion_enabled = 1
let b:ale_fix_on_save = 1

let b:ale_fixers = ['goimports', 'remove_trailing_lines', 'trim_whitespace']
let b:ale_linters = ['gopls', 'golangci-lint']

" mappings
nmap <buffer> <LocalLeader>r :GoImports<cr>
nmap <buffer> <LocalLeader>d :ALEGoToDefinition<cr>

nmap <buffer> gd <Plug>(go-def)<cr>

