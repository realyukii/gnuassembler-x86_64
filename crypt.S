#define __NR_write	1
#define STDOUT_FILENO	1
#define ARGV0_POS	0
#define ARGV1_POS	ARGV0_POS + 8
#define ARGV2_POS	ARGV1_POS + 8

.extern xorstr
.extern rand
.extern puts
.extern printf

.global main

.section .rodata
privkey_str:
	.string "your private key: %d\n"

enc_result_str:
	.string "ciphertext: "
	enc_result_str_len = . - enc_result_str

enc_fmt_str:
	.string "0x%02X "

empty:
	.ascii "\0"

usage_str:
	.string "usage: crypt <enc|dec> <bytes>\n"
	usage_str_len = . - usage_str

enc_str:
	.string "enc"
	enc_str_len = . - enc_str

dec_str:
	.string "dec"
	dec_str_len = . - dec_str

.section .text
print_usage:
	movl	$__NR_write, %eax
	movl	$STDOUT_FILENO, %edi
	leaq	usage_str(%rip), %rsi
	movl	$usage_str_len, %edx
	syscall

	retq

/*
* void encrypt(char *plaintext)
*/
encrypt:
	push	%rbx
	push	%rbp
	push	%r12
	push	%r13

	/* save plaintext to register %rbp */
	movq	%rdi, %rbp

	/* generate private key and store it on register %rbx */
	callq	rand
	movl	%eax, %ebx

	leaq	privkey_str(%rip), %rdi
	movl	%eax, %esi
	xorl	%eax, %eax
	callq	printf

	/* calculate the length of plaintext and store it on register %r12 */
	movq	%rbp, %rdi
	callq	strlen
	movl	%eax, %r12d

	movq	%rbp, %rdi
	movl	%eax, %esi
	movl	%ebx, %edx
	callq	xorstr

	movl	$STDOUT_FILENO, %edi
	leaq	enc_result_str(%rip), %rsi
	movl	$enc_result_str_len, %edx
	movl	$__NR_write, %eax
	syscall

	/* use register %r13 as index and counter of the loop */
	xorl	%r13d, %r13d
.print_ciphertext:
	leaq	enc_fmt_str(%rip), %rdi
	/*
	* zeroing upper bits of %rsi as in the subsequent line,
	* we only use the 8-bit lower bits
	*/
	xorl	%esi, %esi
	movb	(%rbp, %r13), %sil
	xorl	%eax, %eax
	callq	printf

	incl	%r13d
	cmpl	%r12d, %r13d
	jne	.print_ciphertext

	leaq	empty(%rip), %rdi
	callq	puts

	popq	%r13
	popq	%r12
	popq	%rbp
	popq	%rbx
	retq

decrypt:
	/* TODO */

main:
	/* TODO: check argv[1] == "enc" or argv[1] == "dec" */

	/* compare argc with 3 */
	cmpl	$3, %edi
	jne	.invalid_usage

	movq	ARGV2_POS(%rsi), %rdi
	callq	encrypt

	jmp	.exit

.invalid_usage:
	callq	print_usage

.exit:
	xorl	%eax, %eax
	retq
