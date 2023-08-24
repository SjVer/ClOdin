package test

import "core:testing"
import "core:log"
import "core:os"
import "clodin"

logger := log.create_console_logger(
	opt = {.Terminal_Color, .Level, .Short_File_Path, .Line}
)

@test
test_all :: proc(t: ^testing.T) {
	context.logger = logger
	args := []string{"foo", "-bar", "-faz", "-faz", "-faz", "-baz:123"}

	clodin.start(args)
	
	foo := clodin.pos_string("FOO")
	bar := clodin.flag("bar")
	faz := clodin.count("faz")
	baz := clodin.opt_int("baz")
	
	testing.expect(t, clodin.finish())
	testing.expect_value(t, foo, "foo")
	testing.expect_value(t, bar, true)
	testing.expect_value(t, baz, 123)
	testing.expect_value(t, faz, 3)
}

@test
test_help :: proc(t: ^testing.T) {
	context.logger = logger

	clodin.start({"-help"})

	_ = clodin.pos_string("FOO", "This is foo.")
	_ = clodin.flag("bar")
	_ = clodin.count("faz", "This is faz.")
	_ = clodin.opt_int("baz", "This is baz.")

	testing.expect(t, !clodin.finish())
}

@test
test_invalid_pos :: proc(t: ^testing.T) {
	context.logger = logger

	clodin.exit_on_failure = false
	clodin.start({"not_an_int"})

	foo := clodin.pos_int("FOO")

	testing.expect(t, !clodin.finish())
	testing.expect_value(t, foo, 0)
}