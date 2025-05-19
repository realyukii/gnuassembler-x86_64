.equ SYS_EXIT,		60
.equ SYS_GETPID,	39
.equ SYS_WRITE,		1

.equ STDOUT_FILENO,	1
.section .bss
ascii_digit:
	.space 16, 0

.section .text
.global _start

/* credit: https://stackoverflow.com/a/9114996/22382954
* unsigned int int_to_ascii(unsigned int number)
*/
int_to_ascii:
	movl	%edi, %eax		/* number to be converted */
	movl	$10, %ecx		/* divisor */
	xorl	%ebx, %ebx		/* count digits */

.divide:
	xorl	%edx, %edx		/* high part = 0 */
	divl	%ecx			/* eax = eax/ecx, edx = remainder */
	pushq	%rdx			/* rdx is a digit in range [0..9] */
	incl	%ebx			/* count digits */
	testl	%eax, %eax		/* EAX is 0? */
	jnz		.divide			/* no, continue */

	/* POP digits from stack in reverse order */
	movl	%ebx, %ecx				/* number of digits */
	leaq	ascii_digit(%rip), %rsi	/* load address to %rsi */
.next_digit:
	popq	%rax
	addb	$'0', %al			/* convert to ASCII */
	movl	%eax, (%rsi)	/* write it to the buffer */
	incq	%rsi
	loop .next_digit
	
	movl	%ebx, %eax
	retq

print_pid:
	movl	$SYS_GETPID, %eax
	syscall

	/* convert pid number to ascii */
	movl	%eax, %edi
	callq	int_to_ascii
	/* store the digit length */
	movl	%eax, %ebx

	movl	$SYS_WRITE, %eax
	movl	$STDOUT_FILENO, %edi
	leaq	pid_str(%rip), %rsi
	movl	$pid_str_len, %edx
	syscall

	movl	$SYS_WRITE, %eax
	movl	$STDOUT_FILENO, %edi
	leaq	ascii_digit(%rip), %rsi
	movl	%ebx, %edx
	syscall

	movl	$SYS_WRITE, %eax
	movl	$STDOUT_FILENO, %edi
	leaq	newline(%rip), %rsi
	movl	$1, %edx
	syscall

	retq

main:
	callq	print_pid

	xorl	%eax, %eax
	retq

_start:
	callq	main

	movl	$SYS_EXIT, %eax
	syscall

pid_str:
	.string "process id: "
	pid_str_len = . - pid_str
newline:
	.ascii "\n"
