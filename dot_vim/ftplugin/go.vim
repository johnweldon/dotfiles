if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" mappings
nmap <buffer> <LocalLeader>r :GoImports<cr>
