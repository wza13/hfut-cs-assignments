`timescale 1ns/1ps
`include "head.v"
// implement as queue.
module Queue(
    input clk,
    input nRST,
    input requireAC, // whether the ALU is available and ins can be issued，来自memory的avaible信号
    //表示当前memory能不能使用，由于memory读写需要延时，所以要等延时结束了才能用
    input WEN, // Write ENable，来自CU的ResStationEN，三个Queue都接入到该信号的第3个，为1的时候表示需要读入新的指令
    output isFull, // whether the buffer is full，只有RT队列该信号接入到CU的isFull的2号下标，其它俩队列都没接
    output require, // whether output is valid，三个队列组成的2:0信号经过一个与门输入到memory的WEN里
    //表示是否存在数据需要issue，也就是只有当三个队列都有数据需要issue的时候memory才可以开始工作

    input [31:0] dataIn,//三个队列的dataIn接入的地方各不相同
    input [3:0] labelIn,//三个队列的该信号接入的地方也不一样，Immd直接接地了
    input opIN,//三个队列的该信号都接入到了CU的QueueOp上，之后这个信号会送给opOut，
    //所以CU的QueueOp应该是读写控制信号

    input BCEN, // BroadCast ENable，接到CDB的EN上
    input [3:0] BClabel, // BoradCast label，接到CDB的labelOut上
    input [31:0] BCdata, //BroadCast value，接到CDB的dataOut上

    output opOut,//只有RT队列的该信号接入到了memory的op上，控制读写，高电平读，低电平写
    output [31:0] dataOut,//三个队列的该输出分别接入到memory的dataIn1和dataIn2和writeData上
    //dataIn1和dataIn2之和控制读写的地址
    output [3:0] labelOut,//只有RT队列的labelOut接到了memory的labelIn上，
    //memory直接把label输出到CDB，应该是1100部分的保留站编号
    input isLastState,//来自memory的isLastState，在读取或写入延时的最后一个周期其为1
    output [3:0] queue_writeable_label//只有RT队列的该信号接入到了四选一的一个输出上，
    //该信号和保留站的writeable_labelOut是同义的应该，内容是1100部分的保留站编号
    );
    //store指令的执行必须是顺序的，原因是如果有多个store指令，需要保证同一个地址的结果是最后一条store指令存的数据
    //所以存储保留站使用了队列来实现，先进入的指令先执行
    //由于从PC到RF读出操作数都是组合逻辑操作，所以在保留站之前全都是顺序流出的
    //顺序流出的指令在队列中保持了流出的顺序
    //所以dataout即输出的data只能是队头指令的数据
    
    //三个项中可用的那一个
    reg [3:0]availableIdLabel;
    //可用的Queue项号，此Queue实现中队列的项号和实际的下标不是统一的，项号只是一个逻辑上的，专门有IdLabel存Queue项号
    assign queue_writeable_label = availableIdLabel;
    //各个项是否可用
    reg [3:0]Busy;
    //label是产生指令中RS操作数的label，来自RF
    reg [3:0]Label[3:0];
    //data是RS操作数
    reg [31:0]Data[3:0];
    //idlabel是当前数据存在Queue的哪个label上，该label是逻辑上的label，和物理下标不一一对应
    reg [3:0]IdLabel[3:0];
    reg [3:0]op;
    initial begin
        Label[3] = 0;
        Busy[3] = 4'b1000;//Busy[3] = 0
        Data[3] = 0;
        IdLabel[3] = 0;
        op[3] = 0;
    end
    assign opOut = op[0];
    assign dataOut = Data[0];
    assign labelOut =IdLabel[0];

    //表示是否可以输出，当需要进行输出且memory可用的时候才可以输出
    wire issuable = require && requireAC;
    //表示是否三个项全满了
    wire wbusy = Busy[0] && Busy[1] && Busy[2]; //三位二进制相与
    //当三个项全满了并且不能流出的时候是full状态
    //!issuable改为!popable
    assign isFull = !poppable && wbusy;
    //require表示是否存在数据需要issue，0号项busy且数据已经准备好的话就可以输出了
    assign require = Busy[0] && Label[0] == 0;
    wire poppable;
    //当memory的延时进入只剩下一个clk就可以完成的时候，队列可以pop
    //此时队头的指令已经快执行完了，所以在Queue内的这条指令可以移走了
    assign poppable = isLastState;
    
    reg [1:0] first_empty;
    always@(*) begin
        if (!Busy[0]) first_empty = 0;
        else if (!Busy[1]) first_empty = 1;
        else first_empty = 2;
    end

    reg [1:0]lastBusyIndex;
    always@(*) begin
        if (Busy[2])
            lastBusyIndex = 2;
        else if (Busy[1])
            lastBusyIndex = 1;
        else if (Busy[0])
            lastBusyIndex = 0;
        else lastBusyIndex = -1;
    end

    //寻找可用的队列项号
    always@(*) begin
        if (wbusy) 
        //三个都忙的时候没有项可以使用
            availableIdLabel = 4'bx; // if busy, it is don't-care signal
        else if (IdLabel[0] != `QUE0 && IdLabel[1] != `QUE0 && IdLabel[2] != `QUE0)
        //如果不满足if(wbusy)条件，则必然至少有一个项不是busy的，由于busy的更新和idLabel是同步的，
        //所以必然三个项号里有一个项号是可以使用的，所以此时availableIdLabel必然可以得到可以使用的项号
            availableIdLabel = `QUE0;
        else if (IdLabel[0] != `QUE1 && IdLabel[1] != `QUE1 && IdLabel[2] != `QUE1)
            availableIdLabel = `QUE1;
        else availableIdLabel = `QUE2;
    end

    generate
        genvar i;
        for (i = 0; i <= 2; i = i + 1) begin
            always@(posedge clk or negedge nRST) begin
                if (!nRST) begin
                    Busy[i] <= 0;
                    Label[i] <= 0;
                    Data[i] <= 0;
                    IdLabel[i] <= 0;
                    op[i] <= 0;
                end else if (WEN) begin
                //WEN为1和保留站里的WEN是1意思是一样的，都是在下一个clk上升沿把下一条输入的指令保存
                    if (!poppable) begin
                    //popable说明队头指令是否已经存取结束，可以弹出
                    //当需要读入新指令（WEN=1），且队头指令还没执行完不能弹出（!popable)
                    //如果没有全满，则在队尾（first_empty)读入一条新指令
                    //如果全满了，由于不能弹出，所以卡住了，发生了结构冲突，只能更新各个项
                        if (!wbusy && i == first_empty) begin //Wen && !issuable && !busy
                            // input data to the first empty position
                            
                            Busy[i] <= 1;
                            //对于RS队列，如果CDB的数据是指令里的源操作数，那空项的数据为该源操作数，
                            //否则为寄存器里读到的源操作数
                            Data[i] <= BCEN && BClabel==labelIn ? BCdata : dataIn;
                            Label[i] <= BCEN && BClabel == labelIn ? 0 : labelIn;
                            op[i] <= opIN;
                            IdLabel[i] <= availableIdLabel;
                        end else begin
                            if (BCEN && BClabel == Label[i]) begin // else watch for bc
                                Data[i] <= BCdata;
                                Label[i] <= 0;
                            end
                        end 
                    end else begin
                    //当队头指令已经执行完可以弹出（popable=1），
                    //必定可以读入新指令
                    //所有指令前移一位，最后一个busy的位置读入新指令
                        if (i == lastBusyIndex) begin // WEN && issuable : queue must be available
                            // Busy is also 1, so do not change
                            Data[i] <= BCEN && BClabel == labelIn ? BCdata : dataIn;
                            Label[i] <= BCEN && BClabel ==  labelIn ? 0 : labelIn;
                            op[i] <= opIN;
                            IdLabel[i] <= availableIdLabel;
                        end else if (i < lastBusyIndex) begin // queue::pop()
                            Data[i] <= BCEN && BClabel == Label[i+1]? BCdata : Data[i+1];
                            Label[i] <= BCEN && BClabel == Label[i+1] ? 0 : Label[i+1];
                            op[i] <= op[i+1];
                            IdLabel[i] <= IdLabel[i+1];
                        end
                    end
                end else begin
                //WEN为0，也就是不需要读入新的指令的时候
                    if (poppable) begin
                    //当不需要读入新指令（WEN=0），并且可以弹出队头指令时
                    //所有指令前移一位，最后一条busy的指令清空（因为不需要读入新指令）
                        if (i == lastBusyIndex) begin //!Wen && issuable
                            Busy[i] <= 0;
                            Data[i] <= 0;
                            Label[i] <= 0;
                            op[i] <= 0;
                            IdLabel[i] <= 0;
                        end else if (i < lastBusyIndex) begin
                            Busy[i] <= Busy[i+1];
                            Data[i] <= BCEN && BClabel == Label[i+1] ? BCdata : Data[i+1];
                            Label[i] <= BCEN && BClabel ==  Label[i+1] ? 0 : Label[i+1];
                            op[i] <= op[i+1];
                            IdLabel[i] <= IdLabel[i+1];
                        end
                    end else begin //!WEN && !issuable
                    //当队头指令还在执行中时（!popable)
                    //既不需要读新指令，也不需要弹出队头指令的时候
                    //只需要把所有数据更新一下
                        if (BCEN && BClabel == Label[i]) begin
                            Data[i] <= BCdata;
                            Label[i] <= 0;
                        end
                    end
                end
            end
        end
    endgenerate
endmodule