if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" ALE
let b:ale_completion_enabled = 1
let b:ale_fix_on_save = 1

let b:ale_fixers = ['goimports', 'remove_trailing_lines', 'trim_whitespace']
let b:ale_linters = ['gopls', 'golangci-lint']

" vim-go
let b:go_fmt_command = "goimports"
let b:go_fmt_fail_silently = 1

let b:go_highlight_functions = 1
let b:go_highlight_methods = 1
let b:go_highlight_structs = 1
let b:go_highlight_interfaces = 1
let b:go_highlight_operators = 1
let b:go_highlight_build_constraints = 1

let b:go_metalinter_command='golangci-lint'

let b:go_info_mode='gopls'

" mappings
nmap <buffer> <LocalLeader>r :GoImports<cr>
nmap <buffer> <LocalLeader>d :ALEGoToDefinition<cr>

nmap <buffer> gd <Plug>(go-def)<cr>

