`include "../source/head.v"
`timescale 1ns/1ps
module mdfALU_tb;
    reg clk = 0;
    reg nRST = 1;
    wire inEN;
    reg resultAC = 1;
    wire [31:0]result;
    wire [2:0] stateOut;
    initial begin
        #1;
        nRST = 0;
        #1;
        nRST = 1;
    end
    always begin
        #5;
        clk = ~clk;
    end
    reg [31:0]dataIn1 = 5;
    reg [31:0]dataIn2 = 10;

    mfState state(
        .clk(clk),
        .nRST(nRST),
        .stateOut(stateOut),
        .inEN(inEN),
        .resultAC(resultAC),
        .available(available),
        .mdfALUEN(inEN),
        .requireCDB(r)
    );
    mfALU alu(
        .clk(clk),
        .nRST(nRST),
        .EN(inEN),
        .dataIn1(dataIn1),
        .dataIn2(dataIn2),
        .state(stateOut),
        .result(result)
    );
endmodule