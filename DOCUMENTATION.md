# ClOdin API

ClOdin allows you to easily and consistently parse command-line arguments for your Odin programs. The API is designed to follow the style of the command-line interface of Odin's official compiler and be as simple as possible, with almost no boilerplate.

## Control

Typical usage of ClOdin starts by setting any behaviour-related variables:

```odin
program_name := "clodin_program"
```
```odin
program_description := "a command-line program using clodin"
```
```odin
program_version := "1.0.0"
```
```odin
exit_on_failure := true
```
```odin
// If true, include the standard help, usage and version flags.
include_standard_flags := true
```
```odin
// If true, display the standard help, usage and version flags in help messages.
display_standard_flags_help := true
```

Then, to start the parsing, call `clodin.start` with an array of arguments:

```odin
// Starts the argument parser with the given arguments.
start :: proc(args: []string)
```
```odin
// Alias for `start(os.args[1:])`.
//
// The first element of `os.args` is skipped because it is
// typically the name of the command used to invoke the program.
start_os_args :: proc()
```

When parsing is done, call `clodin.finish` to check that parsing succeeded:

```odin
// Finishes the parsing, asserting that there's no input.
//
// Returns `false` if parsing failed or a help or usage message
// was displayed, and returns `true` when parsing succeeded.
finish :: proc(loc := #caller_location) -> bool
```

Lastly, some functions are available for manually displaying different messages. These functions depend on the arguments, so they should be called after the arguments are added.

```odin
Help_Category :: enum {
	Positional,
	Flag_Or_Count,
	Optional,
}

// Adds an entry to the long help message.
//
// `name` should be either a placeholder in case of a positional argument,
// or the name of a flag, count or optional argument otherwise.
add_help_entry :: proc(category: Help_Category, name, message: string)
```
```odin
display_short_help :: proc()
```
```odin
display_long_help :: proc()
```
```odin
display_usage :: proc(multiline := false)
```
```odin
display_version :: proc()
```

## Positional Arguments

Positional arguments are arguments that are not denoted by a prefix like `-foo:`, and must be supplied.

For example, in `my_program.exe foo bar -baz`, "foo" would be the first positional argument.
Positional arguments are consumed in the order of their declaration.

```odin
// Adds a positional string argument. Any input is accepted as a string.
pos_string :: proc(placeholder: string, help_message := "", loc := #caller_location) -> string
```
```odin
// Adds a positional integer argument. Any input that is a valid integer in Odin syntax is accepted.
pos_int :: proc(placeholder: string, help_message := "", loc := #caller_location) -> int
```

## Flag and Count Arguments

Flags and count arguments are in the format `-name` and may appear zero or more times anywhere in the array of arguments.
The value of a count argument is the amount of times it appears in the arguments, and the value of a flag argument is true if it appears one or more times.

```odin
flag :: proc(name: string, help_message := "") -> bool
```
```odin
count :: proc(name: string, help_message := "") -> int
```

# Optional Arguments

Optional arguments are in the format `-name:value` and may appear once anywhere in the array of arguments.
The value of the argument is the result of parsing the value part of the argument, or the `nil` if the argument does isn't used or parsing failed.

```odin
// Adds an optional string argument. Any value is accepted as a string.
opt_string :: proc(name: string, help_message := "", loc := #caller_location) -> Maybe(string)
```
```odin
// Adds an optional integer argument. Any input that is a valid integer in Odin syntax is accepted.
opt_int :: proc(name: string, help_message := "", loc := #caller_location) -> Maybe(int)
```