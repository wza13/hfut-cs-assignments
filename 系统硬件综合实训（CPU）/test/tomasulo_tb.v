`include "../source/head.v"
`timescale 1ns/1ps
module tomasulo;
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
endmodule