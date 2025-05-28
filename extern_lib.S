/* tell the linker that the following label is globlaly or publlicly exposed */
.global strlen
.global int_to_ascii

.section .text
/*
* int strlen(char *str)
* iterate the str until it find null-terminated byte and return its length
*/
strlen:
	/* total length, the counter */
	xorl	%eax, %eax
.start_count:
	cmpb	$0, (%rdi, %rax)
	je	.finish
	incl	%eax
	jmp	.start_count
.finish:
	retq

/*
* int int_to_ascii(int number, char *ascii_int)
* the function will convert number to an ascii-version
*
* int number: number to be converted
* char *ascii_int: a pointer for storing the result of operation
* return the length of data written into ascii_int
*
* credit: https://stackoverflow.com/a/9114996/22382954
* unsigned int int_to_ascii(unsigned int number)
* ChatGPT discussion:
* https://chatgpt.com/share/682b3a7b-1164-8002-982d-f36ac8718ae5
*/
int_to_ascii:
	movl	%edi, %eax	/* number to be converted */

	movl	$10, %ecx	/* divisor */
	xorl	%ebx, %ebx	/* count digits */

.divide:
	xorl	%edx, %edx	/* high part = 0 */
	divl	%ecx		/* eax = eax/ecx, edx = remainder */
	pushq	%rdx		/* rdx is a digit in range [0..9] */
	incl	%ebx		/* count digits */
	testl	%eax, %eax	/* EAX is 0? */
	jnz	.divide		/* no, continue to the next loop */

	/*
	* POP digits from stack in reverse order
	*/
	movl	%ebx, %ecx	/* number of digits */
.next_digit:
	popq	%rax
	addb	$'0', %al	/* convert to ASCII */
	movl	%eax, (%rsi)	/* write it to the buffer */
	incq	%rsi
	loop	.next_digit
	
	movl	%ebx, %eax
	retq
