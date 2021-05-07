`timescale 1ns/1ps

module mux4to1_4(
    input [1:0] sel,
    input [3:0] dataIn0,
    input [3:0] dataIn1,
    input [3:0] dataIn2,
    input [3:0] dataIn3,
    output reg[3:0] dataOut
);
    always@(*) begin
        case(sel)
            2'b00: dataOut = dataIn0;
            2'b01: dataOut = dataIn1;
            2'b10: dataOut = dataIn2;
            2'b11: dataOut = dataIn3;
        endcase
    end
endmodule