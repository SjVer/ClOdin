package clodin

import "core:fmt"
import "core:os"

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

display_handle := os.stderr

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
	
	display_usage()
	
	if include_standard_flags {
		fmt.fprintln(display_handle)
		fmt.fprintln(display_handle, "For more information try -help")
	}
}

display_long_help :: proc() {
	fmt.fprintln(display_handle, program_name, "-", program_description)

	// sort entries
	pos_entries, opt_entries : [dynamic]Help_Entry
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
		fmt.fprintf(display_handle, "\t\t%#v\n\n", entry.message)
	}

	if len(opt_entries) == 0 {return}

	// flags, counts and optionals
	fmt.fprintln(display_handle, "Flags:")
	for entry in opt_entries {
		if entry.category == .Flag_Or_Count {
			fmt.fprintf(display_handle, "\t-%s\n", entry.name)
			if len(entry.message) > 0 {
				fmt.fprintf(display_handle, "\t\t%#v\n", entry.message)
			}
			fmt.fprintln(display_handle)
		}
		else if entry.category == .Optional {
			fmt.fprintf(display_handle, "\t-%s:...\n", entry.name)
			if len(entry.message) > 0 {
				fmt.fprintf(display_handle, "\t\t%#v\n", entry.message)
			}
			fmt.fprintln(display_handle)
		}
	}
}

display_usage :: proc(multiline := false) {
	if multiline {
		fmt.fprintln(display_handle, "Usage:")
		fmt.fprint(display_handle, "\t")
	} else {
		fmt.fprint(display_handle, "Usage:")
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
}

display_version :: proc() {
	fmt.fprintln(display_handle, program_name, "version", program_version)
}