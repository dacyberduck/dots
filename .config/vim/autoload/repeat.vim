vim9script

var repeat_tick = -1
var repeat_reg = ""
var repeat_count = 0
var repeat_sequence = ""

export def repeat#set(sequence: any, count_arg: any = -1)
    # Ensure sequence is a string (lion/surround usually send strings)
    repeat_sequence = (type(sequence) == v:t_string) ? sequence : ""

    # Handle the count logic safely
    var cnt = (type(count_arg) == v:t_number) ? count_arg : -1
    repeat_count = (cnt == -1) ? v:count : cnt

    repeat_tick = b:changedtick
    repeat_reg = v:register
enddef

# This is the function the '.' mapping calls
export def repeat#run(): string
    # If the buffer changed via a different command, fall back to native dot
    if repeat_tick != b:changedtick || empty(repeat_sequence)
        return "."
    endif

    var count = v:count > 0 ? v:count : (repeat_count > 0 ? repeat_count : "")
    var reg = repeat_reg == '"' ? "" : '"' .. repeat_reg

    # Reset tick to prevent infinite loops if the map doesn't call repeat#set
    repeat_tick = -1

    # feedkeys "nt" executes the sequence as if typed, without re-mapping
    feedkeys(reg .. count .. repeat_sequence, "nt")

    return ""
enddef

# Some plugins look for this to wrap commands
export def repeat#wrap(command: string, count_arg: any = -1): string
    repeat#set(command, count_arg)
    return command
enddef
