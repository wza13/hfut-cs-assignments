; sum1 = ( V - ( X * Y + Z - 720 ) ) / X
; sum2 = ( V - ( X * Y + Z - 720 ) ) % X

.model small

.data
    X       dw -10
    Y       dw 1
    Z       dw 100
    V       dw 1000
    sum1    dw ?
    sum2    dw ?

.code
start:
    mov ax, @data
    mov ds, ax

    mov ax, X
    imul Y
    ; [dx, ax] = X * Y
    
    add ax, Z
    adc dx, 0
    sub ax, 720
    sbb dx, 0
    ; [dx, ax] = X * Y + Z - 720

    sub V, ax
    mov ax, 0
    sbb ax, dx
    mov dx, ax
    mov ax, V
    ; [dx, ax] =  V - ( X * Y + Z - 720 ) 

    ; 1630 / -10
    idiv X
    ; ax =  ( V - ( X * Y + Z - 720 ) ) / X 
    ; dx =  ( V - ( X * Y + Z - 720 ) ) % X 
    mov sum1, ax
    mov sum2, dx

    mov ax, 4c00h
    int 21h
end start
