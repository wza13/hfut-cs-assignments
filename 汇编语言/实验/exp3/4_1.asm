; f = x * y + x - y
; x, y: 1 byte signed
; f: 2 byte signed

.model small

.stack 100h

.data
    x dw ?
    y dw ?
    f dw ?
    hintX db 'Please input x between -128 to 127 (end with enter)', 0dh, 0ah, '$'
    hintY db 'Please input y between -128 to 127 (end with enter)', 0dh, 0ah, '$'
    hintError db 'Wrong number format, input again.', 0dh, 0ah, '$'
    hintRes db 'The result of f(x, y) is $'


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

inputNum proc
    ; param: 1. destination to store the input number
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    mov dx, 0
    mov cx, 10

    mov ah, 1
    int 21h
    .IF al == '-'
        mov bx, 1
    .ELSE
        mov bx, 0
        and al, 0fh
        add dl, al
    .ENDIF
    l1:
    mov ah, 1
    int 21h
    cmp al, 0dh
    je endInput
    and al, 0fh
    push ax
    mov al, dl
    mul cl
    mov dl, al
    pop ax
    add dl, al
    jmp l1

    endInput:
    .IF bx == 1
        mov ax, 100h
        sub ax, dx
        cbw
        mov dx, ax
    .ENDIF

    mov bx, [bp + 4]
    mov [bx], dx

    mov ah, 2
    mov dl, 0dh
    int 21h
    mov dl ,0ah
    int 21h

    pop dx
    pop bx
    pop cx
    pop ax
    pop bp
    ret 2
inputNum endp


printNum proc
    ; param: 1. the number that is going to be displayed, length: 2byte
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    mov ax, [bp + 4]
    cmp ax, 0
    jge continue
    push ax
    mov dl, 2dh  ; 2d: '-'
    mov ah, 2
    int 21h
    pop ax
    mov dx, 0
    sub dx, ax
    mov ax, dx
    continue:
    mov cx, 0
    mov bx, 10
    .WHILE ax > 0
        inc cx
        mov dx, 0
        div bx
        push dx
    .ENDW
    mov ah, 2
    cmp cx, 0
    jne l2
    mov dl, '0'
    int 21h
    jmp return
    l2:
    pop dx
    add dl, 30h
    int 21h
    loop l2

    return:
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 2

printNum endp


computeF proc
    ; use registry
    ; param: al: x, bl: y
    ; return: ax: f
    push dx
    
    mov dx, ax  ; store x in dl
    imul bl     ; ax = x * y
    add ax, dx
    sub ax, bx

    pop dx
    ret
computeF endp


start:
    mov ax, @data
    mov ds, ax

    printStr hintX     
    lea ax, x
    push ax
    call inputNum
    printStr hintY
    lea ax, y
    push ax
    call inputNum

    mov ax, x
    mov bx, y
    printStr hintRes
    call computeF
    push ax
    call printNum

    mov ah, 4ch
    int 21h
end start
