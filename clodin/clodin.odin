package clodin

import "core:log"
import "core:os"
import "core:strconv"
import "core:strings"

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

// Alias for `clodin.start(os.args[1:])`.
//
// The first element of `os.args` is skipped because it is
// typically the name of the command used to invoke the program.
start_os_args :: proc() {
	start(os.args[1:])
}

// Finishes the parsing, asserting that there's no input left.
//
// Returns `false` if parsing failed or a help or usage message
// was displayed, and returns `true` when parsing succeeded.
finish :: proc(loc := #caller_location) -> bool {
	// check standard flags (can only be true if `include_standard_flags` is set)
	if found_help_flag {
		if display_standard_flags_help {
			add_help_entry(
				.Flag_Or_Count,
				"h, -help",
				"Display this help message",
			)
			add_help_entry(
				.Flag_Or_Count,
				"u, -usage",
				"Display a short usage message",
			)
			add_help_entry(
				.Flag_Or_Count,
				"v, -version",
				"Display version information",
			)
		}
		display_long_help()
		log.debug(
			"clodin.finish returning false because of help message",
			location = loc,
		)
		return false
	} else if found_usage_flag {
		display_usage()
		log.debug(
			"clodin.finish returning false because of usage message",
			location = loc,
		)
		return false
	} else if found_version_flag {
		display_version()
		log.debug(
			"clodin.finish returning false because of version message",
			location = loc,
		)
		return false
	}

	if len(arguments) > 0 {
		log.error("unexpected arguments:", arguments, location = loc)
		display_short_help()
		failed = true
		if exit_on_failure do os.exit(1)
	}
	return !failed
}


// Positional Arguments

// Add a positional argument of type `$T` that can be parsed by `parsing_proc`.
pos_arg :: proc(
	parsing_proc: proc(input: string) -> (res: $T, ok: bool),
	zero_value: T,
	placeholder: string,
	help_message := "",
	loc := #caller_location,
) -> T {
	add_help_entry(.Positional, placeholder, help_message)
	if found_help_flag {return zero_value}

	if arg, ok := pop_first_positional(); ok {
		if val, ok := parsing_proc(arg); ok {
			return val
		}

		positional_invalid(placeholder, loc)
		return zero_value
	}

	positional_not_supplied(placeholder, loc)
	return zero_value
}

// Adds a positional string argument. Any input is accepted as a string.
pos_string :: proc(
	placeholder: string,
	help_message := "",
	loc := #caller_location,
) -> string {
	parsing_proc :: proc(input: string) -> (res: string, ok: bool) {
		return input, true
	}
	return pos_arg(parsing_proc, "", placeholder, help_message, loc)
}

// Adds a positional integer argument. Any input that is a valid integer in Odin syntax is accepted.
pos_int :: proc(
	placeholder: string,
	help_message := "",
	loc := #caller_location,
) -> int {
	parsing_proc :: proc(input: string) -> (res: int, ok: bool) {
		return strconv.parse_int(input)
	}
	return pos_arg(parsing_proc, 0, placeholder, help_message, loc)
}

// Adds a positional float argument. Any input that is a valid float in Odin syntax is accepted.
pos_float :: proc(
	placeholder: string,
	help_message := "",
	loc := #caller_location,
) -> f64 {
	parsing_proc :: proc(input: string) -> (res: f64, ok: bool) {
		return strconv.parse_f64(input)
	}
	return pos_arg(parsing_proc, 0.0, placeholder, help_message, loc)
}

// Adds a positional boolean argument. As input, "1", "t", "T", "true", "TRUE", "True"
// for `true`, and similar strings for `false` are accepted.
pos_bool :: proc(
	placeholder: string,
	help_message := "",
	loc := #caller_location,
) -> bool {
	parsing_proc :: proc(input: string) -> (res: bool, ok: bool) {
		return strconv.parse_bool(input)
	}
	return pos_arg(parsing_proc, false, placeholder, help_message, loc)
}


// Flag and Count Arguments

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


// Optional Arguments

// Add an optional argument of type `Maybe(T)` that can be parsed by `parsing_proc`.
opt_arg :: proc(
	parsing_proc: proc(input: string) -> (res: $T, ok: bool),
	name: string,
	help_message := "",
	loc := #caller_location,
) -> Maybe(T) {
	add_help_entry(.Optional, name, help_message)

	if val, ok := pop_first_optional(name); ok {
		if val, ok := parsing_proc(val); ok {
			return val
		}

		optional_invalid(name, loc)
	}

	return nil
}

// Adds an optional string argument. Any value is accepted as a string.
opt_string :: proc(
	name: string,
	help_message := "",
	loc := #caller_location,
) -> Maybe(string) {
	parsing_proc :: proc(input: string) -> (res: string, ok: bool) {
		return input, true
	}
	return opt_arg(parsing_proc, name, help_message, loc)
}

// Adds an optional integer argument. Any input that is a valid integer in Odin syntax is accepted.
opt_int :: proc(
	name: string,
	help_message := "",
	loc := #caller_location,
) -> Maybe(int) {
	parsing_proc :: proc(input: string) -> (res: int, ok: bool) {
		return strconv.parse_int(input)
	}
	return opt_arg(parsing_proc, name, help_message, loc)
}

// Adds an optional float argument. Any input that is a valid float in Odin syntax is accepted.
opt_float :: proc(
	name: string,
	help_message := "",
	loc := #caller_location,
) -> Maybe(f64) {
	parsing_proc :: proc(input: string) -> (res: f64, ok: bool) {
		return strconv.parse_f64(input)
	}
	return opt_arg(parsing_proc, name, help_message, loc)
}

// Adds an optional boolean argument. As input, "1", "t", "T", "true", "TRUE", "True"
// for `true`, and similar strings for `false` are accepted.
opt_bool :: proc(
	name: string,
	help_message := "",
	loc := #caller_location,
) -> Maybe(bool) {
	parsing_proc :: proc(input: string) -> (res: bool, ok: bool) {
		return strconv.parse_bool(input)
	}
	return opt_arg(parsing_proc, name, help_message, loc)
}
