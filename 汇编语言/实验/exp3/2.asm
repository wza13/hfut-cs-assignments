.model small

.stack 100h

.data
    table   dw b1, b2, b3, b4, b5, b6, b7, b8
    s1      db   'The first bit is 1', 0dh, 0ah, '$'
    s2      db  'The second bit is 1', 0dh, 0ah, '$'
    s3      db   'The third bit is 1', 0dh, 0ah, '$'
    s4      db  'The fourth bit is 1', 0dh, 0ah, '$'
    s5      db   'The fifth bit is 1', 0dh, 0ah, '$'
    s6      db   'The sixth bit is 1', 0dh, 0ah, '$'
    s7      db 'The seventh bit is 1', 0dh, 0ah, '$'
    s8      db  'The eighth bit is 1', 0dh, 0ah, '$'

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

    mov bl, 00100000b

    mov cx, 8
    mov al, bl
    mov bx, 0
    l1:
    shl al, 1
    jc find
    inc bx
    inc bx
    loop l1
    jmp quit

    find:
    jmp table[bx]

    b1:
    printStr s1
    jmp quit
    b2:
    printStr s2
    jmp quit
    b3:
    printStr s3
    jmp quit
    b4:
    printStr s4
    jmp quit
    b5:
    printStr s5
    jmp quit
    b6:
    printStr s6
    jmp quit
    b7:
    printStr s7
    jmp quit
    b8:
    printStr s8
    jmp quit
    
quit:
    mov ah, 4ch
    int 21h
end start
