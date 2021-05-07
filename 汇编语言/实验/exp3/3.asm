.model small

.stack 100h

.data
    str db 50 dup(0)
    y   db 'Yes$'
    n   db 'No$'
    a   db 0
    s   db 0
    m   db 0
    
    crlf db 0dh, 0ah, '$'

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

findAsm proc
    .IF m == 1
        ret
    .ENDIF
    .IF a == 0
        .IF al == 'a'
            mov a, 1 
        .ENDIF
        ret
    .ENDIF
    .IF s == 0
        .IF al == 's'
            mov s, 1
            ret
        .ENDIF
        .IF al == 'a'
            ret
        .ENDIF
        mov a, 0
        ret
    .ENDIF
    .IF al == 'a'
        mov s, 0
        ret
    .ENDIF
    .IF al == 'm'
        mov m, 1
        ret
    .ENDIF
    .IF al == 'a'
        mov s, 0
        ret
    .ENDIF
    mov a, 0
    mov s, 0
    ret
findAsm endp


start:
    mov ax, @data
    mov ds, ax
    
    mov di, 0
    lea bx, str
    input:
    mov ah, 1
    int 21h
    call findAsm
    mov [bx + di], al
    inc di
    cmp al, 0dh
    jne input

    mov [bx + di], 0ah
    inc di
    mov [bx + di], '$'

    printStr crlf
    printStr str
    .IF m == 1
        printStr y
    .ELSE
        printStr n
    .ENDIF

    mov ah, 4ch
    int 21h
end start
