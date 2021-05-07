; Display day of week based on the input number.

.model small

.stack 100h

.data
    table   dw day1, day2, day3, day4, day5, day6, day7
    crlf    db 0dh, 0ah, '$'
    s0      db 'please input number between 1 to 7$'
    s1      db 'Monday$'
    s2      db 'Tuesday$'
    s3      db 'Wednesday$'
    s4      db 'Thursday$'
    s5      db 'Friday$'
    s6      db 'Saturday$'
    s7      db 'Sunday$'


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
    cmp bl, '7'
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

day1:
    lea dx, s1
    jmp display
day2:
    lea dx, s2
    jmp display
day3:
    lea dx, s3
    jmp display
day4:
    lea dx, s4
    jmp display
day5:
    lea dx, s5
    jmp display
day6:
    lea dx, s6
    jmp display
day7:
    lea dx, s7
    jmp display

end start
