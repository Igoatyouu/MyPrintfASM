
section .text
    global _my_printf           ; void _my_printf(char const *format, ...);
    extern _my_buffchar
    extern _my_buffstr
    extern _my_buffnbr
    extern _my_buffdouble


_my_printf:
    push rbp
    mov rbp, rsp
    sub rsp, 224                     ; Stack cookie ?
    test al, al                      ; is there a float parameters ?
    jz .setup
    mov dword [rbp-216], 0           ; counter of float arguments used (max 128 = (8 registers * 16 size))
    lea rax, qword [rbp-128]         ; get ptr to the float register arguments
    mov qword [rbp-224], rax         ; store this ptr
    movaps [rbp-16], xmm7            ; store every float register arguments to the stack
    movaps [rbp-32], xmm6
    movaps [rbp-48], xmm5
    movaps [rbp-64], xmm4
    movaps [rbp-80], xmm3
    movaps [rbp-96], xmm2
    movaps [rbp-112], xmm1
    movaps [rbp-128], xmm0
.setup:
    mov qword [rbp-144], r9         ; store every classic register arguments to the stack
    mov qword [rbp-152], r8
    mov qword [rbp-160], rcx
    mov qword [rbp-168], rdx
    mov qword [rbp-176], rsi
    lea rax, qword [rbp+16]          ; get ptr to the stack arguments
    mov qword [rbp-184], rax         ; store this ptr
    lea rax, qword [rbp-176]         ; get ptr to the classic register arguments (including space for rdi format)
    mov qword [rbp-192], rax         ; store this ptr
    mov dword [rbp-200], 0           ; counter of classic arguments used (max 40 = (5 registers * 8 size))
    mov qword [rbp-208], rdi         ; store format for va_start
_my_printf_loop:
    mov rdi, qword [rbp-208]             ; get format string
    cmp byte [rdi], 0
    je _my_printf_exit              ; end format string reached
    jmp _my_printf_handleflags
_my_printf_loop_skipflag:           ; classic print char without flags
    mov dil, byte [rdi]
    call _my_buffchar wrt ..plt
    inc qword [rbp-208]
    jmp _my_printf_loop
_my_printf_exit:
    mov rsp, rbp
    pop rbp
    ret


_my_printf_handleflags:
    cmp byte [rdi], '%'
    jne _my_printf_loop_skipflag    ; skip flags checking
    mov sil, byte [rdi+1]
.sflag:
    cmp sil, 's'               ; check '%s' flag
    jne .cflag
    call _my_printf_printstr
    jmp .loop_isflag
.cflag:
    cmp sil, 'c'               ; check '%c' flag
    jne .dflag
    call _my_printf_printchar
    jmp .loop_isflag
.dflag:
    cmp sil, 'd'               ; check '%d' flag
    jne .fflag
    call _my_printf_printnbr
    jmp .loop_isflag
.fflag:
    cmp sil, 'f'               ; check '%f' flag
    jne _my_printf_loop_skipflag
    call _my_printf_printfloat
.loop_isflag:
    add qword [rbp-208], 2      ; skip two chars from the format string (skip current flag)
    jmp _my_printf_loop


_my_printf_getarg:
   mov eax, dword [rdi]              ; check use register or stack
   lea rdx, [rbp-216]               ; get float counter address
   cmp rdi, rdx                     ; compare with current counter address
   je .getarg_float                 ; if same address, we want float arg
.getarg_classic:
   cmp eax, 40                      ; check use register or stack (max 40 = (5 registers * 8 size))
   jge .getstack_classic
.getregister_classic:                ; get argument from next classic register
   mov rax, qword [rbp-192]         ; get classic registers ptr
   xor rdx, rdx
   mov edx, dword [rdi]             ; get offset current registers
   add rax, rdx                     ; get current register param by offset
   add dword [rdi], 8               ; update new register counter (8 for next classic param)
   ret
.getstack_classic:
   mov rax, qword [rbp-184]         ; get current stack param by stack ptr
   mov rax, [rax]                   ; get value from stack
   add qword [rbp-184], 8           ; update stack ptr to the next stack param
   ret

.getarg_float:
   cmp eax, 128                     ; check use register or stack (max 128 = (8 registers * 16 size))
   jge .getstack_float
.getregister_float:                  ; get argument from next float register
   mov rax, qword [rbp-224]         ; get float registers ptr
   xor rdx, rdx
   mov edx, dword [rdi]             ; get offset current registers
   add rax, rdx                     ; get current register param by offset
   add dword [rdi], 16              ; update new register counter (16 for next xmm param)
   ret
.getstack_float:
   mov rax, qword [rbp-184]         ; get current stack param by stack ptr
   mov rax, [rax]                   ; get value from stack
   add qword [rbp-184], 16          ; update stack ptr to the next float param
   ret


_my_printf_printstr:
    lea rdi, qword [rbp-200]           ; get counter for registers used
    call _my_printf_getarg
.printarg:
    mov rax, qword [rax]
    mov rdi, rax
    call _my_buffstr wrt ..plt         ; print the argument
    ret


_my_printf_printchar:
    lea rdi, qword [rbp-200]           ; get counter for registers used
    call _my_printf_getarg
.printarg:
    mov rdi, rax
    mov dil, byte [rdi]
    call _my_buffchar wrt ..plt
    ret


_my_printf_printnbr:
    lea rdi, qword [rbp-200]           ; get counter for registers used
    call _my_printf_getarg
.printarg:
    mov edi, dword [rax]
    call _my_buffnbr wrt ..plt
    ret

_my_printf_printfloat:
    lea rdi, qword [rbp-216]           ; get counter for registers used
    call _my_printf_getarg
    movsd xmm0, [rax]
    lea rdi, qword [rbp-200]           ; get counter for registers used
    call _my_printf_getarg
    mov edi, dword [rax]
.printarg:
    call _my_buffdouble wrt ..plt
    ret
