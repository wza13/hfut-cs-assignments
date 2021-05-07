.model small

.stack 100h

.data
    table   dw t1, t2, t3, t4, t5, t6, t7, t8, t9
    crlf    db 0dh, 0ah, '$'
    s0      db 'please input number between 1 to 9$'
    s1      db '9$'
    s2      db '8$'
    s3      db '7$'
    s4      db '6$'
    s5      db '5$'
    s6      db '4$'
    s7      db '3$'
    s8      db '2$'
    s9      db '1$'

.code

printStr MACRO strAddr
    push dx
    push ax
    lea dx, strAddr
    mov ah, 9
    int 21h
    pop ax
    pop dx
ENDM

start:
    mov ax, @data
    mov ds, ax

input:
    lea dx, s0
    mov ah, 9
    int 21h
    printStr crlf

    mov ah, 1
    int 21h
    ; store the input char in bx
    mov bx, ax
    printStr crlf

    cmp bl, '1'
    jb input
    cmp bl, '9'
    ja input

    and bx, 000fh
    dec bx
    shl bx, 1

    jmp table[bx]
display:
    mov ah, 9
    int 21h
    printStr crlf

    mov ah, 4ch
    int 21h

t1:
    lea dx, s1
    jmp display
t2:
    lea dx, s2
    jmp display
t3:
    lea dx, s3
    jmp display
t4:
    lea dx, s4
    jmp display
t5:
    lea dx, s5
    jmp display
t6:
    lea dx, s6
    jmp display
t7:
    lea dx, s7
    jmp display
t8:
    lea dx, s8
    jmp display
t9:
    lea dx, s9
    jmp display

end start
