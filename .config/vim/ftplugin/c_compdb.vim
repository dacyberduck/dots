vim9script

# Generate compile_commands.json for clangd.
# Prefer CMake export, else Ninja compdb, else Bear + Make with optional append:
# First check is whether need for (re)generation be at all, then where relative
# to the open file, then calling CMake, Ninja, or finally Bear if applicable (as
# background jobs). To make those builders work more predictably, additional
# flags are passed to ensure all files are indexed as, say, `bear -- make` falls
# short in presence of build artifacts.

# This is AI generated vim9script conversion of Konfekt/c_compdb.vim
# https://gist.github.com/Konfekt/2d951b9e07831878b1476133c5f37b52

if exists('b:did_c_compdb_ftplugin')
  finish
endif
b:did_c_compdb_ftplugin = 1

# Script-local state
var inflight: dict<number> = {}

# Initialization
augroup c_compdb
  autocmd! * <buffer>
  autocmd BufWinEnter <buffer> ++once MaybeCompdb()
augroup END

# Helpers
def BuildDir(root: string): string
  var bdir = g:->get('c_compdb_build_dir', 'build')
  return $"{root}/{bdir}"
enddef

def Done(root: string)
  if inflight->has_key(root)
    inflight->remove(root)
  endif
enddef

def ProjectRoot(): string
  var start = expand('%:p:h')
  var markers = ['CMakeLists.txt', 'Makefile', 'makefile', 'build.ninja', '.git']

  for m in markers
    if m == '.git'
      var d = finddir(m, $"{start};")
      if !empty(d) | return fnamemodify(d, ':p:h') | endif
    else
      var f = findfile(m, $"{start};")
      if !empty(f) | return fnamemodify(f, ':p:h') | endif
    endif
  endfor
  return getcwd()
enddef

# Core Sync Logic
def SyncFromBuild(root: string): bool
  var src = $"{BuildDir(root)}/compile_commands.json"
  var dst = $"{root}/compile_commands.json"
  if !filereadable(src) | return false | endif

  if executable('cmake')
    silent call system($'cmake -E create_symlink {shellescape(src)} {shellescape(dst)}')
    return v:shell_error == 0 && filereadable(dst)
  endif

  # Fallback to file copy if no CMake
  var lines = readfile(src)
  writefile(lines, dst)
  return filereadable(dst)
enddef

# Callback Handlers
def OnCmakeConfigure(root: string, job: job, status: number)
  if status != 0
    echomsg 'c_compdb: CMake configure failed'
    Done(root)
    return
  endif

  if SyncFromBuild(root)
    echomsg 'c_compdb: compile_commands.json synced from build dir'
  else
    echomsg 'c_compdb: compile_commands.json not found after configure'
  endif
  Done(root)
enddef

def OnNinjaCompdb(root: string, job: job, status: number)
  if status != 0
    echomsg 'c_compdb: ninja -t compdb failed'
  else
    echomsg 'c_compdb: compile_commands.json generated via Ninja'
  endif
  Done(root)
enddef

def OnBearMake(root: string, job: job, status: number)
  if status != 0
    echomsg 'c_compdb: bear/make failed'
  else
    echomsg 'c_compdb: compile_commands.json updated via Bear'
  endif
  Done(root)
enddef

# Action Functions
def BearMake(root: string)
  if !executable('bear')
    echomsg 'c_compdb: bear not found'
    Done(root)
    return
  endif

  if !g:->get('c_compdb_auto_make', 1)
    echomsg 'c_compdb: make build disabled'
    Done(root)
    return
  endif

  var out = $"{root}/compile_commands.json"
  var append = filereadable(out)
  var bear_cmd = ['bear', '--output', out]
  if append | bear_cmd->add('--append') | endif

  var make_cmd = ['make']
  if !append && g:->get('c_compdb_make_full_on_first', 0)
    make_cmd->add('-B')
  endif

  echomsg append ? 'c_compdb: appending via bear' : 'c_compdb: collecting via bear'

  job_start(bear_cmd + ['--'] + make_cmd, {
    cwd: root,
    exit_cb: (j, s) => OnBearMake(root, j, s)
  })
enddef

def NinjaCompdb(root: string)
  if !executable('ninja')
    echomsg 'c_compdb: ninja not found'
    Done(root)
    return
  endif

  var bdir = filereadable($"{BuildDir(root)}/build.ninja") ? BuildDir(root) : root
  var out = $"{root}/compile_commands.json"

  echomsg 'c_compdb: generating via ninja -t compdb'
  job_start(['ninja', '-C', bdir, '-t', 'compdb'], {
    cwd: root,
    out_io: 'file',
    out_name: out,
    err_io: 'file',
    err_name: $"{out}.err",
    exit_cb: (j, s) => OnNinjaCompdb(root, j, s)
  })
enddef

def CmakeExportCompdb(root: string)
  if !executable('cmake')
    echomsg 'c_compdb: cmake not found'
    Done(root)
    return
  endif

  var bdir = BuildDir(root)
  mkdir(bdir, 'p')

  var args = ['cmake', '-S', root, '-B', bdir, '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON']

  if g:->get('c_compdb_prefer_ninja', 1) && executable('ninja') && !filereadable($"{bdir}/CMakeCache.txt")
    args->extend(['-G', 'Ninja'])
  endif

  echomsg 'c_compdb: configuring CMake...'
  job_start(args, {
    cwd: root,
    exit_cb: (j, s) => OnCmakeConfigure(root, j, s)
  })
enddef

# Main Orchestrator
def MaybeCompdb()
  var root = ProjectRoot()
  if empty(root) || inflight->has_key(root) | return | endif

  # 1. Fast path: already exists
  if filereadable($"{root}/compile_commands.json") | return | endif

  # 2. Check build directory for existing db
  if filereadable($"{BuildDir(root)}/compile_commands.json")
    SyncFromBuild(root)
    return
  endif

  inflight[root] = 1

  # 3. Strategy: CMake
  if filereadable($"{root}/CMakeLists.txt")
    CmakeExportCompdb(root)
    return
  endif

  # 4. Strategy: Ninja
  if filereadable($"{BuildDir(root)}/build.ninja") || filereadable($"{root}/build.ninja")
    NinjaCompdb(root)
    return
  endif

  # 5. Strategy: Bear + Make
  if !empty(glob($"{root}/[Mm]akefile", true, true))
    BearMake(root)
    return
  endif

  Done(root)
enddef

defcompile
# vim: set et sts=2 sw=2:
