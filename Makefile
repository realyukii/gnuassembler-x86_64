all: build/linux_syscall build/function_call build/simplexor build/statically_linked build/crypt

build/linux_syscall: ./linux_syscall.S
	as ./linux_syscall.S -o ./build/linux_syscall.o
	ld ./build/linux_syscall.o -o ./build/linux_syscall

build/function_call: ./build/extern_lib.o ./function_call.S
	as ./function_call.S -o ./build/function_call.o
	ld ./build/extern_lib.o ./build/function_call.o -o ./build/function_call

build/simplexor: ./xor.c
	gcc ./xor.c -o $@

build/crypt: ./extern_routine.c ./crypt.S
	gcc $^ -o $@

build/statically_linked: ./build/statically_linked.o ./build/extern_lib.o
	ld $^ -o $@

build/statically_linked.o: ./statically_link.S
	as ./statically_link.S -o $@

build/extern_lib.o: ./extern_lib.S
	as ./extern_lib.S -o $@
