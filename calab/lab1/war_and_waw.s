.text

    ; war and waw
    
    ; war
    lw      r10, data1(R0)
    lw      r11, data2(R0)
    ; nop
    ; 1 raw
    ddiv    r12, r10, r11
    ; 1 war, pipeline stalled
    ; because r11 is used in ddiv above
    ; and ddiv hasn't gone into EX stage (see comments below)
    ; since ddiv has 1 raw
    and     r11, r0, r10

    ; if there's a nop, there won't be war.
    ; it's the same reason as why there is only 1 war instead of wars.
    ; because once the source reg is in EX stage,
    ; it's stored somewhere and you can change the source reg.
    ; it won't collide.

    ; waw
    lw      r10, data1(R0)
    ; structurals
    ddiv    r12, r10, r11
    ; waws, pipeline stalled
    ; because it's writing to r12
    ; which is going to be written by ddiv first.
    ; also 1 structural
    ; because after ddiv is done with EX stage
    ; and and ddiv are both going to MEM stage
    and     r12, r0, r10

    halt

.data
    data1:  .word   10
    data2:  .word   3
