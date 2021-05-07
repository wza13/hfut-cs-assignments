`timescale 1ns / 1ps
// 测试发现问题：
/*
    1. 每一个上升沿一定会写（默认每次都会有新的指令）除非满

*/
module ReservationStation_tb();
    reg clk;
    reg EXEable; // whether the ALU is available and ins can be issued
    reg WEN; // Write ENable

    reg [4:0] opCode;
    reg [4:0] func;
    reg [31:0] dataIn1;
    reg [4:0] label1;
    reg [31:0] dataIn2;
    reg [4:0] label2;

    reg BCEN; // BroadCast ENable
    reg [4:0] BClabel; // BoradCast label
    reg [31:0] BCdata; //BroadCast value

    wire [4:0] opOut;
    wire [31:0] dataOut1;
    wire [31:0] dataOut2;
    wire isFull; // whether the buffer is full
    wire OutEn; // whether output is valid
    wire [4:0]labelOut;
    initial begin
        clk = 0;
        EXEable = 0;
        opCode = 1;
        dataIn1 = 2;
        dataIn2 = 4;
        label1 = 2;
        label2 = 0;
        #40
        // EXEable = 1;
        opCode = 2;
        dataIn1 = 4;
        dataIn2 = 2;
        label1 = 0;
        label2 = 0;
        #40
        BCEN = 1;
        BClabel = 2;
        BCdata = 32;
        EXEable = 0;
        opCode = 3;
        dataIn1 = 8;
        dataIn2 = 16;
        label1 = 0;
        label2 = 2;
        #40
        EXEable = 1;
        opCode = 1;
        dataIn1 = 2;
        dataIn2 = 4;
        label1 = 0;
        label2 = 0;
        #40
        EXEable = 0;
    end

    always begin
        #20
        clk = ~clk;
    end

    ReservationStation test(
        .clk(clk),
        .EXEable(EXEable),
        .WEN(WEN),
        .opCode(opCode),
        .func(func),
        .dataIn1(dataIn1),
        .dataIn2(dataIn2),
        .label1(label1),
        .label2(label2),
        .BCEN(BCEN),
        .BClabel(BClabel),
        .BCdata(BCdata),
        .opOut(opOut),
        .dataOut1(dataOut1),
        .dataOut2(dataOut2),
        .isFull(isFull),
        .OutEn(OutEn),
        .labelOut(labelOut)
    );


endmodule