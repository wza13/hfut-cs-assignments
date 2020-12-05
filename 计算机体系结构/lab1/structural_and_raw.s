.text

    ; structural and raw
    
    ; r12 = 10 / 3 = 3
    lw      r10, data1(R0)
    lw      r11, data2(R0)
    ; 1 raw here, wait for load word
    ; pipeline won't stalled by raw
    ddiv    r12, r10, r11

    ; f12 = 10.0 / 3.0 = 3.3
    l.d     f10, data3(R0)
    l.d     f11, data4(R0)
    ; structurals here, wait for ddiv above
    div.d   f12, f10, f11

    ; raws here, wait for ddiv to be done
    add.d   f13, f11, f12

    halt

.data
    data1:  .word   10
    data2:  .word   3
    data3:  .double 10.0
    data4:  .double 3.0
