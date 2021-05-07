`timescale 1ns / 1ps
`include "head.v"
module RegFile(
    input clk,
    input nRST,
    input [4:0] ReadAddr1,//来自指令的rs
    input [4:0] ReadAddr2,//来自rt
    input RegWr, //labelEN，高电平有效，来自CU的isFullOut
    input [4:0] WriteAddr, //来自指令的rt或者rd
    input [3:0] WriteLabel,//来自四选一，两个保留站的writeable_labelOut和Queue的一个输出中选一个
    //在保留站中该信号表示了当前保留站中空着的项的label
    input [5:0] op,
    output [31:0] DataOut1,
    output [31:0] DataOut2,
    output [3:0] LabelOut1,
    output [3:0] LabelOut2,
    input BCEN,
    input [3:0] BClabel,
    input [31:0] BCdata
    );
    reg [31:0] regData[1:31];
    reg [3:0] regLabel[1:31];
    assign DataOut1 = (ReadAddr1 == 0) ? 0 : regData[ReadAddr1];   //0号寄存器值始终是0
    assign DataOut2 = (ReadAddr2 == 0) ? 0 : regData[ReadAddr2];   //读出是组合逻辑
    assign LabelOut1 = (ReadAddr1 == 0) ? 0 : regLabel[ReadAddr1];
    assign LabelOut2 = (ReadAddr2 == 0) ? 0 : regLabel[ReadAddr2];
    generate
        genvar i;
        for (i = 1; i < 32; i = i + 1) begin: regfile
            always @(posedge clk or negedge nRST) begin    //写入是时序逻辑
                if (!nRST) begin
                    regData[i] <= 32'b0;               //写generate的目的，当需要对寄存器刷新的时候必须用到循环
                    regLabel[i] <= 32'b0;
                end else begin
                    if (RegWr && WriteAddr == i) begin
                        if (op != `opSW)begin
                        //sw指令不需要写入寄存器值
                            regLabel[i] <= WriteLabel; // don't care whether WriteLabel is the same as BClabel. 
                            // Anyway, it is overriden by WriteLabel at last.
                        end
                            //tomasulo的一个步骤，指令流出以后给要写的目标寄存器标上该指令在保留站中的编号
                            //解决了WAW冲突
                            //遍历所有的寄存器，使能信号为1并且要写入的是当前的寄存器的时候
                            //把标志写入，标志里有要写入该寄存器的保留站编号
                            //writeLabel来自保留站中当前空着的保留站项label，也就是该项将保存了当前的指令
                    end else if (BCEN && regLabel[i] == BClabel) begin
                            //BClabel(broadcast label)是完成了计算的保留站编号，
                            //由CDB发送
                            //遍历所有的寄存器，标志等于该保留站编号的寄存器内容更新
                            //同时标志置零表示寄存器内容计算完毕
                        regLabel[i] <= 5'b0;
                        regData[i] <= BCdata;
                    end
                end
            end
        end
    endgenerate
endmodule