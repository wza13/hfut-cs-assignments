;----------------8255A并行口实验(3)  控制交通灯----------------
CODE    SEGMENT
        ASSUME CS:CODE,DS:CODE,ES:CODE
        ORG 32F0H
PA      EQU 0FFD8H
PB      EQU 0FFD9H
PC      EQU 0FFDAH
PCTL    EQU 0FFDBH
H3:     MOV AL,88H
        MOV DX,PCTL
        OUT DX,AL               ;MOD:0,
        MOV DX,PA
        MOV AL,0B6H
        OUT DX,AL
        INC DX
        MOV AL,0DH
        OUT DX,AL
        CALL DELAY1
P30:    MOV AL,75H
        MOV DX,PA
        OUT DX,AL
        INC DX
        MOV AL,0DH
        OUT DX,AL
        CALL DELAY1
        CALL DELAY1
        MOV CX,08H
P31:    MOV DX,PA
        MOV AL,0F3H
        OUT DX,AL
        INC DX
        MOV AL,0CH
        OUT DX,AL
        CALL DELAY2
        MOV DX,PA
        MOV AL,0F7H
        OUT DX,AL
        INC DX
        MOV AL,0DH
        OUT DX,AL
        CALL DELAY2
        LOOP P31
        MOV DX,PA
        MOV AL,0AEH
        OUT DX,AL
        INC DX
        MOV AL,0BH
        OUT DX,AL
        CALL DELAY1
        CALL DELAY1
        MOV CX,08H
P32:    MOV DX,PA
        MOV AL,9EH
        OUT DX,AL
        INC DX
        MOV AL,07H
        OUT DX,AL
        CALL DELAY2
        MOV DX,PA
        MOV AL,0BEH
        OUT DX,AL
        INC DX
        MOV AL,0FH
        OUT DX,AL
        CALL DELAY2
        LOOP P32
        JMP P30
DELAY1: PUSH AX
        PUSH CX
        MOV CX,0030H
DELY2:  CALL DELAY2
        LOOP DELY2
        POP CX
        POP AX
        RET
DELAY2: PUSH CX
        MOV CX,8000H
        LOOP $
        POP CX
        RET
CODE    ENDS
        END H3
