" Generate compile_commands.json for clangd.
" Prefer CMake export, else Ninja compdb, else Bear + Make with optional append:
" First check is whether need for (re)generation be at all, then where relative
" to the open file, then calling CMake, Ninja, or finally Bear if applicable (as
" background jobs). To make those builders work more predictably, additional
" flags are passed to ensure all files are indexed as, say, `bear -- make` falls
" short in presence of build artifacts.

if exists('b:did_c_compdb_ftplugin') | finish | endif
let b:did_c_compdb_ftplugin = 1

let s:inflight = {}

augroup c_compdb
  autocmd! * <buffer>
  autocmd BufWinEnter <buffer> ++once call s:maybe_compdb()
augroup END

function! s:maybe_compdb() abort
  let root = s:project_root()
  if empty(root) | return | endif
  if has_key(s:inflight, root) | return | endif

  " Fast path.
  if filereadable(root . '/compile_commands.json') | return | endif

  " If CMake already produced a database in build/, then sync without reconfigure.
  " Or prefer `.clangd` pointing at build dir to avoid copying databases:
  " Add `.clangd` with `CompileFlags: { CompilationDatabase: build }`
  if filereadable(s:build_dir(root) . '/compile_commands.json')
    call s:sync_from_build(root)
    return
  endif

  let s:inflight[root] = 1

  if filereadable(root . '/CMakeLists.txt')
    call s:cmake_export_compdb(root)
    return
  endif

  if filereadable(s:build_dir(root) . '/build.ninja') || filereadable(root . '/build.ninja')
    call s:ninja_compdb(root)
    return
  endif

  if !empty(glob(root . '/[Mm]akefile', 1, 1))
    call s:bear_make(root)
    return
  endif

  call s:done(root)
endfunction

function! s:project_root() abort
  let start = expand('%:p:h')
  for m in ['CMakeLists.txt', 'Makefile', 'makefile', 'build.ninja', '.git']
    if m ==# '.git'
      let d = finddir(m, start . ';')
      if !empty(d) | return fnamemodify(d, ':p:h') | endif
    else
      let f = findfile(m, start . ';')
      if !empty(f) | return fnamemodify(f, ':p:h') | endif
    endif
  endfor
  return getcwd()
endfunction

function! s:build_dir(root) abort
  return a:root . '/' . get(g:, 'c_compdb_build_dir', 'build')
endfunction

function! s:done(root) abort
  if has_key(s:inflight, a:root) | call remove(s:inflight, a:root) | endif
endfunction

function! s:cmake_export_compdb(root) abort
  if !executable('cmake')
    echomsg 'c_compdb: cmake not found'
    call s:done(a:root)
    return
  endif

  let bdir = s:build_dir(a:root)
  call mkdir(bdir, 'p')

  let args = ['cmake', '-S', a:root, '-B', bdir, '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON']

  " Optional default to Ninja for speed on fresh build trees.
  if get(g:, 'c_compdb_prefer_ninja', 1) && executable('ninja') && !filereadable(bdir . '/CMakeCache.txt')
    call extend(args, ['-G', 'Ninja'])
  endif

  echomsg 'c_compdb: configuring CMake with CMAKE_EXPORT_COMPILE_COMMANDS=ON'
  call job_start(args, {
        \ 'cwd': a:root,
        \ 'exit_cb': function('s:on_cmake_configure', [a:root]),
        \ })
endfunction

function! s:on_cmake_configure(root, job, status) abort
  if a:status != 0
    echomsg 'c_compdb: CMake configure failed'
    call s:done(a:root)
    return
  endif

  if s:sync_from_build(a:root)
    echomsg 'c_compdb: compile_commands.json synced from build dir'
  else
    echomsg 'c_compdb: compile_commands.json not found after configure'
  endif

  call s:done(a:root)
endfunction

function! s:sync_from_build(root) abort
  let src = s:build_dir(a:root) . '/compile_commands.json'
  let dst = a:root . '/compile_commands.json'
  if !filereadable(src) | return 0 | endif

  " Prefer portable cmake -E, then fall back to file copy.
  if executable('cmake')
    " optionally use `copy_if_different` instead of `create_symlink`
    silent call system('cmake -E create_symlink ' .. shellescape(src) .. ' ' .. shellescape(dst))
    return v:shell_error == 0 && filereadable(dst)
  endif

  if exists('*filecopy')
    call filecopy(src, dst)
  else
    call writefile(readfile(src), dst)
  endif
  return filereadable(dst)
endfunction

function! s:ninja_compdb(root) abort
  if !executable('ninja')
    echomsg 'c_compdb: ninja not found'
    call s:done(a:root)
    return
  endif

  let bdir = filereadable(s:build_dir(a:root) . '/build.ninja') ? s:build_dir(a:root) : a:root
  let out = a:root . '/compile_commands.json'

  echomsg 'c_compdb: generating compile_commands.json via ninja -t compdb'
  call job_start(['ninja', '-C', bdir, '-t', 'compdb'], {
        \ 'cwd': a:root,
        \ 'out_io': 'file',
        \ 'out_name': out,
        \ 'err_io': 'file',
        \ 'err_name': out . '.err',
        \ 'exit_cb': function('s:on_ninja_compdb', [a:root]),
        \ })
endfunction

function! s:on_ninja_compdb(root, job, status) abort
  if a:status != 0
    echomsg 'c_compdb: ninja -t compdb failed'
  else
    echomsg 'c_compdb: compile_commands.json generated via Ninja'
  endif
  call s:done(a:root)
endfunction

function! s:bear_make(root) abort
  if !executable('bear')
    echomsg 'c_compdb: bear not found'
    call s:done(a:root)
    return
  endif

  if !get(g:, 'c_compdb_auto_make', 1)
    echomsg 'c_compdb: make build disabled via g:c_compdb_auto_make'
    call s:done(a:root)
    return
  endif

  let out = a:root . '/compile_commands.json'
  let append = filereadable(out)

  let bear = ['bear', '--output', out]
  if append
    call add(bear, '--append')
  endif

  let make = ['make']
  if !append && get(g:, 'c_compdb_make_full_on_first', 0)
    call add(make, '-B')
  endif

  echomsg append
        \ ? 'c_compdb: appending compile commands via bear --append + make'
        \ : 'c_compdb: collecting compile commands via bear + make'

  call job_start(bear + ['--'] + make, {
        \ 'cwd': a:root,
        \ 'exit_cb': function('s:on_bear_make', [a:root]),
        \ })
endfunction

function! s:on_bear_make(root, job, status) abort
  if a:status != 0
    echomsg 'c_compdb: bear/make failed'
  else
    echomsg 'c_compdb: compile_commands.json updated via Bear'
  endif
  call s:done(a:root)
endfunction
