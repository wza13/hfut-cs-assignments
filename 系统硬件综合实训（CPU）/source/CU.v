`include "head.v"
`timescale 1ns/1ps
module CU(
    input [5:0] op,
    input [5:0] func,
    output reg[2:0]ALUop,
    output reg[1:0]ALUSel,
    output reg[3:0]ResStationEN,
    input [2:0]isFull,
    output isFullOut,
    output RegDst,
    output vkSrc,
    output QueueOp
);
    always@(*) begin
        case(op)
            `opRFormat:
                case(func)
                    `funcADD, `funcMULU:
                        ALUop = 0;  
                    `funcSUB : ALUop = `ALUSub;
                    `funcAND : ALUop = `ALUAnd;
                    `funcOR : ALUop = `ALUOr;
                    `funcXOR : ALUop = `ALUXor;
                    `funcNOR : ALUop = `ALUNor;
                    `funcSLT : ALUop = `ALUSlt;
                endcase
            `opADDI : ALUop = `ALUAdd;
            `opORI : ALUop = `ALUOr;
            `opANDI : ALUop = `ALUAnd;
            `opXORI : ALUop = `ALUAnd;
            `opSLTI : ALUop = `ALUSlt;
            default:
                ALUop = 1;
        endcase
        if (op == `opHALT) begin
        //停机指令，ALUsel变成高阻态，终止PC自增和RF读取
            ALUSel = 2'bz;
            ResStationEN = 4'b0000;
        end
        else if (op == `opRFormat && func == `funcMULU) begin
            ALUSel = `multipleALU;
            ResStationEN = 4'b0010;
        end
        else if (op == `opRFormat && func == `funcDIVU) begin
        //除法没实现，所以除法位置的ALUsel是2'b11
            ALUSel = `divideALU;
            ResStationEN = 4'b0100;
        end 
        else if (op == `opLW || op == `opSW) begin
        //在指令是SW或者LW的时候，isFullOut应该输出Queue的full情况，所以ALUsel是2'b10；
            ALUSel = 2'b10;
            ResStationEN = 4'b1000;
        end else begin
            ALUSel = `addsubALU;
            ResStationEN = 4'b0001;
        end
    end
    //把队列和保留站的full信号输入，根据当前指令即将用哪个部件来送回该部件的full信号，将full信号取反输出到PC的
    //pcwrite，这样full为1的话PCwrite是0，也就是PC不能自增，实现了满了以后不能自增
    assign isFullOut = isFull[ALUSel];
    assign RegDst = op == `opRFormat ? `FromRd : `FromRt;
    assign vkSrc = op == `opRFormat ? `FromRtData : `FromImmd;
    assign QueueOp = op == `opLW ? `opLoad : `opStore;
endmodule    