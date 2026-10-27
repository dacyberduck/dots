vim9script

packadd lsp

# server configuration
call LspAddServer([
  {
    name: 'clangd',
    filetype: ['c', 'cpp'],
    path: '/usr/bin/clangd',
    args: ['--background-index', '--clang-tidy']
  }
])

# Lsp options
call LspOptionsSet({
  noNewlineInCompletion: v:true,
})

# Lsp related bindings and stuff
augroup lsp_attched
  autocmd USER LspAttached nnoremap <buffer> gd         :LspGotoDefinition<CR>
  autocmd USER LspAttached nnoremap <buffer> gD         :LspGotoDeclaration<CR>
  autocmd USER LspAttached nnoremap <buffer> gr         :LspShowReferences<CR>
  autocmd USER LspAttached nnoremap <buffer> gi         :LspGotoImpl<CR>
  autocmd USER LspAttached nnoremap <buffer> K          :LspHover<CR>
  autocmd USER LspAttached nnoremap <buffer> <C-K>      :LspShowSignature<CR>
  autocmd USER LspAttached nnoremap <buffer> [d         :LspDiag prevWrap<CR>
  autocmd USER LspAttached nnoremap <buffer> ]d         :LspDiag nextWrap<CR>
  autocmd USER LspAttached nnoremap <buffer> <leader>d  :LspDiag current<CR>
  autocmd USER LspAttached nnoremap <buffer> <leader>rn :LspRename<CR>
  autocmd USER LspAttached nnoremap <buffer> <leader>ca :LspCodeAction<CR>
  autocmd USER LspAttached nnoremap <buffer> <leader>f  :LspFormat<CR>
augroup end

defcompile
# vim: set et sts=4 sw=4:
