package clodin

import "core:fmt"
import "core:os"
import "core:strings"

Help_Category :: enum {
	Positional,
	Flag_Or_Count,
	Optional,
}

@(private)
Help_Entry :: struct {
	category: Help_Category,
	name:     string,
	message:  string,
}

@(private)
help_entries: [dynamic]Help_Entry

program_name := "clodin_program"
program_description := "a command-line program using clodin"
program_version := "1.0.0"
program_information := "See https://github.com/SjVer/ClOdin for more information."

display_handle := os.stderr

@(private)
indent_msg :: proc(msg: string) -> string {
	msg, _ := strings.replace(msg, "\n", "\n\t\t", -1)
	return msg
}

// Adds an entry to the long help message.
//
// `name` should be either a placeholder in case of a positional argument,
// or the name of a flag, count or optional argument otherwise.
add_help_entry :: proc(category: Help_Category, name, message: string) {
	append(&help_entries, Help_Entry{category, name, message})
}

display_short_help :: proc() {
	fmt.fprintln(display_handle, program_name, "-", program_description)
	fmt.fprintln(display_handle)

	display_usage(true, false)

	if include_standard_flags {
		fmt.fprintln(display_handle)
		fmt.fprintln(display_handle, "For more information try -help")
	}
}

display_long_help :: proc() {
	fmt.fprintln(display_handle, program_name, "-", program_description)

	// sort entries
	pos_entries, opt_entries: [dynamic]Help_Entry
	for entry in help_entries {
		if entry.category == .Positional {
			append(&pos_entries, entry)
		} else {
			append(&opt_entries, entry)
		}
	}

	// usage
	display_usage(true)
	fmt.fprintln(display_handle)

	// positionals
	fmt.fprintln(display_handle, "Arguments:")
	for entry in pos_entries {
		fmt.fprintf(display_handle, "\t<%s>\n", entry.name)
		if len(entry.message) > 0 {
			fmt.fprintf(
				display_handle, "\t\t%s\n\n", 
				indent_msg(entry.message)
			)
		}
		else do fmt.fprintln(display_handle)
	}

	if len(opt_entries) == 0 do return

	// flags, counts and optionals
	fmt.fprintln(display_handle, "Flags:")
	for entry in opt_entries {
		if entry.category == .Flag_Or_Count {
			fmt.fprintf(display_handle, "\t-%s\n", entry.name)
			if len(entry.message) > 0 {
				fmt.fprintf(
					display_handle, "\t\t%#v\n", 
					indent_msg(entry.message)
				)
			}
			fmt.fprintln(display_handle)
		} else if entry.category == .Optional {
			fmt.fprintf(display_handle, "\t-%s:...\n", entry.name)
			if len(entry.message) > 0 {
				fmt.fprintf(
					display_handle, "\t\t%#v\n", 
					indent_msg(entry.message)
				)
			}
			fmt.fprintln(display_handle)
		}
	}

	// long help
	if program_information != "" {
		fmt.fprintf(display_handle, "%s\n", program_information)
	}
}

display_usage :: proc(compact := false, include_help_hint := false) {
	if compact {
		fmt.fprint(display_handle, "Usage:")
	} else {
		fmt.fprintln(display_handle, "Usage:")
		fmt.fprint(display_handle, "\t")
	}
	fmt.fprintf(display_handle, " %s", program_name)

	has_opts := false
	for entry in help_entries {
		if entry.category == .Positional {
			fmt.fprintf(display_handle, " %s", entry.name)
		} else {
			has_opts = true
		}
	}
	if has_opts {
		fmt.fprintf(display_handle, " [options]")
	}
	fmt.fprintln(display_handle)
	
	if include_help_hint && include_standard_flags {
		fmt.fprintln(display_handle)
		fmt.fprintln(display_handle, "For more information try -help")
	}
}

display_version :: proc() {
	fmt.fprintln(display_handle, program_name, "version", program_version)
}
