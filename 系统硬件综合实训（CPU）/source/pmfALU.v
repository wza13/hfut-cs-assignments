`timescale 1ns/1ps
`include "head.v"
module pmfState(
    input clk,
    input nRST,
    output reg [1:0] stateOut,//控制pmfALU的状态
    input WEN, //来自alu保留站的OutEn，当保留站内存在指令准备完毕则输出1
    input requireAC, //CDB响应信号，由cdbHelper发回，为1的时候表示CDB已经拿走了数据
    output available,//当前ALU是否可用，接入到alu保留站的EXEable
    output pmfALUEN, // send to pmfALU as EN
    input [2:0]op,//来自保留站的opOut，准备完毕的指令的操作码
    output require //CDB请求信号，当ALU计算完毕后向优先编码器cdbHelper发出申请
);
    //和mfALU一样
    assign available = (require && requireAC) || stateOut == `sIdle;
    assign pmfALUEN = available && WEN;
    //当处于这两个状态的时候表示计算完毕，向CDBHelper发出需要CDB的申请
    assign require = stateOut == `sPremitiveIns || stateOut == `sMAdd;
    initial begin
        stateOut = `sIdle;
    end
    //sPremitiveIns表示加法运算完毕，在pmfALU中，如果算的是加法，在状态还是idle的时候的一个周期
    //就已经把结果计算完毕了，这个周期的时候pmfstate才把状态切换成sPremitiveIns，所以在这个状态的时候可以直接发起CDB申请。
    //当进行减法运算的时候，第一个clk ALU读入的还是idle状态，把操作数读入，这个时候操作数还没取反
    //pmfState在第一个clk把状态切换成inverse，在第二个clk，ALU把操作数取反，并得到运算结果，
    //pmfState把状态变成Madd，表示减法运算完毕并向CDB提出请求，如果CDB一直没回应，那么每个clk
    //ALU和pmfstate啥都不干，直到有了回应则pmfState把状态变成idle
    always@(posedge clk or negedge nRST) begin
        if (!nRST) begin
            stateOut <= `sIdle;
        end else begin
            case (stateOut)
                `sIdle : 
                    if (WEN)
                    //若当前是空闲状态，判断WEN，如果保留站有准备好的指令，
                    //则根据该指令的操作码给状态赋值，以便于之后控制计算
                        stateOut <= op == `ALUSub ? `sInverse : `sPremitiveIns;
                `sPremitiveIns, `sMAdd : begin
                //当处于这两个状态的时候表示计算完毕，
                //若接收到了CDB的回应信号，则把状态设置成空闲
                    if (requireAC) begin
                        // if (WEN) begin
                            // stateOut <= op == `ALUSub ? `sInverse : `sPremitiveIns;
                        // end else begin
                            stateOut <= `sIdle;
                        // end
                    end
                end
                `sInverse:
                    stateOut <= `sMAdd;
            endcase
        end
    end
endmodule

module pmfALU(
    input clk,
    input nRST,
    input EN, // linked from State::pmfALUEN
    input [31:0] dataIn1,//来自保留站，第一个操作数
    input [31:0] dataIn2,//来自保留站，第二个操作数
    input [1:0] state,//来自pmfState，控制ALU的状态
    input [2:0]op,//来自保留站的opOut，当前执行指令的操作码
    output reg [31:0] result,//送到CDB的data0
    input [3:0] labelIn,//来自保留站的ready_labelOut，当前指令在保留站中的标号
    output reg [3:0] labelOut//送到CDB的label0
);
    reg [31:0] data1_latch;
    reg [31:0] data2_latch;
    reg [31:0] inverseData2_latch;
    reg [2:0] op_latch;
    initial begin
        result = 0;
        labelOut = 0;
    end
    always@(posedge clk or negedge nRST) begin
        if (!nRST) begin
            data1_latch <= 32'b0;
            data2_latch <= 32'b0;
            inverseData2_latch <= 31'b0;
        end else begin
            if (EN)
                op_latch <= op;
            case (state)
                `sIdle, `sPremitiveIns, `sMAdd :
                    if (EN) begin
                        data1_latch <= dataIn1;
                        data2_latch <= dataIn2;
                        labelOut <= labelIn;
                    end
                `sInverse :
                    inverseData2_latch <= ~data2_latch + 1;
            endcase
        end
    end

    always@(*) begin
        case (op_latch)
            `ALUAdd : 
                result = data1_latch + data2_latch;
            `ALUSub : 
                result = data1_latch + inverseData2_latch;   //减法转换成加法，转换是取反加一
            `ALUAnd :
                result = data1_latch & data2_latch;
            `ALUOr:
                result = data1_latch | data2_latch;   
            `ALUXor:
                result = data1_latch ^ data2_latch;
            `ALUNor:
                result = ~ (data1_latch | data2_latch);
            `ALUSlt:
                result = data1_latch < data2_latch ? 1 : 0;
            default:
                result = 32'b0;
        endcase
    end
endmodule
