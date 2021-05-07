`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/27 17:16:49
// Design Name: 
// Module Name: frequencyChanger
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module frequencyChanger(
        input clk_in,
        output reg clk_out
    );
    reg[27:0] counter;
    initial begin
        counter = 0;
        clk_out = 0;
    end
    always@(posedge clk_in)begin
        counter = counter + 1;
        if(counter == 100000000)begin
            clk_out = ~clk_out;
        end
        if(counter == 200000000)begin
            clk_out = ~clk_out;
            counter = 0;
        end
    end
    
endmodule
