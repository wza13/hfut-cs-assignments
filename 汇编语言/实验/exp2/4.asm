; Initialize the 20 bytes starting at DS:0000
; to 0cch and copy to into the next 20 bytes.

assume cs:code, ds:data

data segment
    db 40 dup(10)
data ends

code segment
start:
    mov ax, data
    mov ds, ax
    mov es, ax

    cld
    mov cx, 20
    mov di, 0
    mov al, 0cch
    rep stosb

    mov cx, 20
    mov si, 0
    rep movsb

    mov ah, 4ch
    int 21h
code ends
end start
