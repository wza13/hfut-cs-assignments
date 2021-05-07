`timescale 1ns/1ps
module ROM (  
    input nrd, //在例子中接地了
    output reg [31:0] dataOut,
    input [31:0] addr//接到PC的输出
    ); 

    reg [7:0] rom [0:99]; 
    initial begin 
         //$readmemb ("E:/myfile/计算机体系结构/课设/Tomasulo-master/rom/mytest.mem", rom);
         rom[0] = 8'b00100000;
         rom[1] = 8'b00000001;
         rom[2] = 8'b00000000;
         rom[3] = 8'b00000001;
         
         rom[4] = 8'b00100000;
         rom[5] = 8'b00000001;
         rom[6] = 8'b00000000;
         rom[7] = 8'b00000001;
         
         rom[8] = 8'b00100000;
         rom[9] = 8'b00000001;
         rom[10] = 8'b00000000;
         rom[11] = 8'b00000001;
         
         rom[12] = 8'b11111100;
         rom[13] = 8'b00000000;
         rom[14] = 8'b00000000;
         rom[15] = 8'b00000000;
    end
    always @(*) begin
        if (nrd == 0) begin
            dataOut[31:24] = rom[addr];      //rom定义了100个8位存储，但是32位地址也还可以寻址
            dataOut[23:16] = rom[addr+1];
            dataOut[15:8] = rom[addr+2];
            dataOut[7:0] = rom[addr+3];
        end else begin
            dataOut[31:0] = {32{1'bz}};      //32个随机信号
        end
    end
endmodule