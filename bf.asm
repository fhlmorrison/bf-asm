format ELF64 executable

SYS_read = 0
SYS_write = 1
SYS_exit = 60

STDIN = 0
STDOUT = 1
STDERR = 2

macro syscall1 arg0 {
    mov rax, arg0
    syscall
}
macro syscall2 arg0, arg1 {
    mov rdi, arg1
    syscall1 arg0
}
macro syscall3 arg0, arg1, arg2 {
    mov rsi, arg2
    syscall2 arg0, arg1
}
macro syscall4 arg0, arg1, arg2, arg3 {
    mov rdx, arg3
    syscall3 arg0, arg1, arg2
}

macro write fd, msg, msg_len {
    syscall4 SYS_write, fd, msg, msg_len
}

macro read fd, msg, msg_len {
    syscall4 SYS_read, fd, msg, msg_len
}

macro exit code {
    syscall2 SYS_exit, code
}

segment readable executable
entry main
main:
    ;; Initialize the pointer
    mov r9, buf
    
read_loop:
    read STDIN, msg, msg.len
    ;; write STDOUT, msg, msg.len

    cmp [msg], byte "+" ; 43
    je plus
    cmp [msg], byte "-" ; 45
    je minus
    cmp [msg], byte "<" ; 60
    je left
    cmp [msg], byte ">" ; 62
    je right
    cmp [msg], byte "." ; 46
    je print
    ;;cmp [msg], byte "[" ; 91
    ;;je loop_start
    ;;cmp [msg], byte "]" ; 93
    ;;je loop_end

    ;; Keep reading until we get a newline
    cmp [msg], byte 10
    jne read_loop
    je clean_exit
plus: 
    ;; add 1 to the number
    ;write STDOUT, info_plus, info_plus.len
    inc byte [r9]
    jmp read_loop
minus:
    ;; subtract 1 from the number
    ;write STDOUT, info_minus, info_minus.len
    dec byte [r9]
    jmp read_loop
left:
    ;; move the pointer left
    ;write STDOUT, info_left, info_left.len
    dec r9
    cmp r9, buf
    jae read_loop
    write 1, error_index, error_index.len
    exit -1
right:
    ;; move the pointer right
    ;write STDOUT, info_right, info_right.len
    inc qword r9
    cmp qword r9, buf + 30000
    jb read_loop
    write 1, error_index, error_index.len
    exit -1
print:
    ;; print the number
    ;write STDOUT, info_print, info_print.len
    write STDOUT, buf, 1
    write 1, [r9], 1
    jmp read_loop

clean_exit:
    ;; exit
    write STDOUT, nl, 1
    exit 0

segment readable writeable
msg db 0
msg.len = $ - msg
error_index db "Error: index out of bounds", 10
error_index.len = $ - error_index
info_plus db "plus", 10
info_plus.len = $ - info_plus
info_minus db "minus", 10
info_minus.len = $ - info_minus
info_left db "left", 10
info_left.len = $ - info_left
info_right db "right", 10
info_right.len = $ - info_right
info_print db "print", 10
info_print.len = $ - info_print
info_exit db "exit", 10
info_exit.len = $ - info_exit
nl db 10

buf rb 30000
