//+private
package clodin

import "core:runtime"
import "core:os"
import "core:strings"
import "core:fmt"
import "core:log"

Loc :: runtime.Source_Code_Location

failed := false
arguments: [dynamic]string

pop_first_positional :: proc() -> (arg: string, ok: bool) {
	for arg, i in arguments {
		if arg[0] != '-' {
			unordered_remove(&arguments, i)
			return arg, true
		}
	}

	return "", false
}

pop_flags :: proc(name: string) -> int {
	count := 0

	for i := 0; i < len(arguments); i += 1 {
		arg := arguments[i]

		if arg[0] == '-' && arg[1:] == name {
			unordered_remove(&arguments, i)
			i -= 1
			count += 1
		}
	}

	return count
}

pop_first_optional :: proc(name: string) -> (val: string, ok: bool) {
	prefix := fmt.aprintf("-%s:", name)

	for arg, i in arguments {
		if len(arg) > len(prefix) && strings.has_prefix(arg, prefix) {
			unordered_remove(&arguments, i)
			_, _, val := strings.partition(arg, ":")
			return val, true
		}
	}

	return "", false
}

positional_not_supplied :: proc(placeholder: string, loc: Loc) {
	log.error("got no argument for", placeholder, location = loc)
	display_usage()
	failed = true
	if exit_on_failure {os.exit(1)}
}

positional_invalid :: proc(placeholder: string, loc: Loc) {
	log.error("got invalid argument for", placeholder, location = loc)
	display_short_help()
	failed = true
	if exit_on_failure {os.exit(1)}
}

optional_invalid :: proc(name: string, loc: Loc) {
	log.error("got invalid argument for", name, location = loc)
	display_short_help()
	failed = true
	if exit_on_failure {os.exit(1)}
}

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

// Add an optional argument of type `$T` that can be parsed by `parsing_proc`.
opt_arg :: proc(
	parsing_proc: proc(input: string) -> (res: $T, ok: bool),
	zero_value: T,
	name: string,
	help_message := "",
	loc := #caller_location,
) -> T {
	add_help_entry(.Optional, name, help_message)

	if val, ok := pop_first_optional(name); ok {
		if val, ok := parsing_proc(val); ok {
			return val
		}

		optional_invalid(name, loc)
	}

	return zero_value
}