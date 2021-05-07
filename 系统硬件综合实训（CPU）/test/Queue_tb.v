`timescale 1ns/1ps
`include "../source/head.v"
module Queue_tb;
    reg clk = 0;
    reg nRST = 1;
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
    reg requireAC;
    reg WEN;
    wire isFull;
    wire require;
    reg [31:0]dataIn;
    reg [4:0] labelIn;
    reg opIN;
    reg BCEN;
    reg [4:0]BClabel;
    reg [31:0]BCdata;
    wire opOut;
    wire [31:0]dataOut;
    wire [31:0]labelOut;
    initial begin
        #3;
        requireAC = 0;
        WEN = 1;
        dataIn = 20;
        labelIn = 4;
        opIN = 0;
        BCEN = 0;
        #10;
        requireAC = 0;
        WEN = 1;
        dataIn = 30;
        labelIn = 5;
        #10;
        BCEN = 1;
        BClabel = 4;
        BCdata = 25;
        requireAC = 1;
        dataIn = 40;
        labelIn = 0;
        #10;
        BClabel = 5;
        BCdata = 1;
        dataIn = 30;
        labelIn = 2;
        #10;
        requireAC = 1;
        dataIn = 16;
        labelIn = 8;
        #10;
        dataIn = 1;
        labelIn = 2;
        #10;
        #10;
        BCEN = 1;
        BClabel = 2;
        BCdata = 10;
        #20;
        $finish;
    end
    Queue queue(
        .clk,
        .nRST,
        .requireAC,
        .WEN,
        .isFull,
        .require,
        .dataIn,
        .labelIn,
        .opIN,
        .BCEN,
        .BClabel,
        .BCdata,
        .opOut,
        .dataOut,
        .labelOut
    );
endmodule