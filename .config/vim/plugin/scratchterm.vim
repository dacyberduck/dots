vim9script

# USAGE Example:
#   :ScratchTerm
#   :ScratchTerm make %<
#   :ScratchTerm bash -c %:p
def ScratchTerm(...args: list<any>): void
  const termbufname = "__SCRATCH_TERM__"
  const scratch_bufnr = bufnr(termbufname)

  # scratch term not exists
  if scratch_bufnr == -1
    term_start('bash', {'term_name': termbufname, 'term_finish': 'close', 'term_rows': 15})
  else
    # Check if the buffer is currently visible in a window
    const winid = bufwinid(scratch_bufnr)

    if winid != -1 && win_getid() != winid
      # Visible in another window: focus it
      win_gotoid(winid)
    elseif winid == -1
      # Exists but hidden: open it in a bottom split
      execute($"botright 15split | buffer {scratch_bufnr}")
    endif
  endif

  const cmd = args->join()->expandcmd()
  if len(cmd) > 0
    sleep 100m
    term_sendkeys(bufnr(), cmd .. "\<CR>")
  endif
enddef

def ScratchTermClose(): void
  const scratch_bufnr = bufnr("__SCRATCH_TERM__")
  if scratch_bufnr != -1
    execute($"silent bdelete! {scratch_bufnr}")
  endif
enddef

command! -nargs=* -complete=shellcmd ScratchTerm ScratchTerm(<q-args>)
command! ScratchTermClose ScratchTermClose()

defcompile
# vim: et sts=2 sw=2:
