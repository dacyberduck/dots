vim9script
# lion.vim - A Vim plugin for text alignment operators
# Maintainer:   Tom McDonald <http://github.com/tommcdo>
# Version:      1.0

if exists("g:loaded_vim_lion_plugin")
  finish
endif
g:loaded_vim_lion_plugin = 1

var count = 1
var lion_prompt = get(g:, 'lion_prompt', 'Pattern [/]: ')
var lion_squeeze_spaces = 0

def Command(func: string, ...args: list<any>): string
  count = v:count
  if len(args) > 0
    return ':' .. "\<C-U>call " .. func .. "(visualmode(), 1)\<CR>"
  else
    return ':' .. "\<C-U>set opfunc=" .. func .. "\<CR>g@"
  endif
enddef

def AlignRight(type: string, ...args: list<any>)
  Align('right', type, len(args), '')
enddef

def AlignLeft(type: string, ...args: list<any>)
  Align('left', type, len(args), '')
enddef

# Align a range to a particular character
def Align(mode: string, type: string, vis: number, align_char: string)
  var sel_save = &selection
  &selection = 'inclusive'
  try
    # Do we have a character from argument, or should we get one from input?
    var align_pattern = align_char
    var skip = 0
    if align_pattern ==# ''
      align_pattern = nr2char(getchar())
      var char = ''
      if align_pattern =~# '[1-9]'
        while 1
          char = nr2char(getchar())
          if char !~# '[1-9]'
            break
          endif
          align_pattern = align_pattern .. char
        endwhile
        if char !=# "\<CR>"
          skip = str2nr(align_pattern) - 1
          align_pattern = char
        endif
      endif
    endif
    if align_pattern ==# '/'
      align_pattern = input(lion_prompt)
    elseif align_pattern ==# ' '
      align_pattern = '/\S\zs\s'
    endif

    # Determine range boundaries
    var pos = []
    if vis
      pos = GetPos("'<", "'>", visualmode())
    else
      pos = GetPos("'[", "']", type)
    endif
    var [start_line, end_line, start_col, end_col, middle_start_col, middle_end_col] = pos

    # Check for 'lion_squeeze_spaces' options
    if exists('b:lion_squeeze_spaces')
      lion_squeeze_spaces = get(b:, 'lion_squeeze_spaces')
    elseif exists('g:lion_squeeze_spaces')
      lion_squeeze_spaces = get(g:, 'lion_squeeze_spaces')
    endif

    # Squeeze extra spaces before aligning
    if lion_squeeze_spaces
      for lnum in range(start_line, end_line)
        setline(lnum, substitute(getline(lnum), '\(^\s*\)\@<! \{2,}', ' ', 'g'))
      endfor
    endif

    # Align for each character up to count or maximum occurances
    var iteration = 1
    while 1
      var line_virtual_pos = [] # Keep track of positions
      var longest          = -1 # Track longest sequence
      var start:    number
      var end:      number
      var line_str: string

      # Find the longest substring before the align character
      for line_number in range(start_line, end_line)
        if line_number == start_line
          start = start_col
        else
          start = middle_start_col
        endif
        if line_number == end_line
          end = end_col
        else
          end = middle_end_col
        endif
        line_str = getline(line_number)
        # Find the 'real' and 'virtual' positions of the align character
        # in this line
        var [real_pos, virtual_pos] = MatchPos(mode, line_str, align_pattern, skip + iteration, line_number, start, end)
        line_virtual_pos = line_virtual_pos + [[real_pos, virtual_pos]]
        longest = max([longest, virtual_pos])
      endfor

      # Align each line according to the longest
      for line_number in range(start_line, end_line)
        line_str = getline(line_number)
        var [real_pos, virtual_pos] = line_virtual_pos[(line_number - start_line)]
        if virtual_pos != -1 && virtual_pos < longest
          var spaces = repeat(' ', (longest - virtual_pos))
          var new_line = ''
          if real_pos == 0
            new_line = spaces .. line_str
          else
            new_line = line_str[ : (real_pos - 1) ] .. spaces .. line_str[ (real_pos) : ]
          endif
          setline(line_number, new_line)
        endif
      endfor
      if count - iteration == 0 || longest == -1
        break
      endif
      iteration = iteration + 1
    endwhile

    # fix pattern before use with repeat.vim
    if align_pattern ==# '/\S\zs\s'
      align_pattern = " "
    endif
    if align_pattern[0] ==# '/'
      silent! call repeat#set("\<Plug>LionRepeat" .. align_pattern .. "\<CR>")
    else
      silent! call repeat#set("\<Plug>LionRepeat" .. align_pattern)
    endif
  finally
    &selection = sel_save
  endtry
