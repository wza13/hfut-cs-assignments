.model small

.stack 100h

.data
    xueHao  dw 0
    up      dw 0
    down    dw 0
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

judge proc
    ; param:  xueHao: [bp + 4]
    ; return: flag: [bp + 6]
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx

    mov bx, [bp + 4]
    mov cx, [bp + 4]

    sub cx, 2
    cmp bx, 2
    jle isPrime
    mov dl, 1
Prime:
    mov ax,bx
    inc dl
    div dl
    cmp ah, 0
    jz notPrime
    loop prime
    jmp isPrime

notPrime:
    mov word ptr [bp + 6], 0
    jmp endOfJudge
isPrime:
    mov word ptr [bp + 6], 1
endOfJudge:
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 2
judge endp


printUNum proc
    ; print unsigned number
    ; param al: num
    push cx
    push dx

    mov cx, 0
    pushRemainders:
    and ah, 0
    mov dl, 10
    div dl
    mov dl, ah
    and dh, 0
    push dx
    inc cx
    cmp al, 0
    jne pushRemainders

    popRemainders:
    pop dx
    or dl, 30h
    mov ah, 2
    int 21h
    loop popRemainders

    pop dx
    pop cx
    ret
printUNum endp


start:
    mov ax, @data
    mov ds, ax
    mov es, ax

    ; input xueHao
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
    cbw
    mov xueHao, ax
    printStr crlf

    mov ax, xueHao
    mov cx, 0
    cmp cx, 0
    ja endUp
        sub sp, 2
        push ax
        call judge
        pop dx
        cmp dx, 1
        je notFindUp
        mov cx, 1
        mov up, ax
        notFindUp:
        inc ax
    endUp:

    ; .WHILE flag == 0
    ;     sub sp, 2
    ;     push ax
    ;     call judge
    ;     pop dx
    ;     .IF dx == 1
    ;         mov flag, 1
    ;         mov up, ax
    ;     .ENDIF
    ;     inc ax
    ; .ENDW

    mov ax, xueHao
    mov cx, 0
    cmp cx, 0
    ja endDown
        sub sp, 2
        push ax
        call judge
        pop dx
        cmp dx, 1
        jne notFindDown
        mov cx, 1
        mov up, ax
        notFindDown:
        dec ax
    endDown:

    ; .WHILE flag == 0
    ;     sub sp, 2
    ;     push ax
    ;     call judge
    ;     pop dx
    ;     .IF dx == 1
    ;         mov flag, 1
    ;         mov up, ax
    ;     .ENDIF
    ;     dec ax
    ; .ENDW

    ; find which one is closer to xueHao
    mov di, up
    mov ax, xueHao
    sub di, ax
    mov ax, down
    mov si, xueHao
    sub si, ax
    cmp di, si
    ; di < si: printUp
    jb printUp
    ja printDown
    printUp:
    mov ax, up
    call printUNum
    jmp endOfMain
    printDown:
    mov ax, down
    call printUNum

    endOfMain:
    mov ah, 4ch
    int 21h

end start
