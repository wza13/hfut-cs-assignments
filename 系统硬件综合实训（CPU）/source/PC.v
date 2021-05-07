`timescale 1ns / 1ps
`include "head.v"
module PC(
    input clk,
    input nRST,
    input [31:0]newpc,
    input pcWrite,//当执行的是停机指令的时候，pcWrite为0
    //另一个条件是当前执行的指令需要的部件（保留站，队列）是否满了，如果满了，pcWrite也是0
    output reg [31:0]pc
    );
    initial begin
        pc = 0;
    end
    always@(posedge clk or negedge nRST) begin
        if (pcWrite || !nRST) begin
            pc <= nRST == 0 ? 0 : newpc;             //pc的值或者写入或者重置
        end else begin
            pc <= pc;
        end
    end
endmodule

module PCHelper(
    input [31:0] pc,
    input [15:0] immd16,
    input [25:0] immd26,
    input [1:0] sel,//在例子中接地了，所以每次更新操作 都是PC+4
    input [31:0] rs,
    output reg [31:0] newpc
    );
    //通过和CU配合来控制下一次PC自增的值
    initial begin
        newpc = 0;
    end
    wire [31:0]exd_immd16 = { {16{immd16[15]}}, immd16};      //符号扩展
    always@(*) begin
        case (sel)
            `NextIns : newpc <= pc + 4;
            `RelJmp : newpc <= (pc + 4 + (exd_immd16 << 2));
            `AbsJmp : newpc <= {pc[31:28], immd26, 2'b00};
            `RsJmp : newpc <= rs;
        endcase
    end
endmodule
