.model small

.stack 100h

.data
    scores  db 10 dup(100)
            db 10 dup(95)
            db 10 dup(90)
            db 10 dup(85)
            db 10 dup(80)
            db 10 dup(75)
            db 10 dup(70)
            db 10 dup(65)
            db 10 dup(55)
            db 10 dup(60)
    y       db 'Y$'
    n       db 'N$'
    crlf    db 0dh, 0ah, '$'

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
    mov es, ax

    mov ah, 1
    int 21h
    mov dh, al
    and dh, 0fh
    mov ah, 1
    int 21h
    mov dl, al
    and dl, 0fh
    
    mov al, dh
    mov dh, 10
    mul dh
    add al, dl
    printStr crlf

    mov cx, 100
    lea di, scores
    repnz scasb

    cmp cx, 0
    je printN
    printStr y
    jmp quit
    printN:
    printStr n

quit:
    mov ah, 4ch
    int 21h
end start
