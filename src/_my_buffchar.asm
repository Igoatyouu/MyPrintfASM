
section .data
    buffer_array: db 4096 dup(0)
    buffer_size: dw 0
    ten: dq 10.0

section .text
    global _my_buffchar     ; void _my_buffchar(char c);
    global _my_buffstr      ; void _my_buffstr(const char *str);
    global _my_buffnbr      ; void _my_buffnbr(int nb);
    global _my_buffdouble   ; void _my_buffdouble(double nb, int precision);
    global _fini

_fini:
    call _my_flushbuff
    ret

_my_flushbuff:                      ; flush the buffer into stdout
    lea rcx, [rel buffer_size]
    lea rsi, [rel buffer_array]
    test rcx, rcx
    jz .exit
.flush:
    mov edx, dword [rcx]
    mov rax, 1
    mov rdi, rax
    syscall
    lea rcx, [rel buffer_size]
    mov dword [rcx], 0
.exit:
    ret

_my_buffchar:                       ; bufferize a character
    lea rcx, [rel buffer_size]
    lea rsi, [rel buffer_array]
    test dil, dil
    jz .skipadd
    mov edx, dword [rcx]
    mov byte [rsi+rdx], dil
    inc dword [rcx]
.skipadd:
    test rcx, rcx
    jz .exit
    cmp dil, 10
    je .print
    cmp dword [rcx], 4096
    jl .exit
.print:
    mov edx, dword [rcx]
    mov rax, 1
    mov rdi, rax
    syscall
    lea rcx, [rel buffer_size]
    mov dword [rcx], 0
.exit:
    ret


_my_buffstr:            ; bufferize a whole char *
    mov r10, rdi
.loop:
    cmp byte [r10], 0
    je .exit
    mov dil, byte [r10]
    call _my_buffchar
    inc r10
    jmp .loop
.exit:
    ret


_my_intlen:               ; get the len of an int (character by character, e.g. 5120 = 1000)
    push rbp
    mov rbp, rsp
    sub rsp, 12
    mov dword [rbp-12], 10
    mov dword [rbp-8], 10
    mov dword [rbp-4], edi
    mov eax, dword [rbp-4]
    test eax, eax
    jz .exit
.loop:
    mov eax, dword [rbp-4]
    xor rdx, rdx
    idiv dword [rbp-8]
    test eax, eax
    jz .exit
    mov eax, dword [rbp-8]
    imul dword [rbp-12]
    mov dword [rbp-8], eax
    jmp .loop
.exit:
    xor rax, rax
    mov eax, dword [rbp-8]
    xor rdx, rdx
    idiv dword [rbp-12]
    mov rsp, rbp
    pop rbp
    ret


_my_buffnbr:                        ; Bufferize a number as an int
    push rbp
    mov rbp, rsp
    sub rsp, 12
    mov dword [rbp-8], 10
    mov dword [rbp-12], edi
    cmp edi, 0
    jge .skip_negativenbr
    mov dil, '-'
    call _my_buffchar
    neg dword [rbp-12]
.skip_negativenbr:
    mov edi, dword [rbp-12]
    call _my_intlen
    mov dword [rbp-4], eax
.loop:
    mov eax, dword [rbp-12]
    xor rdx, rdx
    idiv dword [rbp-4]
    xor rdx, rdx
    idiv dword [rbp-8]
    xor rdi, rdi
    mov dil, dl
    add dil, '0'
    call _my_buffchar
    mov eax, dword [rbp-4]
    xor rdx, rdx
    idiv dword [rbp-8]
    test eax, eax
    jz .exit
    mov dword [rbp-4], eax
    jmp .loop
.exit:
    mov rsp, rbp
    pop rbp
    ret

_my_buffdouble:                     ; Bufferize a number as a double double
    push rbp
    mov rbp, rsp
    sub rsp, 20
    movsd [rbp-16], xmm0
    mov dword [rbp-20], edi
    test edi, edi
    js .exit
    xorpd xmm1, xmm1
    ucomisd xmm0, xmm1
    jae .skip_negative
    mov dil, '-'
    call _my_buffchar
    movsd xmm0, [rbp-16]
    xorpd xmm0, xmm0
    subsd xmm0, [rbp-16]            ; xmm0 = -xmm0
    movsd [rbp-16], xmm0
.skip_negative:
    movsd xmm0, [rbp-16]            ; integer part
    cvttsd2si rdi, xmm0
    call _my_buffnbr
    mov ecx, dword [rbp-20]        ; Counter for 6 decimals
    test ecx, ecx
    jz .exit
    mov dil, '.'
    call _my_buffchar
    movsd xmm0, [rbp-16]             ; decimal part
    cvttsd2si rax, xmm0
    cvtsi2sd xmm1, rax
    subsd xmm0, xmm1               ; remove int part
    mov ecx, dword [rbp-20]
.decimal_loop:
    mulsd xmm0, [rel ten]
    cvttsd2si rdi, xmm0
    push rcx
    movsd [rbp-16], xmm0
    call _my_buffnbr
    movsd xmm0, [rbp-16]
    pop rcx
    cvttsd2si rax, xmm0
    cvtsi2sd xmm1, rax
    subsd xmm0, xmm1             ; Remove int part
    dec ecx
    jnz .decimal_loop
.exit:
    mov rsp, rbp
    pop rbp
    ret
