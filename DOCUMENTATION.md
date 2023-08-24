# ClOdin API

ClOdin allows you to easily and consistently parse command-line arguments for your Odin programs. The API is designed to follow the style of the command-line interface of Odin's official compiler and be as simple as possible, with almost no boilerplate.

## Positional Arguments

Positional arguments are arguments that are not denoted by a prefix like `-foo:`, and must be supplied.
For example, in `my_program.exe foo bar -baz`, "foo" would be the first positional argument.
Positional arguments are consumed in the order of their declaration.

### pos_string

Adds a positional string argument. Any input is accepted as a string.
```odin
pos_string :: proc(placeholder: string, help_message := "", loc := #caller_location) -> string
```

### pos_int

Adds a positional integer argument. Any input that is a valid integer in Odin syntax is accepted.
```odin
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