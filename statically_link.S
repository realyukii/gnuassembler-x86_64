.equ SYS_EXIT, 60
.equ SYS_WRITE, 1

.equ STDOUT_FILENO, 1

.extern strlen
.extern int_to_ascii

.section .bss
ascii_digit:
	.space 16, 0

.section .rodata
str_literal:
	.string "this is an array of character\n"
str_length:
	.string "the length: "
newline:
	.ascii "\n"

.section .text
.global _start
_start:
	pushq	%rbx
	
	leaq	str_literal(%rip), %rdi
	callq	strlen

	movl	%eax, %edx
	leaq	str_literal(%rip), %rsi
	movl	$STDOUT_FILENO, %edi
	movl	$SYS_WRITE, %eax
	syscall
	
	/* store length of str_literal */
	movl	%eax, %ebx

	/*
	* count length at assemble-time with GNU assembler is possible
	* see:
	* - https://sourceware.org/binutils/docs/as/Dot.html
	* - https://stackoverflow.com/a/11375043/22382954
	* but let's see if we have another option.
	*/
	leaq	str_length(%rip), %rdi
	callq	strlen

	movl	%eax, %edx
	leaq	str_length(%rip), %rsi
	movl	$STDOUT_FILENO, %edi
	movl	$SYS_WRITE, %eax
	syscall

	movl	%ebx, %edi
	leaq	ascii_digit(%rip), %rsi
	callq	int_to_ascii

	movl	%eax, %edx
	leaq	ascii_digit(%rip), %rsi
	movl	$STDOUT_FILENO, %edi
	movl	$SYS_WRITE, %eax
	syscall

	movl	$1, %edx
	leaq	newline(%rip), %rsi
	movl	$STDOUT_FILENO, %edi
	movl	$SYS_WRITE, %eax
	syscall

	popq	%rbx

	xorl	%edi, %edi
	movl	$SYS_EXIT, %eax
	syscall
