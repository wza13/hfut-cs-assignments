`timescale 1ns/1ps

module Memory_tb();
    reg clk;
    reg outEn;
    reg [31:0] dataIn1;// Qj
    reg [31:0] dataIn2;// A 
    reg op;// for example, 1 is load, 0 is write
    reg [31:0] writeData;
    reg requireAC;
    wire [31:0] loadData;
    wire available;
    wire requireCDB;
    
    initial begin
        requireAC = 0;
        clk = 0;
        outEn = 1;
        dataIn1 = 4;
        dataIn2 = 8;
        writeData = 32'h12345678;
        op = 0;
        #400
        requireAC = 1;
        dataIn1 = 4;
        dataIn2 = 8;
        writeData = 32'h12345678;
        op = 1;

    end

    always begin
        #10
        clk = ~clk;
    end

    Memory my_memory(
        .clk(clk),
        .WEN(outEn),
        .dataIn1(dataIn1),
        .dataIn2(dataIn2),
        .op(op),
        .writeData(writeData),
        .requireAC(requireAC),
        .loadData(loadData),
        .available(available),
        .require(requireCDB)
    );
    


endmodule