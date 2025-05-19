build/linux_syscall:
	as ./linux_syscall.S -o ./build/linux_syscall.o
	ld ./build/linux_syscall.o -o ./build/linux_syscall