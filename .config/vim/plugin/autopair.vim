vim9script

def CharAhead(): string
  const colm = col('.') - 1
  const line = getline('.')
  if colm < len(line)
    return line[colm]
  endif
  return ''
enddef

def OpenPair(open: string, close: string): string
  return open .. close .. "\<left>"
enddef

def ClosePair(close: string): string
  if CharAhead() == close
    return "\<right>"
  endif
  return close
enddef

def QuotePair(q: string): string
  const line = getline('.')
  const colm = col('.') - 1

  if CharAhead() == q
    return "\<right>"
  endif

  if q == "'" && colm > 0 && line[colm - 1] =~ '\w' && colm < len(line) && line[colm] =~ '\w'
    return q
  endif

  return q .. q .. "\<left>"
enddef

def SmartBackspace(): string
  const line = getline('.')
  const colm = col('.') - 1
  if colm > 0 && colm < len(line)
    const prev = line[colm - 1]
    const next = line[colm]
    if (prev == '(' && next == ')') ||
       (prev == '{' && next == '}') ||
       (prev == '[' && next == ']') ||
       (prev == '"' && next == '"') ||
       (prev == "'" && next == "'")
      return "\<right>\<bs>\<bs>"
    endif
  endif
  return "\<bs>"
enddef

inoremap <expr> ( OpenPair('(', ')')
inoremap <expr> { OpenPair('{', '}')
inoremap <expr> [ OpenPair('[', ']')
inoremap <expr> ) ClosePair(')')
inoremap <expr> } ClosePair('}')
inoremap <expr> ] ClosePair(']')
inoremap <expr> " QuotePair('"')
inoremap <expr> ' QuotePair("'")
inoremap <expr> <BS> SmartBackspace()

defcompile
# vim: et sts=2 sw=2:
