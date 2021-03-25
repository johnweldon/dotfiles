if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

setlocal tabstop=4
setlocal shiftwidth=4
setlocal expandtab
setlocal autoindent
setlocal formatoptions=croql

" ALE
let b:ale_completion_enabled = 1
let b:ale_fix_on_save = 1

let b:ale_fixers = ['black', 'remove_trailing_lines', 'trim_whitespace']
let b:ale_linters = ['flake8', 'pyls']

" mappings
nmap <buffer> <LocalLeader>r :ALEFix black<cr>
nmap <buffer> <LocalLeader>d :ALEGoToDefinition<cr>
