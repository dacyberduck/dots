vim9script

def SetIndentGuides()
  if &buflisted && &modifiable
    execute('setlocal listchars=' .. join(filter(copy(split(&listchars, ',')), (_, val) => val !~ 'leadmultispace\|tab') + 
      [ 'leadmultispace:│' .. repeat('\ ', &shiftwidth - 1), 'tab:█\ ' ], ','))
    setlocal list
  endif
enddef

augroup IndentGuide
  autocmd!
  autocmd BufWinEnter * SetIndentGuides()
  autocmd OptionSet shiftwidth SetIndentGuides()
augroup END

defcompile
# vim: set et sts=2 sw=2:
