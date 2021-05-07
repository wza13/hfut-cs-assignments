`timescale 1ns/1ps

module Memory(
    input clk,
    input WEN,
    input [31:0] dataIn1,// Qj
    input [31:0] dataIn2,// A 
    input op,// for example, 1 is load, 0 is write，读写控制信号
    input [31:0] writeData,  //要向存储器写入的数据
    input [3:0] labelIn,
    output reg [3:0] labelOut, //接入到CDB的label输入上，应该是保留站编号中最后的1100部分
    output [31:0] loadData,  //从存储器读取的数据
    output reg available,   //可能是表示当前memory是否可用
    output reg require,   //CDB请求信号，当数据准备完毕后需要使用CDB发送数据
    //该信号将接入优先编码器cdbHelper
    input requireAC,  //是否可以使用CDB发送数据，来自CDBHelper优先编码器，1表示可以
    output isLastState
);
//memory是通过和RAM配合实现的，总体上实现了一个读取和写入延时都是10个周期的存储器
//目前的一个迷惑在于为什么写入的地址是输入的dataIn1和dataIn2的和
//我们进行实现的时候由于可以不用考虑存储器的读取和写入延时，所以可以不用实现的这么复杂
    reg [31:0] addr;
    reg nRD;
    reg nWR;
    integer States;
    initial begin
        States = 0;
        nRD = 1;
        nWR = 1;
        require = 0;
    end 
    wire readStatus;
    wire writeStatus;
    always@( posedge clk ) begin
        if (States == 0) begin
            if (WEN == 1) begin
            //当处于0状态，并且使能信号允许的时候，准备好地址
            //并换到状态1，并把传递给RAM的写和读控制信号设置好
            //这个时候RAM在clk的下降沿开始后就会开始读取/写入，并且需要10个周期准备完
                addr <= dataIn1 + dataIn2;
                labelOut <= labelIn;
                States <= 1;
            // States 浠?0 鍙樻垚1锛岃繘鍏ヨ瀛橀樁娈?
                if (op == 1) begin
                    nRD <= 0;
                end
                if (op == 0) begin
                    nWR <= 0;
                end
            end
            else begin // WEN == 0
                States <= 0;
                nRD <= 1;
                nWR <= 1;
            end
        end
        else if (States == 1) begin
        //储于状态1的时候，RAM正在进行读取/写入操作，此时每过一个clk判断是否写入/读取完毕
                nRD <= 1;
                nWR <= 1;
                if (readStatus == 1) begin
                //当读取完毕的时候
                //切换到状态2，并且向CDB优先编码器提出使用CDB的请求
                    States <= 2;
                    require <= 1;
                end
                if (writeStatus == 1) begin
                //当写入完毕的时候，不需要向CDB提出请求
                //状态变成0，等待下一次写入或读取
                    require <= 0;
                    States <= 0;
                end
            end
        else if (States == 2) begin
        //在状态2的时候，等待优先编码器返回的响应信号
        //若响应信号是1，表示CDB允许送数据，或者说CDB已经拿到了数据
        //修改状态为0，等待下一次读取/写入
            if (requireAC == 1) begin
                States <= 0;
            end
            else begin
            //否则如果CDB还没准备好，则一直储于状态2
                States <= 2;
            end
        end
        else 
            States <= 4;
            //整个文件都没有说储于状态4的时候应该做什么
            //所以这个状态4可能不会到达，其实没啥用
    end

    always@(*) begin
        if (States == 1 || States == 2) begin
        //在状态1的时候正在读取/写入延使，所以此时memory处于不可用状态
        //在状态2的时候读取的数据还没送到CDB上，所以此时memory也是不可用状态
            available = 0;
        end
        else begin
            available = 1; //TODO :maybe bugs not a good implementation
        end
    end

    RAM my_ram(
        .clk(clk),
        .address(addr),
        .writeData(writeData),
        .Dataout(loadData),
        .readStatus(readStatus),
        .writeStatus(writeStatus),
        .nRD(nRD),
        .nWR(nWR),
        .isLastState(isLastState)
    );

endmodule