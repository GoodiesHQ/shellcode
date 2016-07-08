section .text
global _main
_main:
    %define LOADLIBA ebp - 4
    %define PROCADDR ebp - 8
    push ebp
    mov ebp, esp
    sub esp, 8

    xor edx, edx
  	push edx              ; Null terminator
  	push DWORD 0x41797261	; Ayra
  	push DWORD 0x7262694c	; rbiL
  	push DWORD 0x64616f4c	; daoL
    push esp
    push DWORD 0xC         ; length of above word
    call get_k32_function
    mov [LOADLIBA], eax

    test eax, eax
    je .done

    xor edx, edx
    mov dx, 0x7373	; ss
    push edx
    push 0x65726464	; erdd
    push 0x41636f72	; Acor
    push 0x50746547	; PteG
    push esp
    push 0xE
    call get_k32_function
    mov [PROCADDR], eax

    test eax, eax
    je .done

    mov eax, [LOADLIBA]
    call .user32_dll
    db "User32.dll",0x00
    .user32_dll:
    call eax
    test eax, eax
    je .fail
    call .messageboxa
    db "MessageBoxA",0x00
    .messageboxa:
    push eax
    mov eax, [PROCADDR]
    call eax

    test eax, eax
    je .fail

    xor ebx, ebx
    push ebx
    call .lpcaption
    db "This is my caption.",0x00
    .lpcaption:
    call .lptext
    db "This is my message!",0x00
    .lptext:
    push ebx
    call eax

    jmp .done
    .fail:
    xor ebx, ebx
    inc ebx

    .done:
    mov esp, ebp
    pop ebp

    xor edx, edx
  	mov dh, 0x73	; s
  	shl edx, 8
  	mov dx, 0x7365	; se
  	push edx
  	push 0x636f7250	; corP
  	push 0x74697845	; tixE
    call get_k32_function

    push ebx
    call eax

get_k32_function:
    ;// returns the address of a function specifically in Kernel32.dll which is later used with LoadLibraryA and GetProcAddress.
    ;// push a pointer to function name and then the length of that string...
    %define KERNEL32 ebp - 4
    %define EX_TABLE ebp - 8
    %define FUNC_NAME ebp + 12
    %define FUNC_LEN ebp + 8
    push ebp
    mov ebp, esp
    sub esp, 16

    ;// reference image:                        http://3.bp.blogspot.com/-oNSLW0H7hH4/TvOh03f3kiI/AAAAAAAAAFE/UXfbLYLBcZM/s1600/PE_Structure.jpg
    ;// derived from information at:            http://fumalwareanalysis.blogspot.com/2011/12/malware-analysis-tutorial-8-pe-header.html
    call get_k32
    mov [KERNEL32], eax                         ;// save the kernel32 base address locally
    add eax, [eax + 0x3c]                       ;// Get the MS-DOS header.
    ;// IMAGE_FILE_HEADER (20 bytes) + 96 bytes (see link below) = 0x78:
    ;// MS - export table offset:               https://msdn.microsoft.com/en-us/library/windows/desktop/ms680305(v=vs.85).aspx
    mov eax, [eax + 0x78]                       ;// relative offset from the MS-DOS header to find the export table address
    add eax, [KERNEL32]                         ;// add the base address to get the actual address
    ;// take parameters from stack and move it into a local variable

    ;mov [EX_TABLE], eax                         ;// Store the export table address locally
    mov ebx, [eax + 0x20]                       ;// IMAGE_EXPORT_DIRECTORY.AddressOfNames - get the addess of function names so we can iterate through them.
    add ebx, [KERNEL32]                         ;// add the base address to get the actual address

    xor ecx, ecx                                ;// counter
    .loop:
        push ecx
        mov esi, [ebx + ecx * 4]                ;// get the relative address of the next function name
        add esi, [KERNEL32]                     ;// add the base address to get the actual address
        mov ecx, [FUNC_LEN]                     ;// length of function name for 'rep cmpsb'
        mov edx, [FUNC_NAME]
        lea edi, [edx]
        rep cmpsb
        je .loop_end
        pop ecx
        inc ecx
        cmp ecx, [eax + 0x18]                   ;// compare ECX counter with IMAGE_EXPORT_DIRECTORY.NumberOfNames
        jl .loop                                ;// if it's less than NumberOfNames, go to the next iteration
        jmp .done
    .loop_end:
        pop ebx                                 ;// this contains the index of the name/function
        mov ecx, [eax + 0x1C]                   ;// get the IMAGE_EXPORT_DIRECTORY.AddressOfFunctions relative address
        mov edx, [eax + 0x24]                   ;// get the IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals relative address
        add ecx, [KERNEL32]                     ;// add the base address to get the actual address
        add edx, [KERNEL32]                     ;// add the base address to get the actual address
        xor eax, eax
        mov ax, WORD [edx + ebx * 2]
        mov eax, [ecx + eax * 4]                ;//
        add eax, [KERNEL32]
        jmp .end
    .done:
    xor eax, eax
    .end:
    mov esp, ebp
    pop ebp
    ret

get_k32:                                        ;// returns the base address of Kernel32.dll
    xor eax, eax
    mov eax, [fs:0x30]                          ;// PEB struct
    mov eax, [eax + 0x0C]	                      ;// Ldr
    mov eax, [eax + 0x14]	                      ;// InMemoryOrderModuleList
    mov eax, [eax]                              ;// linked list entry 2
    mov eax, [eax]                              ;// linked list entry 3
    mov eax, [eax + 0x10]	                      ;// Base address of 3rd entry
    ret
