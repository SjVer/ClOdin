package clodin

import "core:fmt"

display_long_help :: proc() {
	fmt.println(program_name, "-", description)

	// // usage
	// fmt.println("Usage:")
	// fmt.printf("\t%s", name)
	// for parser in pos_parsers {
	//     fmt.printf(" <%s>", parser.placeholder)
	// }
	// if len(flag_parsers) > 0 || len(opt_parsers) > 0 {
	//     fmt.printf(" [arguments]")
	// }
	// fmt.println()
}
