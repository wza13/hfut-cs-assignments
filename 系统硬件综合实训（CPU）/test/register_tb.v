`timescale 1ns/1ps
`include "../source/head.v"
module RegFile_tb();
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
reg [4:0] ReadAddr1;
reg [4:0] ReadAddr2;
reg RegWr;
reg [4:0] WriteAddr;
reg [4:0]WriteLabel;
reg BCEN;
reg [4:0]BClabel;
reg [31:0]BCdata;
wire [31:0] DataOut1;
wire [31:0] DataOut2;
wire [4:0] LabelOut1;
wire [4:0] LabelOut2;
initial begin
    #4;
    ReadAddr1 = 1;
    ReadAddr2 = 2;
    RegWr = 1;
    WriteAddr = 2;
    WriteLabel = 3;
    BCEN = 0;
    #10;
    ReadAddr1 = 2;
    ReadAddr2 = 4;
    RegWr = 0;
    BCEN = 1;
    BClabel = 3;
    BCdata = 10;
end

RegFile regfile(
    .clk,
    .nRST,
    .ReadAddr1,
    .ReadAddr2,
    .RegWr,
    .WriteAddr,
    .WriteLabel,
    .DataOut1,
    .DataOut2,
    .LabelOut1,
    .LabelOut2,
    .BCEN,
    .BClabel,
    .BCdata
);
endmodule