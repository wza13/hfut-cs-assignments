`timescale 1ns/1ps
`include "../source/head.v"
module top_tb;
    reg clk = 1;
    reg nRST = 1;
    initial begin
        #1;
        nRST = 0;
        #2;
        nRST = 1;
        #60;
        
    end
    always begin
        #5;
        clk = ~clk;
    end
    top top_(
        .clk(clk),
        .nRST(nRST)
    );
endmodule