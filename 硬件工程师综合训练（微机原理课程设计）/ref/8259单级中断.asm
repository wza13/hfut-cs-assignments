;-------------8259单级中断控制器实验-------------------
CODE    SEGMENT
        ASSUME CS:CODE,DS:CODE,ES:CODE
        ORG 3400H
H8:     JMP P8259
ZXK     EQU 0FFDCH
ZWK     EQU 0FFDDH
LED     DB 0C0H,0F9H,0A4H,0B0H,99H,92H,82H,0F8H,80H,90H
        DB 88H,83H,0C6H,0A1H,86H,8EH,0FFH,0CH,0DEH,0F3H
BUF     DB ?,?,?,?,?,?
Port0   EQU 0FFE0H
Port1   EQU 0FFE1H
P8259:  CLI
        CALL WP        ;初始化显示“P.”
        MOV AX,OFFSET INT8259
        MOV BX,003CH
        MOV [BX],AX
        MOV BX,003EH
        MOV AX,0000H
        MOV [BX],AX
        CALL FOR8259
        mov si,0000h
        STI
CON8:   CALL DIS
        JMP CON8
;------------------------------------
INT8259:cli
        MOV BX,OFFSET BUF
        MOV BYTE PTR [BX+SI],07H
        INC SI
        CMP SI,0007H
        JZ X59
XX59:   MOV AL,20H
        MOV DX,Port0
        OUT DX,AL
        mov cx,0050h
xxx59:  push cx
        call dis
        pop cx
        loop xxx59
        pop cx
        mov cx,3438h
        push cx
        STI
        IRET
X59:    MOV SI,0000H
        CALL WP
        JMP XX59
;==============================
FOR8259:MOV AL,13H
        MOV DX,Port0
        OUT DX,AL
        MOV AL,08H
        MOV DX,Port1
        OUT DX,AL
        MOV AL,09H
        OUT DX,AL
        MOV AL,7FH      ;IRQ7
        OUT DX,AL
        RET
;---------------------------
WP:     MOV BUF,11H     ;初始化显示“P.”
        MOV BUF+1,10H
        MOV BUF+2,10H
        MOV BUF+3,10H
        MOV BUF+4,10H
        MOV BUF+5,10H
        RET
;--------------------------------
DIS:    MOV CL,20H
        MOV BX,OFFSET BUF
DIS1:   MOV AL,[BX]
        PUSH BX
        MOV BX,OFFSET LED
        XLAT
        POP BX
        MOV DX,ZXK
        OUT DX,AL
        MOV AL,CL
        MOV DX,ZWK
        OUT DX,AL
        PUSH CX
        MOV CX,0100H
DELAY:  LOOP $
        POP CX
        CMP CL,01H
        JZ EXIT
        INC BX
        SHR CL,1
        JMP DIS1
EXIT:   MOV AL,00H
        MOV DX,ZWK
        OUT DX,AL
        RET
;--------------------------
CODE    ENDS
        END H8
