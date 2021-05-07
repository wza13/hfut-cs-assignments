.model small

.data
    x dw ?
    y dw ?
    z dw ?
    min dw ?

.code
min3 MACRO x, y, z, min
    push ax
    mov ax, x
    cmp ax, y
    jge j1
    j3:
    cmp ax, z
    jge j2
    jmp finally
    j2:
    mov ax, z
    jmp finally
    j1:
    mov ax, y
    jmp j3 

    finally:
    mov min, ax
    pop ax
ENDM

start:
    mov ax, @data
    mov ds, ax

    mov x, 1
    mov y, 2
    mov z, 0
    min3 x, y, z, min
    mov ax, min

    ; mov x, 1
    ; mov y, -1
    ; mov z, 0
    ; min3 x, y, z, min
    ; mov ax, min

    mov ah, 4ch
    int 21h
end start

