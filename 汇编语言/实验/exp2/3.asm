; Find the average, maximum and minimum values 
; of 50 students and display the results.

; Scores can be stored as unsigned number.
; 50 * 100 = 5000 < ffffH (unsigned)

.model small

.stack 100h

.data
    crlf        db 0dh, 0ah, '$'
    maxStr      db 'The maximum score is $'
    minStr      db 'The minimum score is $'
    avgStr      db 'The average score is $'
    max         dw 0
    min         dw 100
    avg         dw 0
    count       equ 50
    scores      db 5 dup(100)
                db 5 dup(95)
                db 5 dup(90)
                db 5 dup(85)
                db 5 dup(80)
                db 5 dup(75)
                db 5 dup(70)
                db 5 dup(65)
                db 5 dup(55)
                db 5 dup(60)

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

    mov cx, count
    lea bx, scores
    mov si, 0
loadScores:
    mov dl, [bx + si]
    and dh, 0
    cmp dx, max
    ; if dx <= max, don't update max
    jbe compareMin
    mov max, dx
    compareMin:
    ; if dx >= min, don't update min
    cmp dx, min
    jae addScore
    mov min, dx
    addScore:
    add avg, dx
    inc si
    loop loadScores

    mov ax, avg
    mov bl, count
    div bl
    and ah, 0
    mov avg, ax

    printStr maxStr
    mov ax, max
    call printUNum
    printStr crlf

    printStr minStr
    mov ax, min
    call printUNum
    printStr crlf

    printStr avgStr
    mov ax, avg
    call printUNum
    printStr crlf

    mov ah, 4ch
    int 21h
end start
