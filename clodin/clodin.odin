package clodin

import "core:strings"
import "core:strconv"
import "core:log"
import "core:os"

program_name := "clodin_program"
program_description := "a command-line program using clodin"
program_version := "1.0.0"

exit_on_failure := true

// If true, include the standard help, usage and version flags.
include_standard_flags := true
// If true, display the standard help, usage and version flags in help messages.
display_standard_flags_help := true

@(private)
found_help_flag, found_usage_flag, found_version_flag: bool

// Starts the argument parser with the given arguments.
start :: proc(args: []string) {
	failed = false
	clear_dynamic_array(&help_entries)

	// chech for "-help" and "-h"
	if include_standard_flags {
		found_help_flag = false
		found_usage_flag = false
		found_version_flag = false

		for arg in args {
			switch arg {
			case "-h", "-help":
				found_help_flag = true
			case "-u", "-usage":
				found_usage_flag = true
			case "-v", "-version":
				found_version_flag = true
			}
		}
	}

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
// Returns `false` if parsing failed or a help or usage message
// was displayed, and returns `true` when parsing succeeded.
finish :: proc(loc := #caller_location) -> bool {
	// check standard flags (can only be true if `include_standard_flags` is set)
	if found_help_flag {
		if display_standard_flags_help {
			add_help_entry(.Flag_Or_Count, "h, -help", "Display this help message.")
			add_help_entry(.Flag_Or_Count, "u, -usage", "Display a short usage message.")
			add_help_entry(.Flag_Or_Count, "v, -version", "Display version information.")
		}
		display_long_help()
		log.debug("clodin.finish returning false because of help message", location = loc)
		return false
	} else if found_usage_flag {
		display_usage()
		log.debug("clodin.finish returning false because of usage message", location = loc)
		return false
	} else if found_version_flag {
		display_version()
		log.debug("clodin.finish returning false because of version message", location = loc)
		return false
	}

	if len(arguments) > 0 {
		log.error("unexpected arguments:", arguments, location = loc)
		return false
	}
	return !failed
}

// Adds a positional string argument. Any input is accepted as a string.
pos_string :: proc(placeholder: string, help_message := "", loc := #caller_location) -> string {
	add_help_entry(.Positional, placeholder, help_message)
	if found_help_flag {return ""}

	if arg, ok := pop_first_positional(); ok {
		// all input can be a string
		return arg
	}

	positional_not_supplied(placeholder, loc)
	return ""
}

// Adds a positional integer argument. Any input that is a valid integer in Odin syntax is accepted.
pos_int :: proc(placeholder: string, help_message := "", loc := #caller_location) -> int {
	add_help_entry(.Positional, placeholder, help_message)
	if found_help_flag {return 0}

	if arg, ok := pop_first_positional(); ok {
		if i, ok := strconv.parse_int(arg); ok {
			return i
		}
		positional_invalid(placeholder, loc)
		return 0
	}

	positional_not_supplied(placeholder, loc)
	return 0
}

// Adds a flag argument.
flag :: proc(name: string, help_message := "") -> bool {
	add_help_entry(.Flag_Or_Count, name, help_message)

	// for flags we don't care abt the count
	return pop_flags(name) > 0
}

// Adds a count argument.
count :: proc(name: string, help_message := "") -> int {
	add_help_entry(.Flag_Or_Count, name, help_message)

	return pop_flags(name)
}

// Adds an optional string argument. Any value is accepted as a string.
opt_string :: proc(name: string, help_message := "", loc := #caller_location) -> Maybe(string) {
	add_help_entry(.Optional, name, help_message)

	if val, ok := pop_first_optional(name); ok {
		// any input can be a string
		return val
	}

	return nil
}

// Adds an optional integer argument. Any input that is a valid integer in Odin syntax is accepted.
opt_int :: proc(name: string, help_message := "", loc := #caller_location) -> Maybe(int) {
	add_help_entry(.Optional, name, help_message)

	if val, ok := pop_first_optional(name); ok {
		if i, ok := strconv.parse_int(val); ok {
			return i
		}

		optional_invalid(name, loc)
	}

	return nil
}
