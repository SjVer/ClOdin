.PHONY: build
build: bin/
	odin build clodin -build-mode:shared -out:bin/clodin.so

.PHONY: test
test: bin/
	odin test tests.odin -file -out:bin/tests

bin/:
	mkdir bin