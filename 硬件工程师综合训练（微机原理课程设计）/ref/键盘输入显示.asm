;******************************************
;　8086系列微机接口实验系统　软件实验项目
;　键盘扫描显示实验
;******************************************
code    segment
        assume cs:code

OUTSEG  equ  0ffdch             ;段控制口
OUTBIT  equ  0ffddh             ;位控制口/键扫口
IN_KEY  equ  0ffdeh             ;键盘读入口
LedBuf  db   6 dup(?)           ;显示缓冲

        org  1000h
Start:
        mov  LedBuf+0,0c2h      ;显示"Good"
        mov  LedBuf+1,0a3h
        mov  LedBuf+2,0a3h
        mov  LedBuf+3,0a1h
        mov  LedBuf+4,0ffh
        mov  LedBuf+5,0ffh

MLoop:
        call Disp               ;显示
        call GetKey             ;扫描键盘并读取键值
        and  al,0fh             ;显示键码
        mov  ah,0
        mov  bx,offset LEDMAP
        add  bx,ax
        mov  al,[bx]
        mov  LEDBuf+5,al
        jmp  MLoop

Disp:
        mov  bx,offset LEDBuf
        mov  cl,6               ;共6个八段管
        mov  ah,00100000b       ;从左边开始显示
DLoop:
        mov  dx,OUTBIT
        mov  al,0
        out  dx,al              ;关所有八段管
        mov  al,[bx]
        mov  dx,OUTSEG
        out  dx,al

        mov  dx,OUTBIT
        mov  al,ah
        out  dx,al              ;显示一位八段管

        push ax
        mov  ah,1
        call Delay
        pop  ax

        shr  ah,1
        inc  bx
        dec  cl
        jnz  DLoop

        mov  dx,OUTBIT
        mov  al,0
        out  dx,al              ;关所有八段管
        ret

Delay:                          ;延时子程序
        push  cx
        mov   cx,256
        loop  $
        pop   cx
        ret

GetKey:                         ;键扫子程序
        mov  al,0ffh            ;关显示口
        mov  dx,OUTSEG
        out  dx,al
        mov  bl,0
        mov  ah,0feh
        mov  cx,8
key1:   mov  al,ah
        mov  dx,OUTBIT
        out  dx,al
        shl  al,1
        mov  ah,al
        nop
        nop
        nop
        nop
        nop
        nop
        mov  dx,IN_KEY
        in   al,dx
        not  al
        nop
        nop
        and  al,0fh
        jnz  key2
        inc  bl
        loop key1
nkey:   mov  al,20h
        ret
key2:   test al,1
        je   key3
        mov  al,0
        jmp  key6
key3:   test al,2
        je   key4
        mov  al,8
        jmp  key6
key4:   test al,4
        je   key5
        mov  al,10h
        jmp  key6
key5:   test al,8
        je   nkey
        mov  al,18h
key6:   add  al,bl
        cmp  al,10h
        jnc  fkey
        mov  bx,offset KeyTable
        xlat
fkey:   ret

LedMap:                         ;八段管显示码
        db   0c0h,0f9h,0a4h,0b0h,099h,092h,082h,0f8h
        db   080h,090h,088h,083h,0c6h,0a1h,086h,08eh

KeyTable:                       ;键码定义
        db   07h,04h,08h,05h,09h,06h,0ah,0bh
        db   01h,00h,02h,0fh,03h,0eh,0ch,0dh

code    ends
        end Start
