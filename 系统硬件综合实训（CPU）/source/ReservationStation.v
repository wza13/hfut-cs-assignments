`timescale 1ns/1ps
`include "head.v"

module ReservationStation(
    input clk,
    input nRST,
    input EXEable, // whether the ALU is available and ins can be issued
    //来自ALU的available，表示当前ALU是否可用，当ALU是空闲状态的时候这个标志是1
    input WEN, // Write ENable 来自CU的ResStationEN

    input [1:0] ResStationDst,// TODO:  保留站的编号，alu保留站是01，mul保留站是10，直接接地和电源
    //保留站每个项的编号（全局）格式是 保留站编号：保留站内项号
    input [2:0] opCode,   //来自CU的ALUOp，直接输出到opOut
    input [31:0] dataIn1,//来自RF的DataOut1
    input [3:0] label1,//来自RF的LabelOut1
    input [31:0] dataIn2,//来自RF的DataOut2和Decoder的immd16的两种扩展组成的三选一电路
    input [3:0] label2,//来自RF的LabelOut2和地的二选一电路

    input BCEN, // BroadCast ENable，来自CDB的EN信号，memory，pmfState, mfState三个中只要有一个提出使用CDB的申请
    //BCEN就是1
    input [3:0] BClabel, // BoradCast label  来自CDB的labelOut
    input [31:0] BCdata, //BroadCast value 来自CDB的dataOut

    output [2:0] opOut,//接入state的op，或者ALU的OP入口，当前指令的操作码，控制ALU进行什么运算
    output [31:0] dataOut1,
    output [31:0] dataOut2,
    //两个dataOut是两个操作数，接入到ALU的两个操作数输入端
    output isFull, // whether the buffer is full
    //接入到CU的isFull，CU该输入中还有其它部件，其中alu保留站是0，mul保留站是1，一个队列是2
    output OutEn, // whether output is valid，接入到State的WEN输入，指示保留站内是否有指令准备好
    output [3:0] ready_labelOut,//接到ALU的labelIn，传输当前运行指令的保留站编号
    output [3:0] writeable_labelOut//接到mux4to1_4的一个输入
    //该三选一是选择一个信号到RF的WriteLabel，选择哪个由CU决定，三个信号分别来自一个队列和两个保留站
    //根据RF把数据输入到这三个地方，可能和控制RF数据输出有关
    );
