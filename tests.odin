package test

import "core:testing"
import "core:log"
import "clodin"

logger := log.create_console_logger(
    opt = {.Terminal_Color, .Level, .Short_File_Path, .Line}
)

@test
test_all :: proc(t: ^testing.T) {
    context.logger = logger
    args := []string{"foo", "-bar", "-faz", "-faz", "-faz", "-baz:123"}

    clodin.start(args)
    
    foo := clodin.pos_string("FOO", "this is foo")
    bar := clodin.flag("bar", "this is bar")
    faz := clodin.count("faz", "this is faz")
    baz := clodin.opt_int("baz", "this is baz")
    
    testing.expect(t, clodin.finish())
    testing.expect_value(t, foo, "foo")
    testing.expect_value(t, bar, true)
    testing.expect_value(t, baz, 123)
    testing.expect_value(t, faz, 3)
}