analyze result of disassembled xorstr function:
```
gef➤  disassemble xorstr 
Dump of assembler code for function xorstr:
	 0x0000555555555199 <+0>:     push   %rbp
	 0x000055555555519a <+1>:     mov    %rsp,%rbp
	 0x000055555555519d <+4>:     mov    %rdi,-0x18(%rbp)
	 0x00005555555551a1 <+8>:     mov    %esi,-0x1c(%rbp)
	 0x00005555555551a4 <+11>:    mov    %rdx,-0x28(%rbp)
=> 0x00005555555551a8 <+15>:    movq   $0x0,-0x8(%rbp)
	 0x00005555555551b0 <+23>:    jmp    0x5555555551dc <xorstr+67>
	 0x00005555555551b2 <+25>:    mov    -0x18(%rbp),%rdx
	 0x00005555555551b6 <+29>:    mov    -0x8(%rbp),%rax
	 0x00005555555551ba <+33>:    add    %rdx,%rax
	 0x00005555555551bd <+36>:    movzbl (%rax),%ecx
	 0x00005555555551c0 <+39>:    mov    -0x28(%rbp),%rax
	 0x00005555555551c4 <+43>:    mov    %eax,%esi
	 0x00005555555551c6 <+45>:    mov    -0x18(%rbp),%rdx
	 0x00005555555551ca <+49>:    mov    -0x8(%rbp),%rax
	 0x00005555555551ce <+53>:    add    %rdx,%rax
	 0x00005555555551d1 <+56>:    xor    %esi,%ecx
	 0x00005555555551d3 <+58>:    mov    %ecx,%edx
	 0x00005555555551d5 <+60>:    mov    %dl,(%rax)
	 0x00005555555551d7 <+62>:    addq   $0x1,-0x8(%rbp)
	 0x00005555555551dc <+67>:    mov    -0x1c(%rbp),%eax
	 0x00005555555551df <+70>:    cltq
	 0x00005555555551e1 <+72>:    cmp    %rax,-0x8(%rbp)
	 0x00005555555551e5 <+76>:    jb     0x5555555551b2 <xorstr+25>
	 0x00005555555551e7 <+78>:    nop
	 0x00005555555551e8 <+79>:    nop
	 0x00005555555551e9 <+80>:    pop    %rbp
	 0x00005555555551ea <+81>:    ret
End of assembler dump.
```

prologue:
```
	 0x0000555555555199 <+0>:     push   %rbp
	 0x000055555555519a <+1>:     mov    %rsp,%rbp
```

move passed function arguments from register to stack:
```
	 0x000055555555519d <+4>:     mov    %rdi,-0x18(%rbp)		/* str ptr */
	 0x00005555555551a1 <+8>:     mov    %esi,-0x1c(%rbp)		/* len */
	 0x00005555555551a4 <+11>:    mov    %rdx,-0x28(%rbp)		/* randomkey */
```

initialize local variable:
```
=> 0x00005555555551a8 <+15>:    movq   $0x0,-0x8(%rbp)		/* variable i as counter */
```

loop structure, condition expression:
```
	 0x00005555555551b0 <+23>:    jmp    0x5555555551dc <xorstr+67>
	 ...
	 0x00005555555551dc <+67>:    mov    -0x1c(%rbp),%eax
	 0x00005555555551df <+70>:    cltq
	 0x00005555555551e1 <+72>:    cmp    %rax,-0x8(%rbp)
	 0x00005555555551e5 <+76>:    jb     0x5555555551b2 <xorstr+25>
```

code execution block inside loop:
```
	 0x00005555555551b2 <+25>:    mov    -0x18(%rbp),%rdx		/* move str ptr to register rdx */
	 0x00005555555551b6 <+29>:    mov    -0x8(%rbp),%rax		/* move the counter to register rax */
	 0x00005555555551ba <+33>:    add    %rdx,%rax					/* increment rax with ptr (think of it as commutative property in math, it has the same effect no matter how you order it, increment the ptr.) */

	 0x00005555555551bd <+36>:    movzbl (%rax),%ecx				/* mov a byte from dereferenced ptr stored in rax to register ecx and zero extend the ecx */
	 0x00005555555551c0 <+39>:    mov    -0x28(%rbp),%rax		/* mov randomkey to rax */
	 0x00005555555551c4 <+43>:    mov    %eax,%esi					/* assign register esi with randomkey */

	 0x00005555555551c6 <+45>:    mov    -0x18(%rbp),%rdx		/* move str ptr to register rdx */
	 0x00005555555551ca <+49>:    mov    -0x8(%rbp),%rax		/* move the counter to register rax */
	 0x00005555555551ce <+53>:    add    %rdx,%rax					/* increment rax with ptr (think of it as commutative property in math, it has the same effect no matter how you order it, increment the ptr.) */

	 0x00005555555551d1 <+56>:    xor    %esi,%ecx					/* randomkey xor character from str ptr */
	 0x00005555555551d3 <+58>:    mov    %ecx,%edx					/* move the result to register edx */
	 0x00005555555551d5 <+60>:    mov    %dl,(%rax)					/* each loop iteration, mov 1-byte rdx to the current-offset of str */
	 0x00005555555551d7 <+62>:    addq   $0x1,-0x8(%rbp)		/* increment the counter */
```

epilogue:
```
	 0x00005555555551e7 <+78>:    nop
	 0x00005555555551e8 <+79>:    nop
	 0x00005555555551e9 <+80>:    pop    %rbp
	 0x00005555555551ea <+81>:    ret
```