//总共只有两个保留站，mfALU的和pmfALU的，
//每个保留站有三个项
    // 璁剧疆浜嗕笁涓?淇濈暀绔?
    // 鑻ヤ娇b2'11鏉ョ储寮曪紝鏃犳晥
    //busy在指令刚写入该项的时候设置为1，在指令计算完成后恢复为0
    reg Busy[2:0];
    reg [1:0]Op[2:0];
    reg [3:0]Qj[2:0];
    reg [31:0]Vj[2:0];
    reg [3:0]Qk[2:0];
    reg [31:0]Vk[2:0];

    // 褰撳墠鍙?鍐欏湴鍧� ,2'b11鍒欎负涓嶅彲锟???
    //表示当前空着的项
    reg [1:0] cur_addr ;
    // 褰撳墠灏辩华鍦板潃,2'b11鍒欎负涓嶅彲锟???
    //表示两个操作数都已经准备好，随时可以送给ALU进行计算的项
    reg [1:0] ready_addr ;
    initial begin
        Busy[0] = 0;
        Busy[1] = 0;
        Busy[2] = 0;
    end
    
    always@(posedge clk or negedge nRST) begin
        if (nRST == 0) begin 
            Busy[0] <= 0;
            Busy[1] <= 0;
            Busy[2] <= 0;
        end
        else begin 
            if (WEN == 1) begin
                if (cur_addr != 2'b11 && Busy[cur_addr] == 0) begin
                    Busy[cur_addr] <= 1;
                    Op[cur_addr] <= opCode;
                    if (BCEN == 1 & label1 == BClabel) begin
                        //tomauslo：寄存器换名，在新的指令写入的时候，先从CDB看第一个源操作数寄存器等待的数据是否在
                        //CDB上，在的话可以直接拿过来
                        Qj[cur_addr] <= 0;
                        Vj[cur_addr] <= BCdata;
                    end
                    else begin
                    //tomasulo：寄存器换名，CDB没有的话，直接把RF送来的源操作数值和label写入
                    //此时写入的源操作数值可能是正确的，此时label应该是0，或者还在计算，此时label不是0，
                    //寄存器换名之后，保留站中的项就和RF分开了，如果Vj还没准备好，那Qj里会标注其等待的label，
                    //在之后的clk到来的时候，会在下面的watch CDB的地方把计算完的值写入，不需要再从RF里读取
                    //解决了WAR冲突
                        Qj[cur_addr] <= label1;
                        Vj[cur_addr] <= dataIn1;
                    end
                    //源操作数2的步骤是一样的，但是根据指令格式不同源操作数2也不同，所以label2是受到选择电路控制的
                    if (BCEN == 1 && label2 == BClabel) begin
                        Qk[cur_addr] <= 0;
                        Vk[cur_addr] <= BCdata;
                    end
                    else begin
                        Qk[cur_addr] <= label2;
                        Vk[cur_addr] <= dataIn2;
                    end
                end
                //  maybe generate latch
            end
            // watch CDB
            //解决了RAW冲突
            if (BCEN == 1 ) begin 
                if (BClabel[3:2] == ResStationDst) begin
                //注意BClabel的来源，BClabel是完成了计算的指令所在的保留站的项的编号，
                //所以第一个if是把该项的busy设置为0
                    Busy[BClabel[1:0]] <= 0; 
                end
                //挨个看busy是1的项，把等待CDB上数据的项进行更新
                if (Busy[0] == 1 && Qj[0] == BClabel) begin
                    Vj[0] = BCdata;
                    Qj[0] = 0;
                end
                if (Busy[1] == 1 && Qj[1] == BClabel) begin
                    Vj[1] = BCdata;
                    Qj[1] = 0;
                end
                if (Busy[2] == 1 && Qj[2] == BClabel) begin
                    Vj[2] = BCdata;
                    Qj[2] = 0;
                end
                if (Busy[0] == 1 && Qk[0] == BClabel) begin
                    Vk[0] = BCdata;
                    Qk[0] = 0;
                end
                if (Busy[1] == 1 && Qk[1] == BClabel) begin
                    Vk[1] = BCdata;
                    Qk[1] = 0;
                end
                if (Busy[2] == 1 && Qk[2] == BClabel) begin
                    Vk[2] = BCdata;
                    Qk[2] = 0;
                end
            end
        end
    end    
    

    assign opOut = Op[ready_addr];
    assign dataOut1 = Vj[ready_addr];
    assign dataOut2 = Vk[ready_addr];
    
    // 浼樺厛璇戠爜锛屼娇鐢ㄧ粍鍚堬拷?锟借緫鐢熸垚褰撳墠鍙?鍐欏湴鍧�
    // 鑻ヤ负2'b11鍒欎笉鍙?鍐?
    //00号保留站项的优先级最高
    always@(*) begin
        if (Busy[0] == 0) begin
            cur_addr = 2'b00;
        end
        else if (Busy[1] == 0) begin
            cur_addr = 2'b01;
        end
        else if (Busy[2] == 0) begin
            cur_addr = 2'b10;
        end
        else
            cur_addr = 2'b11;
    end

    // 淇濈暀绔欐槸鍚︽弧
    //只有当cur_addr是11b的时候&cur_addr才是1
    assign isFull = & cur_addr;

    // 鏄?鍚﹀氨缁?
    // 璁＄畻褰撳墠灏辩华鍦板潃锛屼互鍙婂氨缁?鐘讹????
    //计算两个操作数都准备好的项
    //00项的优先级是最高的
    always@(*)begin
        if (Busy[0] == 1 && Qj[0] == 0 && Qk[0] == 0) begin
            ready_addr = 2'b00;
        end
        else begin
            if(Busy[1] == 1 && Qj[1] == 0 && Qk[1] == 0) begin
                ready_addr = 2'b01;
            end
            else begin 
                if (Busy[2] == 1 && Qj[2] == 0 && Qk[2] == 0 ) begin
                    ready_addr = 2'b10;
                end
                else 
                    ready_addr = 2'b11;
            end
        end
    end

    //只有当ready_addr是11b的时候outEn才是0
    //也就是只要保留站内有项准备好了，那OutEn就是1
    assign OutEn = ~ (&ready_addr);

    //指定的保留站里准备好的保留站项号
    assign ready_labelOut = {ResStationDst,ready_addr};// TODO:
    //将当前空闲的保留站项编号输出，在ALU的控制下输出到RF的WriteLabel，作为下一个指令要保存的保留站号
    assign writeable_labelOut = {ResStationDst, cur_addr};

endmodule