enddef

def GetPos(start: string, end: string, mode: string): list<number>
  var [_, start_line, start_col, _] = getpos(start)
  var [_, end_line,   end_col,   _] = getpos(end)
  var [middle_start_col, middle_end_col] = [0, -1]
  if mode ==# 'V' || mode ==# 'line'
    [start_col, end_col] = [0, -1]
  elseif mode ==# "\<C-V>"
    [middle_start_col, middle_end_col] = [start_col, end_col]
  endif
  return [start_line, end_line, start_col, end_col, middle_start_col, middle_end_col]
enddef

# Match the position of a character in a line after accounting for artificial width set by tabs
def MatchPos(mode: string, lline: string, char: string, scount: number, line_number: number, start: number, end: number): list<number>
  var pattern = ''
  var line = ''
  var real_pos = -1
  var virtual_pos = -1
  if strlen(char) == 1
    # Ignore the 'ignorecase' setting
    pattern = '\C' .. escape(char, '~^$.')
  else
    pattern = char[ 1 : ]
  endif
  # Add start-of-match anchor at the end if there isn't already one in the pattern
  if mode ==# 'left' && match(pattern, '\\zs') == -1
    pattern = pattern .. '\zs'
  endif
  if end == -1
    line = lline
  else
    line = lline[ : (end - 1) ]
  endif
  if mode ==# 'right'
    real_pos = match(line, pattern, start - 1, scount)
  elseif mode ==# 'left'
    real_pos = FirstNonWsAfter(line, pattern, start - 1, scount)
  endif
  if real_pos == -1
    virtual_pos = -1
  else
    virtual_pos = virtcol([line_number, real_pos])
  endif
  return [real_pos, virtual_pos]
enddef

# Get the first non-whitespace after [count] instances of [char]
def FirstNonWsAfter(line: string, pattern: string, start: number, scount: number): number
  var char_pos = match(line, pattern, start, scount)
  if char_pos == -1
    return -1
  else
    return match(line, '\S', char_pos)
  endif
enddef

# Echo a string and wait for input (used when I'm debugging)
def DebugStr(str: string)
  echo str
  var x = getchar()
enddef

def AlignCmd(cmd: string, line1: number, line2: number, ...args: list<string>)
  const save_cursor = getcurpos()
  var char: any
  if args->len() == 0
    char = args[0]
  else
    char = input(lion_prompt)
  endif
  execute 'normal ' .. line1 .. 'GV' .. line2 .. 'G' .. cmd .. char
  setpos('.', save_cursor)
enddef

command! -range -nargs=? AlignRight AlignCmd('gL', <line1>, <line2>, <q-args>)
command! -range -nargs=? AlignLeft  AlignCmd('gl', <line1>, <line2>, <q-args>)

nnoremap <silent> <Plug>LionRepeat .
nnoremap <silent> <expr> <Plug>LionRight  <SID>Command("<SID>AlignRight")
vnoremap <silent> <expr> <Plug>VLionRight <SID>Command("<SID>AlignRight", 1)
nnoremap <silent> <expr> <Plug>LionLeft   <SID>Command("<SID>AlignLeft")
vnoremap <silent> <expr> <Plug>VLionLeft  <SID>Command("<SID>AlignLeft",  1)

if get(g:, 'lion_create_maps', 1)
  nmap gl <Plug>LionRight
  vmap gl <Plug>VLionRight
  nmap gL <Plug>LionLeft
  vmap gL <Plug>VLionLeft
endif

defcompile
# vim: set et sts=2 sw=2:
