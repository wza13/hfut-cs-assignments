`timescale 1ns/1ps
`include "head.v"
module mfState(
    input clk,
    input nRST,
    output reg [2:0] stateOut, // 只接到ALU
    input WEN,//来自于mul保留站的OutEn，表示保留站的输出是否有效
    //参考保留站可以知道，只要保留站内有一条指令的俩操作数准备完毕，该指令可以计算了
    //那么OutEn信号就是1，同时保留站会把该指令流出
    //也就是WEN为1的时候表示保留站有指令准备好了，已经准备输出
    input requireAC,//优先编码器响应信号，CDBHelper接收到CDB请求后根据优先级返回该信号，1表示
    //MFALU可以向CDB传输数据
    output available,//接入到保留站的EXEable信号上，表示当前ALU是否可以执行/可用
    output mfALUEN, // determine whether mdfALU should work
    //接入到mf_alu的EN信号上
    input [2:0] op, // do nothing，来自mul保留站的opOut，是保留站中保存的输出到ALU指令的操作码
    output require  //CDB请求信号，当ALU计算完毕之后，利用该信号向优先编码器申请CDB使用权
    //1表示申请
);
    //若ALU不是空闲状态，那么当对CDB提出申请以后只有当也接收到了CDB的响应信号以后ALU才算是可用
    //也就是说，若ALU不是空闲状态，那么当：没提出对CDB的申请时（此时ALU正在运算），
    //提出了对CDB的申请而还没接收到响应时（此时正在等待CDB的响应信号）
    //ALU都处于忙碌的状态，不可用
    //只要state是Idle，那么ALU必定空闲，必定可用
    assign available = (require && requireAC) || stateOut == `sIdle;
    //mfALUEN接入到了ALU的EN信号上，EN是1的时候ALU才可以进行计算
    //所以这里的available和WEN同时是1的时候ALU才可以进行计算
    //WEN只控制了第一层的ALU的计算，之后的计算不需要WEN控制
    //在第一个CLK经过以后，state会从空闲变成Mul32，而计算过程还未结束（需要五个CLK）
    //所以此时的available是0，输出的mfALUEN也是0
    assign mfALUEN = available && WEN;
    //sMulAnswer可能表示的是ALU计算完毕的状态，当处于该状态的时候
    //require是1，也就是需要向CDB发送数据，提出了申请
    assign require = stateOut == `sMulAnswer;
    initial begin
        stateOut = `sIdle;
    end
    always@(posedge clk or negedge nRST) begin
        if (!nRST) begin
        //重置信号，将ALU的状态重置成空闲
            stateOut <= `sIdle;
        end else begin
            case(stateOut)
                `sMulAnswer:
                //当处在ALU计算完毕的状态的时候，对是否接收到了CDB的返回信号进行判断
                //如果接收到了返回信号，表示CDB已经拿走了计算结果，ALU的全计算过程已经完毕，
                //可以进行下一条指令的计算
                //这个时候对WEN进行判断，判断保留站中是否有准备好的指令，
                //如果有，那么状态改变为sMul32(这个状态可能是表示ALU正在计算）
                //如果没有，那么ALU进入空闲状态。
                //当还没接收到CDB的返回信号的时候，啥也不干
                    if (requireAC) begin
                        stateOut <= WEN ? `sMul32 : `sIdle;
                    end
                `sIdle:
                //当ALU是空闲的状态的时候，对WEN进行检测，
                //如果是1，表示保留站有指令准备好了，把状态切换成正在计算
                    if (WEN)
                        stateOut <= `sMul32;
                default:
                    stateOut <= stateOut + 1;
            endcase
        end
    end
endmodule

module mfALU(
    input clk,
    input nRST,
    input EN, // linked from state::mfALUEN
    input [31:0] dataIn1,//来自mul保留站的dataOut1，第一个操作数
    input [31:0] dataIn2,//来自mul保留站的dataOut2，第二个操作数
    input [2:0] state,//来自mfState的stateOut，当前ALU的状态
    input [3:0] labelIn,//来自保留站的ready_labelOut，是保留站内准备好的指令所在的项号
    output reg [31:0] result,
    output reg [3:0] labelOut //只要EN为1，这里就输出labelIn
    //labelOut和result将接到CDB上
);
//利用阵列乘法器加速定点数乘法
    reg [31:0]temp32[0:31];
    reg [31:0]temp16[0:15];
    reg [31:0]temp8[0:7];
    reg [31:0]temp4[0:3];
    reg [31:0]temp2[0:1];
    
    initial begin
        result = 0;
        labelOut = 0;
    end

    always@(posedge clk or negedge nRST) begin
        if (!nRST) begin
            labelOut <= 0;
        end else if (EN) begin
            labelOut <= labelIn;
        end
    end

//注意generate的特点，产生了32个并行的部件，可以同时进行计算
//所以第一层只需要一个clk就可以把temp32的32个都计算完
//所以每个CLK计算一层，总共需要五个CLK就可以计算完整个乘法
//另外，在第一个CLK过去以后，EN信号会变成零，所以之后的计算过程不能让EN来控制
    generate
        genvar i;  
        for (i = 0; i <= 31; i=i+1) begin
            always@(posedge clk or negedge nRST) begin
                if (!nRST) begin
                    temp32[i] <= 32'b0;
                end else if (EN) begin
                    temp32[i] <= dataIn2[i] == 0 ? 0 : dataIn1 << i;
                    //根据dataIn2的每位是不是0来把dataIn1左移对应位数，并赋值给temp32的32个寄存器
                end
            end
        end

        for (i = 0; i <= 15; i=i+1) begin
            always@(posedge clk or negedge nRST) begin
                if (!nRST) begin
                    temp16[i] <= 32'b0;
                end else begin
                    temp16[i] <= temp32[i] + temp32[i + 16];
                end
            end
        end

        for (i = 0; i <= 7; i=i+1) begin
            always@(posedge clk or negedge nRST) begin
                if (!nRST) begin
                    temp8[i] <= 32'b0;
                end else begin
                    temp8[i] <= temp16[i] + temp16[i + 8];
                end
            end
        end

        for (i = 0; i <= 3; i=i+1) begin
            always@(posedge clk or negedge nRST) begin
                if (!nRST) begin
                    temp4[i] <= 32'b0;
                end else begin
                    temp4[i] <= temp8[i] + temp8[i + 4];
                end
            end
        end
    endgenerate
    always@(posedge clk or negedge nRST) begin
        if (!nRST) begin
            temp2[0] <= 32'b0;
            temp2[1] <= 32'b0;
            result <= 32'b0;
        end else begin
            temp2[0] <= temp4[0] + temp4[2];
            temp2[1] <= temp4[1] + temp4[3];
            result <= temp2[0] + temp2[1];
        end
    end
endmodule