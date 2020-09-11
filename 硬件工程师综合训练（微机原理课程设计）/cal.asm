; “A”——“+”
; “B”——“-”
; “C”——“*” 
; “D”——“括号” 
; “E”——“=” 
; “F”——开始运算（包括撤消运算），屏幕显示“0”。
;
; 运算要求： 
;     ⑴ 输入待计算数据（小于四位数），数码管跟随显示。 
;     ⑵ 按“+”、“-”、“*”或“括号”时，当前显示内容不变。 
;     ⑶ 再输入数据时，数码管跟随显示。 
;     ⑷ 按“E”时，显示最终结果数据。若计算结果为奇数，则点亮1个红色发光二极管，并持续以1秒间
;     隔（硬件实现）闪烁；若计算结果为偶数，则点亮2个绿色发光二极管，并持续以2秒间隔（硬件实现）闪
;     烁。 
;     ⑸ 按“F”键：左侧四个数码管中最右边（对应个位数）的一个显示“0”，其余三个不显示内容。
;     同时熄灭点亮的发光二极管，等待下一次运算的开始。 
;     ⑹ 需要考虑运算的优先级问题。 
;     ⑺ 可以只考虑正整数运算，不考虑负数和实数运算。括号可以不考虑嵌套情况，但必须能实现算式
;     中存在多组平行括号的计算。
;
; 设计说明： 
;     输入数据时，若超出显示范围则不响应超出部分。在计算结果超出显示范围时，则显示“F”。


code    segment
        assume cs:code

