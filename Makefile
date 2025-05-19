all: build/linux_syscall build/function_call

build/linux_syscall: ./linux_syscall.S
	as ./linux_syscall.S -o ./build/linux_syscall.o
	ld ./build/linux_syscall.o -o ./build/linux_syscall

build/function_call: ./function_call.S
	as ./function_call.S -o ./build/function_call.o
	ld ./build/function_call.o -o ./build/function_call

