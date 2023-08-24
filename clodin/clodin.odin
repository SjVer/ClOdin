package clodin

import "core:strings"
import "core:strconv"
import "core:log"
import "core:os"

program_name: string = "clodin_program"
description: string = "a command-line program using clodin"

// Starts the argument parser with the given arguments.
start :: proc(args: []string) {
	resize(&arguments, len(args))
	copy(arguments[:], args[:])
}

// Alias for `start(os.args[1:])`.
//
// The first element of `os.args` is skipped because it is
// typically the name of the command used to invoke the program.
start_os_args :: proc() {
	start(os.args[1:])
}

// Finishes the parsing, asserting that there's no input.
//
// Returns `true` if the parsing finished succesfully,
// and `false` otherwise.
finish :: proc() -> bool {
    if len(arguments) > 0 {
        log.error("unexpected arguments:", arguments)
        return false
    }
    return true
}

pos_string :: proc(placeholder: string, help_message := "") -> string {
    if arg, ok := pop_first_positional(); ok {
        // all input can be a string
        return arg
    }
    
    log.error("expected", placeholder)
    return ""
}

pos_int :: proc(placeholder: string, help_message := "") -> int {
    if arg, ok := pop_first_positional(); ok {
        if i, ok := strconv.parse_int(arg); ok {
            return i
        }

        log.error("expected an integer for", placeholder, "got", arg)
        return 0
    }
    
    log.error("expected", placeholder)
    return 0
}

flag :: proc(name: string, help_message := "") -> bool {
    // for flags we don't care abt the count
    return pop_flags(name) > 0
}

count :: proc(name: string, help_message := "") -> int {
    return pop_flags(name)
}

opt_string :: proc(name: string, help_message := "") -> Maybe(string) {
    if val, ok := pop_first_optional(name); ok {
        // any input can be a string
        return val
    }
 
    return nil
}

opt_int :: proc(name: string, help_message := "") -> Maybe(int) {
    if val, ok := pop_first_optional(name); ok {
        if i, ok := strconv.parse_int(val); ok {
            return i
        }
        
        log.error("expected an integer, got", val)
    }
 
    return nil
}