org  1200h
start:

    jmp true_start
    ; 中断控制器 8259
    ; 8259只处理来自8253的计时中断
    port59_0    equ 0ffe4h
    port59_1    equ 0ffe5h
    icw1        equ 13H         ; 边沿触发
    icw2        equ 08h         ; 中断类型号 08H 09H ...
    icw4        equ 09h         ; 全嵌套，缓冲从片，非自动EOI，8086/88模式 为什么要用缓冲单片?
    ocw1open    equ 0feh        ; IRQ0，类型号为08h
    vectorOffset EQU 20H        ; 中断向量的地址 08H*4=20H
    vectorSeg   EQU 22H         ; 中断向量的CS段地址在中断向量表中的地址，值为0

    ; 并行接口芯片 8255
    ; 8255向led灯输出led状态
    port55_a    equ 0ffd8H
    port55_ctrl equ 0ffdBH

    ; 计数定时芯片 8253
    port53_0    equ 0ffe0H
    port53_ctrl equ 0ffe3H      ; 控制口
    count53_second1  equ 19200       ; 1s计数次数 T7=19.2KHz Tn=4.9152MHz/2^n
    count53_second2  equ 38400       ; 2s计数次数


    ledbuf                  db 6 dup(?)
    led_count               db 0
    previous_key            db 20h
    current_key             db 20h
    has_previous_bracket    db 0
    has_right_bracket       db 0
    same_as_pre             db 0

    operator_stack          db '#', 100 dup(?)      ; si
    operand_stack           db 0ffh, 0ffh, 100 dup(?)   ; di

    priority                db 0    ; 0 栈顶<下一个; 1 =; 2 >
    is_save_num             db 0    ; 当按下一个运算符时，current_num是否已经保存，为了处理连输运算符号的错误情况
    current_num             dw 0
    display_num             dw 0    ; 按下符号后，会把current_num清零，但不把display_num清零
    has_input_e             db 0    ; 统计是否已经按下过e键
    result                  dw 0    ; 总的计算结果
    overflow                db 0
    whole_error             db 0
    
    ; # ( +- *    优先级从小到大

    ;   # ( + - *
    ; # f 0 0 0 0
    ; ( f f 0 0 0
    ; + 2 2 1 1 0
    ; - 2 2 1 1 0
    ; * 2 2 2 2 1
    priority_table  db  0ffh, 0, 0, 0, 0
                    db  0ffh, 0ffh, 0, 0, 0
                    db  2, 2, 1, 1, 0
                    db  2, 2, 1, 1, 0
                    db  2, 2, 2, 2, 1


    OUTSEG  equ  0ffdch             ;段控制口
    OUTBIT  equ  0ffddh             ;位控制口/键扫口
    IN_KEY  equ  0ffdeh             ;键盘读入口

    LightOnGreen EQU 0edh ;绿灯  1110 1101   按照题目例子中给的接线方式接线
    LightOnRed EQU 0feh ;红灯    1111 1110   
    lightOff EQU 0FFH; 关灯      1111 1111
    flag    db 0                ;灯是否在亮


true_start:
        cli
        call init_all
main:
        call get_key
        cmp current_key, 20h
        je handle
        and  al,0fh
    handle:
        call handle_key
        ;call set_led_num
        call disp
        jmp main
; end



init_all proc
        call init8259
        call init8255
        call init8253
        call initVector
        call clean_all
        ret
init_all endp


init8259 proc
        push ax
        push dx
        mov dx, port59_0
        mov al, icw1
        out dx, al
        mov dx, port59_1
        mov al, icw2
        mov dx, port59_1
        out dx, al
        mov al, icw4
        out dx, al
        mov al, ocw1open
        out dx, al
        pop dx
        pop ax
        ret
init8259 endp


init8255 proc
        push ax
        push dx
        mov dx, port55_ctrl
        mov al, 88H             ;8255A控制字88H，使AB端口均为输出口，C口高位输入，低位输出，且全部工作在方式0下
        out dx, al
        mov al, lightOff
        mov dx, port55_a
        out dx, al
        pop dx
        pop ax
        ret
init8255 endp


init8253 proc
        push dx
        push ax
        mov dx, port53_ctrl
        mov al, 36H            ; 计数器0，先低8位，再高8位，方式3，二进制计数
        out dx, al
        pop ax
        pop dx
        ret
init8253 endp


init_stack proc
        mov si, 0
        mov di, 0
        ret
init_stack endp


initVector proc
        cli
        Push bx
        Push ax

        Mov ax , offset flash	;中断向量表的初始化
        Mov bx , vectorOffset
        Mov [bx] , ax

        mov bx,vectorSeg		;中断向量的段地址对应的中断向量表的地址
        mov ax,0000H
        mov [bx],ax

        Pop ax
        Pop bx
        sti
        Ret
initVector endp


clean_all proc
        cli
        call init_stack
        call clean_led
        call ProcTurnOff
        mov previous_key, 20h
        mov current_key, 20h
        mov led_count, 0
        mov has_previous_bracket, 0
        mov has_right_bracket, 0
        mov same_as_pre, 0
        mov current_num, 0
        mov display_num, 0
        mov result, 0
        mov overflow, 0
        mov is_save_num, 0
        mov whole_error, 0
        mov has_input_e, 0
        ret
clean_all endp


clean_led proc
        mov  LedBuf+0,0ffh
        mov  LedBuf+1,0ffh
        mov  LedBuf+2,0ffh
        mov  LedBuf+3,0c0h
        mov  LedBuf+4,0ffh
        mov  LedBuf+5,0ffh
        ret
clean_led endp


;---------------中断服务程序---------------------
flash proc
        cli	;关中断
        test flag,1	;判断当前灯是否亮
        Jz turnOn		;不亮则开灯
        ;TurnOff
        call ProcTurnOff	;亮灯则关上
        Jmp flashOK
    turnOn:
        call ProcTurnOn

    flashOK:
        ; call ProcWriteCount;重新计数
        mov dx,port59_0
        mov al,20h	;0010 0000 普通EOI方式 OCW2
        out dx,al
        STI		;开中断
        IRET
flash endp


ProcTurnOn proc
        push dx
        push ax

        Mov dx, Port55_A
        test result,1h		;判断是否是奇数
        jz green		;是偶数则亮绿灯
        mov al, LightOnRed
        jmp rgOk
    green:
        mov al, LightOnGreen
    rgOk:
        Out dx, al
        mov flag,1

        pop ax
        pop dx

        ret
ProcTurnOn endp

ProcTurnOff proc
        push dx
        push ax
		
        Mov dx, Port55_A
        Mov al, lightOff
        Out dx, al
        mov flag,0

        pop ax
        pop dx

        ret
ProcTurnOff endp


ProcWriteCount proc
        mov dx, port53_0  ;第一个计数器通道的端口地址
        test result,1h       ;判断result是否为奇数
        jz second2
        mov ax,count53_second1	;如果是奇数，则写入计数初值1s
        jmp countSetOK
    second2:
        mov ax,count53_second2
    countSetOK:
        out dx,al		;先写低8位，再读写高八位，方式3，二进制计数
        mov al,ah
        out dx,al
        ret
ProcWriteCount endp


get_key proc                    ;键扫子程序
    ; store key in current_key
        push ax
        push bx
        push cx
        push dx

        mov al, current_key     ;上一次扫描的符号
        mov previous_key, al

        mov  al,0ffh            ;关显示口
        mov  dx,OUTSEG
        out  dx,al
        mov  bl,0
        mov  ah,0feh
        mov  cx,8
    key1:   
        mov  al,ah
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
    nkey:   
        mov  al,20h
        mov current_key, al
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    key2:   
        test al,1
        je   key3
        mov  al,0
        jmp  key6
    key3:   
        test al,2
        je   key4
        mov  al,8
        jmp  key6
    key4:   
        test al,4
        je   key5
        mov  al,10h
        jmp  key6
    key5:   
        test al,8
        je   nkey
        mov  al,18h
    key6:   
        add  al,bl
        cmp  al,10h
        jnc  fkey
        mov  bx,offset KeyTable
        xlat
    fkey:   
        mov current_key, al
        pop dx
        pop cx
        pop bx
        pop ax
        ret
get_key endp


handle_key proc
        push ax
        call is_same_as_pre
        cmp same_as_pre, 1
        jne handle_key_continue
        pop ax
        ret
    handle_key_continue:
        mov al, current_key
        cmp al, 10
        jnb handle_key_a
        call handle_number
        pop ax
        ret
    handle_key_a:
        cmp al, 0ah
        jne handle_key_b
        call handle_a
        pop ax
        ret
    handle_key_b:
        cmp al, 0bh
        jne handle_key_c
        call handle_b
        pop ax
        ret
    handle_key_c:
        cmp al, 0ch
        jne handle_key_d
        call handle_c
        pop ax
        ret
    handle_key_d:
        cmp al, 0dh
        jne handle_key_e
        call handle_d
        pop ax
        ret
    handle_key_e:
        cmp al, 0eh
        jne handle_key_f
        call handle_e
        pop ax
        ret
    handle_key_f:
        cmp al, 0fh
        jne key_error
        call handle_f
        jmp handle_key_f_ret
        key_error:
        call handle_error
        handle_key_f_ret:
        pop ax
        ret
handle_key endp

is_same_as_pre proc
    ;给same_as_pre赋值
        push ax
        mov al, current_key
        cmp al, previous_key
        je is_same
        mov same_as_pre, 0
        jmp return
    is_same: 
        mov same_as_pre, 1
    return:    
        pop ax
        ret
is_same_as_pre endp



handle_number proc
    ; 如果 led_count < 4
    ;   current_num = current_num * 10 + current_key
    ;   led_count += 1
    ; 当输入数字以外的符号的时候需要把led_count清空
        push ax
        push bx
        push dx
        mov is_save_num, 0           ; 输入新的数字时，设置成当前数字还未保存
        cmp led_count, 4
        jae handle_number_ret
        mov ax, current_num
        mov bx, 10
        mul bx
        mov bl, current_key
        mov bh, 0
        add ax, bx               
        mov current_num, ax          ;current_num = current_num * 10 + current_key
        inc led_count
        push ax
        mov ax, current_num
        mov display_num, ax
        pop ax
        call set_led_num
    handle_number_ret:
        pop dx
        pop bx
        pop ax
        ret
handle_number endp

handle_error proc
    ;处理get_key得到的字符不是数字和符号的情况，包含current_key=20h
        cmp current_key, 20h
        je handle_error_ret
        ; 处理其它的符号
    handle_error_ret:
        ret
handle_error endp

handle_a proc
    ; 处理输入的是加减乘的情况

    ; 如果数字已经保存或刚输入过右括号
    ;   则不把数字压入栈
    ; 否则，数字入栈

    ; 然后计算

        cmp is_save_num, 0
        jne calculate_a
        mov is_save_num, 1

        ; 数字入栈
        cmp has_right_bracket, 1
        je number_not_push
        inc di
        inc di
        push ax
        mov ax, current_num
        mov operand_stack[di], ah           ;将current_num入栈
        mov operand_stack[di + 1], al
        pop ax
        jmp next_a
    
    number_not_push:
        mov has_right_bracket, 0
    
    next_a:
        mov led_count, 0
        mov current_num, 0                  ;按下运算符时，数字输入结束，将当前的数字清空
    calculate_a:
        cmp whole_error, 1
        je a_ret                            ;当前面的式子已经计算出错的时候后面的式子不需要计算了
        call get_priority
        cmp priority, 0
        je push_a                           ;当前符号优先级大于栈顶符号，直接入栈
        call cal_one_op                     ;否则计算一次
        jmp calculate_a
    push_a:
        inc si
        push ax
        mov al, current_key
        mov operator_stack[si], al          ;将当前运算符入栈
        pop ax
    a_ret:
        ret
handle_a endp

handle_b proc
        call handle_a
        ret
handle_b endp

handle_c proc
        call handle_a
        ret
handle_c endp

handle_d proc
        ;处理输入符号是括号的情况
        ;输入是左括号，直接入栈
        ;输入是右括号，反复计算直到栈顶是左括号
        cmp has_previous_bracket, 0
        je no_previous
        mov has_previous_bracket, 0
        mov has_right_bracket, 1

        inc di
        inc di
        push ax
        mov ax, current_num
        mov operand_stack[di], ah          ;将current_num入栈
        mov operand_stack[di + 1], al
        pop ax
        mov led_count, 0
        mov current_num, 0                    ;按下运算符时，数字输入结束，将当前的数字清空

    cal_between_bracket:
        cmp operator_stack[si], 0dh
        je is_left_bracket
        call cal_one_op
        jmp cal_between_bracket
    is_left_bracket:
        dec si
        jmp ret_d

    no_previous:
        mov has_previous_bracket, 1
        inc si
        push ax
        mov al, current_key
        mov operator_stack[si], al
        pop ax
    ret_d:
        ret
handle_d endp

handle_e proc
        ;处理输入符号是'='的情况
        ;第一次按下'='时，反复计算直到栈顶是'#'号
        push ax

        cmp has_input_e, 0                ;为了解决按下第二次'e'键后显示第二个操作数的问题，判断已经输入过'e'后再次输入'e'时不进行任何操作
        jne handle_e_ret
        mov has_input_e, 1

        cmp has_right_bracket,1
        je num_not_push_e
        inc di
        inc di
        push ax
        mov ax, current_num
        mov operand_stack[di], ah         ;将current_num入栈
        mov operand_stack[di + 1], al
        pop ax
    num_not_push_e:
        mov has_right_bracket, 0

    cal_e:
        cmp whole_error, 1
        je ret_e
        cmp operator_stack[si], '#'
        je ret_e
        call cal_one_op
        jmp cal_e
    ret_e:
        cmp whole_error, 1
        je show_error
        cmp di, 2
        ja show_error                    ;计算完成后，运算符栈内剩余数字大于一个时计算结果错误
        mov ah, operand_stack[di]
        mov al, operand_stack[di + 1]
        mov display_num, ax
        mov result, ax

        call set_led_num
        sti
        call ProcTurnOn
        call ProcWriteCount
        jmp handle_e_ret
    show_error:
        mov  LedBuf+0,0ffh               ;计算出现错误时结果显示'F'
        mov  LedBuf+1,0ffh
        mov  LedBuf+2,0ffh
        mov  LedBuf+3,8eh
    handle_e_ret:
        pop ax
        ret
handle_e endp

handle_f proc
        ;处理按下'F'的情况
        call clean_all
        ret
handle_f endp


cal_one_op proc
        push ax
        push bx
        push dx
        cmp si, 1
        jb cal_error
        cmp di, 4
        jb cal_error
        mov ah, operand_stack[di - 2]
        mov al, operand_stack[di - 1]
        mov bh, operand_stack[di]
        mov bl, operand_stack[di + 1]
        mov dl, operator_stack[si]

        cmp dl, 0ah                 ; +
        jne cal_not_plus
        add ax, bx
        cmp ax,9999
        ja cal_overflow
        jmp cal_ret
    cal_not_plus:
        cmp dl, 0bh                 ; -
        jne cal_not_minus
        cmp ax,bx
        jb cal_overflow         ; 减法得负也为overflow
        sub ax, bx
        jmp cal_ret
    cal_not_minus:
        cmp dl, 0ch                 ; *
        jne cal_error               ; 不是 + - * 为error
        mul bx
        cmp dx, 0
        ja cal_overflow            ; 乘法溢出为overflow
        cmp ax,9999
        ja cal_overflow
        jmp cal_ret
    cal_error:
        mov whole_error, 1
        jmp cal_ret
    cal_overflow:
        mov overflow, 1
    cal_ret:
        dec di
        dec di
        dec si
        mov operand_stack[di], ah
        mov operand_stack[di + 1], al
        pop dx
        pop bx
        pop ax
        ret
cal_one_op endp


get_priority proc
        push ax
        push bx
        push dx
        mov al, operator_stack[si]
        cmp al, '#'
        jne top_not_pound
        mov al, 0
        jmp curr_operator
        top_not_pound:
        cmp al, 0dh
        jne top_not_bracket
        mov al, 1
        jmp curr_operator
        top_not_bracket:
        sub al, 0ah
        add al, 2

        curr_operator:
        mov dl, current_key
        cmp dl, 0dh
        jne curr_operator_not_pound
        mov dl, 1
        jmp find_in_table
        curr_operator_not_pound:
        sub dl, 0ah
        add dl, 2

        find_in_table:
        mov dh, 5           ; 5 x 5 的优先表
        mul dh
        add al, dl
        mov ah, 0
        mov bx, ax
        mov dl, priority_table[bx]
        mov priority, dl
        jmp get_priority_ret
    get_priority_err:
        mov whole_error, 1
    get_priority_ret:
        pop dx
        pop bx
        pop ax
        ret
get_priority endp


set_led_num proc
    ; 在handle_number里调用时
    ; 此时led_count = 已输入的数字位数
    ; led_count - 1 = 已显示的数字位数
        push ax
        push bx
        push cx
        push dx
        push di
        mov  LedBuf+0,0ffh
        mov  LedBuf+1,0ffh
        mov  LedBuf+2,0ffh
        mov  LedBuf+3,0ffh
        mov di, 3
        mov ax, display_num
        
        cmp overflow, 1
        jne ax_not_zero
        
        overFshow:
        mov LedBuf+3,08eh       ; 8eh : 'F'
        JMP set_led_num_ret

    ax_not_zero:

        mov bx, offset ledmap
        mov dx, 0               ; dx 为被除数的高位，需要置为0
        mov cx, 10              ; cx 做除数
        div cx
        add bx, dx              ; 除完后，dx为余数，ax为商，把余数加到ledmap的偏移地址上
        mov dl, [bx]            ; bx为段码的地址，dl 就是要显示的段码

        mov bx, offset ledbuf   
        add bx, di
        mov [bx], dl            ; 等价于 mov ledbuf+di, dl
        dec di
        
        cmp ax, 0
        jne ax_not_zero

    set_led_num_ret:
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        ret
set_led_num endp



disp proc
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
disp endp

delay proc                         ;延时子程序
        push  cx
        mov   cx,256
        loop  $
        pop   cx
        ret
delay endp

    ;八段管显示码
    LedMap  db   0c0h,0f9h,0a4h,0b0h,099h,092h,082h,0f8h
            db   080h,090h,088h,083h,0c6h,0a1h,086h,08eh
    ;键码定义
    KeyTable db   07h,04h,08h,05h,09h,06h,0ah,0bh
            db   01h,00h,02h,0fh,03h,0eh,0ch,0dh

code    ends
        end start
