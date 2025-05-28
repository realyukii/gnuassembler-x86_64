.equ SYS_EXIT,		60
.equ SYS_GETPID,	39
.equ SYS_WRITE,		1

.equ STDOUT_FILENO,	1

.section .bss
ascii_digit:
	.space 16, 0

.section .text
.global _start

print_pid:
	movl	$SYS_GETPID, %eax
	syscall

	/* convert pid number to ascii */
	movl	%eax, %edi
	leaq	ascii_digit(%rip), %rsi
	callq	int_to_ascii
	/* store the digit length */
	movl	%eax, %ebx

	movl	$SYS_WRITE, %eax
	movl	$STDOUT_FILENO, %edi
	movq	$pid_str, %rsi
	movl	$pid_str_len, %edx
	syscall

	movl	$SYS_WRITE, %eax
	movl	$STDOUT_FILENO, %edi
	movq	$ascii_digit, %rsi
	movl	%ebx, %edx
	syscall

	movl	$SYS_WRITE, %eax
	movl	$STDOUT_FILENO, %edi
	movq	$newline, %rsi
	movl	$1, %edx
	syscall

	retq

main:
	callq	print_pid

	xorl	%eax, %eax
	retq

_start:
	callq	main

	movl	%eax, %edi
	movl	$SYS_EXIT, %eax
	syscall

pid_str:
	.string "process id: "
	pid_str_len = . - pid_str
newline:
	.ascii "\n"
