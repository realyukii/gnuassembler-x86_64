#define __NR_write	1
#define STDIN_FILENO	1

.extern xorstr
.extern puts
.extern printf

.global main

.section .rodata
privkey_str:
	.string "your private key: %s\n"

enc_result_str:
	.string "ciphertext: 0x%02X\n"

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
	movl	$STDIN_FILENO, %edi
	leaq	usage_str(%rip), %rsi
	movl	$usage_str_len, %edx
	syscall

	retq

encrypt:
	/* TODO */
	callq	printf
decrypt:

main:
	/* compare argc with 3 */
	cmpl	$3, %edi
	jne	.invalid_usage

	leaq	enc_result_str(%rip), %rdi
	callq	puts

	jmp	.exit

.invalid_usage:
	callq	print_usage

.exit:
	xorl	%eax, %eax
	retq
