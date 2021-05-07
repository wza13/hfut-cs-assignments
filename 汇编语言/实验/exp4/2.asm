.model small

.stack 100h

.data
    seconds db 0
    timer db 18
    oldIsr dw ?, ?

.code

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
    
    mov dl, 20h
    mov ah, 2
    int 21h

    pop dx
    pop cx
    ret
printUNum endp

isr proc far
    push ax
    sti
    
    cmp timer, 0
    je print
    dec timer
    jmp endIsr
    print:
    mov al, seconds
    call printUNum
    inc seconds
    mov timer, 18

    endIsr:
    pushf
    call dword ptr oldIsr
    pop ax
    iret
isr endp

start:
    mov ax, @data
    mov ds, ax
    mov ax, 0
    mov es, ax

    mov ax, es:[1ch * 4]
    mov oldIsr[0], ax
    mov ax, es:[1ch * 4 + 2]
    mov oldIsr[2], ax
    mov word ptr es:[1ch * 4], OFFSET isr
    mov word ptr es:[1ch * 4 + 2], SEG isr
    
    again:
    cmp seconds, 59
    ja exit
    jmp again

    exit:
    mov ax, oldIsr[0]
    mov es:[1CH * 4], ax
    mov ax, oldIsr[2]
    mov es:[1CH * 4 + 2], ax
    mov ah, 4ch
    int 21h
end start
