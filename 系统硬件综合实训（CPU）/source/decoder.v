`include "head.v"
`timescale 1ns / 1ps
module Decoder(
    input [31:0] ins,
    output [5:0] op,
    output [5:0] func,
    output [4:0] sftamt,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [15:0] immd16,
    output [25:0] immd26
    );
    //把输入的指令分成好几部分，因为实现的是RISC架构，指令里位置都是固定的
    assign op = ins[31:26];
    assign func = ins[5:0];
    assign sftamt = ins[10:6];
    assign rs = ins[25:21];
    assign rt = ins[20:16];
    assign rd = ins[15:11];
    assign immd16 = ins[15:0];
    assign immd26 = ins[25:0];
endmodule