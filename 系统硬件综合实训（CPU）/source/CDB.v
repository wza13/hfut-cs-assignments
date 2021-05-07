`timescale 1ns/1ps
`include "head.v"
module CDBHelper(
    input [3:0] requires,
    //cdbHelper的requires信号由两个ALU和数据存储提供，也就是说这个requires信号应该是
    //部件准备好数据以后需要用CDB发送数据时的请求信号
    //根据之后先判断requires[3]，之后才判断其它的，可以知道requires[3]是优先级最高的
    //也就是memory是优先级最高的，当memory准备好数据以后先响应memory的
    output reg [3:0] accepts
    //accepts，0接入pmfstate的requireAC，1接入mfState，3接入memory
    //cdbHelper从两个ALU和memory接受到require信号之后，再把accepts信号发回这三个部件
    //因此accepts信号可能是一个响应信号，这样cdbHelper的功能就是接收到发来的发送数据请求之后
    //返回响应信号，并且memory的优先级是最高的，其次是mfstate，最后是pmfState
);
//所谓的CDBHelper其实就是个优先编码器，多个输入的请求中requires[3]，
//也就是memory是优先级最高的，一旦该部件提出要使用CDB发送数据的请求，
//就响应该部件，把使用权交给他
    initial begin
        accepts = 4'b0000;
    end
    always@(*) begin
        if (requires[3])
            accepts = 4'b1000;
            //根据以上猜想，这里的accepts信号可能表示的是CDB的使用权，1表示可以使用，0表示不行
        else if (requires[2])
            accepts = 4'b0100;
        else if (requires[1])
            accepts = 4'b0010;
        else if (requires[0])
            accepts = 4'b0001;
        else
            accepts = 4'b0000;
    end
endmodule

module CDB(
    input [31:0] data0,//接到pmfALU的result上
    input [3:0] label0,//接到pmfALU的labelOut上
    input [31:0] data1,//接到mfALU的result上
    input [3:0] label1,//接到mfALU的labelOut上
    input [31:0] data2,//接地
    input [3:0] label2,//接地
    input [31:0] data3,//接到memory的loadData，从memory读出的数据
    input [3:0] label3,//接到memory的labelOut上，memory的labelOut直接输出了Queue的labelOut
    input [3:0] sel,//0：pmfState, 1：mfState, 2:0, 3：memory，接到这三个部件的require上，表示对CDB的请求信号
    //sel和cdbHelper的requires输入接入的是同一条线
    //cdbHelper优先响应memory的请求
    output reg[31:0] dataOut,
    //接到：两个保留站的BCdata，RF的BCdata，三个Queue的BCdata
    output reg[3:0] labelOut,
    //接到：两个保留站的BClabel，RF的BClabel，三个Queue的BClabel
    output EN
    //接到：两个保留站的BCEN，RF的BCEN，三个Queue的BCEN
);
//这里的优先级不知道为什么和上面的cdbHelper是相反的，
//假设pmfState和memory同时输出require=1，memory是requires[3]，pmfState是requires[0]
//那么在cdbHelper里返回的accept信号是1000，也就是给memory返回了确认信号，
//但是在这里却先判断sel[0]，也就是pmfState的，并且把pmfState的数据放到CDB上，
//这样出现了明明给memory返回了确认，却把pmfState的数据放上去了
//可能是作者写反了吧。
    initial begin
        dataOut = 0;
        labelOut = 0;
    end
    always@(*) begin
        if (sel[3]) begin
            dataOut = data3;
            labelOut = label3;
        end else if (sel[2]) begin
            dataOut = data2;
            labelOut = label2;
        end else if (sel[1]) begin
            dataOut = data1;
            labelOut = label1;
        end else begin
            dataOut = data0;
            labelOut = label0;
        end
    end
    //三个部件都没请求信号，即三个require都是0的时候，EN才是0
    assign EN = | sel;
endmodule