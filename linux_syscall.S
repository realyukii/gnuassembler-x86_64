.equ SYS_EXIT,		60
.equ SYS_WRITE,		1

.equ STDOUT_FILENO,	1

.section .text
.global _start
_start:
	movl		$SYS_WRITE, %eax
	movl		$STDOUT_FILENO, %edi
	leaq		hello_str, %rsi
	movl		$hello_str_len, %edx
	syscall

	movl		$SYS_EXIT, %eax
	xorl		%edi, %edi
	syscall

hello_str:
	.string "hello wurld"
	hello_str_len = . - hello_str
