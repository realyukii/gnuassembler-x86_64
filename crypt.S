#define __NR_write	1
#define STDOUT_FILENO	1
#define ARGV0_POS	0
#define ARGV1_POS	ARGV0_POS + 8
#define ARGV2_POS	ARGV1_POS + 8
#define ARGV3_POS	ARGV2_POS + 8

.extern xorstr
.extern datahex
.extern atoi
.extern rand
.extern srand
.extern time
.extern puts
.extern printf

.global main

.section .rodata
privkey_str:
	.string "your private key: %d\n"

failed_to_decrypt:
	.string "failed to decrypt, make sure the supplied ascii-hex is a valid one.\n"
	failed_to_decrypt_len = . - failed_to_decrypt

dec_result_str:
	.string "decrypted text: %s\n"

readable_enc_result_str:
	.string "readable ciphertext: "
	readable_enc_result_str_len = . - readable_enc_result_str

copyable_enc_result_str:
	.string "copyable ciphertext: "
	copyable_enc_result_str_len = . - copyable_enc_result_str

enc_fmt_str:
	.string "0x%02X "

enc_2nd_fmt_str:
	.string "%02X"

empty:
	.ascii "\0"

usage_str:
	.string "usage: crypt <enc|dec> <bytes> [private key]\n"
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

	xorl	%edi, %edi
	callq	time

	movq	%rax, %rdi
	callq	srand

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

	/* readable */
	movl	$STDOUT_FILENO, %edi
	leaq	readable_enc_result_str(%rip), %rsi
	movl	$readable_enc_result_str_len, %edx
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

	/* copyable */
	movl	$STDOUT_FILENO, %edi
	leaq	copyable_enc_result_str(%rip), %rsi
	movl	$copyable_enc_result_str_len, %edx
	movl	$__NR_write, %eax
	syscall

	/* use register %r13 as index and counter of the loop */
	xorl	%r13d, %r13d
.print_ciphertext_2nd:
	leaq	enc_2nd_fmt_str(%rip), %rdi
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
	jne	.print_ciphertext_2nd

	leaq	empty(%rip), %rdi
	callq	puts

	popq	%r13
	popq	%r12
	popq	%rbp
	popq	%rbx
	retq

/*
* void decrypt(char *ascii_hex, char *private_key)
*/
decrypt:
	pushq	%rbx
	pushq	%rbp
	pushq	%r12
	pushq	%r13

	movq	%rdi, %r12
	movq	%rsi, %rbx

	callq	datahex

	/* if datahex return NULL, the supplied ascii_hex is invalid */
	testq	%rax, %rax
	je	.error

	/* store pointer created by malloc in register %rbp */
	movq	%rax, %rbp

	/* count length of ascii_hex and divide it by two */
	movq	%r12, %rdi
	callq	strlen
	movl	%eax, %r13d

	/*
	* assuming the supplied ascii-hex is even,
	* get the actual length by divide it with two
	*
	* actually, it's not an assumption, datahex will return NULL
	* if the supplied ascii_hex not even
	*/
	xorl	%edx, %edx
	movl	$2, %ecx
	divl	%ecx
	/* add null-byte at the end of decrypted-string */
	movl	$0, (%rbp, %rax)
	movl	%eax, %r13d

	movq	%rbx, %rdi
	call	atoi

	movq	%rbp, %rdi
	movl	%r13d, %esi
	movl	%eax, %edx
	callq	xorstr

	leaq	dec_result_str(%rip), %rdi
	movq	%rbp, %rsi
	xorl	%eax, %eax
	callq	printf

	jmp	.exit_dec
.error:
	movl	$STDOUT_FILENO, %edi
	leaq	failed_to_decrypt(%rip), %rsi
	movl	$failed_to_decrypt_len, %edx
	movl	$__NR_write, %eax
	syscall
.exit_dec:
	popq	%r13
	popq	%r12
	popq	%rbp
	popq	%rbx
	retq

main:
	pushq	%rbx
	pushq	%rbp

	/* store char **argv in register %rbx */
	movq	%rsi, %rbx
	/* store argc in register %rbp */
	movl	%edi, %ebp

	/* jump to usage if argc < 3 */
	cmpl	$3, %edi
	jl	.invalid_usage

	/* check argv[1] == "enc" or argv[1] == "dec" */
	leaq	enc_str(%rip), %rdi
	movq	ARGV1_POS(%rbx), %rsi
	movl	$enc_str_len, %edx
	callq	strncmp

	testl	%eax, %eax
	je	.handle_encrypt

	leaq	dec_str(%rip), %rdi
	movq	ARGV1_POS(%rbx), %rsi
	movl	$dec_str_len, %edx
	callq	strncmp

	testl	%eax, %eax
	je	.handle_decrypt

	jmp	.invalid_usage

.handle_encrypt:
	movq	ARGV2_POS(%rbx), %rdi
	callq	encrypt

	jmp	.exit

.handle_decrypt:
	/* compare argc with 4 */
	cmpl	$4, %ebp
	jne	.invalid_usage

	movq	ARGV2_POS(%rbx), %rdi
	movq	ARGV3_POS(%rbx), %rsi
	callq	decrypt

	jmp	.exit

.invalid_usage:
	callq	print_usage

.exit:
	popq	%rbp
	popq	%rbx
	xorl	%eax, %eax
	retq
