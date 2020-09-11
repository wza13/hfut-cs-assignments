;-----------------定时/计数器  8253方波-------------------
CODE    SEGMENT
        ASSUME CS:CODE,DS:CODE,ES:CODE
        ORG 3490H
H9:     MOV DX,0FFE3H
        MOV AL,36H
        OUT DX,AL
        MOV DX,0FFE0H
        MOV AL,00H
        OUT DX,AL
        MOV AL,10H
        OUT DX,AL
        JMP $
CODE    ENDS
        END H9
