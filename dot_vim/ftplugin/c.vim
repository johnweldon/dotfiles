if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" ALE
let b:ale_completion_enabled = 1
let b:ale_fix_on_save = 1

let b:ale_fixers = ['astyle', 'remove_trailing_lines', 'trim_whitespace']
let b:ale_linters = ['cc', 'ccls', 'cppcheck']

" mappings
nmap <buffer> <LocalLeader>r :ALEFix astyle<cr>
