`timescale 1ns / 1ps
// 淇′换鎻愪緵鍦板潃鍜屾暟鎹殑妯″潡锛屽湪鍐呭瓨鏈畬鎴愭搷浣滅殑鏃跺?欙紝addr鍜宒ata涓嶆敼鍙?
module RAM(
    input clk,
    input [31:0] address,
    input [31:0] writeData, // [31:24], [23:16], [15:8], [7:0]
    input nRD, // 涓?0锛屾甯歌锛涗负1,杈撳嚭楂樼粍鎬?
    input nWR, // 涓?0锛屽啓锛涗负1锛屾棤鎿嶄綔
    output reg [31:0] Dataout,
    output reg readStatus, // 濡傛灉杈撳嚭鏈夋晥鍒欎负1
    //readStatus和writeStatus分别表示读取和写入操作是否成功
    output reg writeStatus,
    output isLastState
    );
    //RAM是一个存储器，模仿了真实的存储器实现了读取和读出的延时
    //R和W分别控制读取和写入，当需要进行读取的时候，R会从0加到1，之后每个clk
    //下降沿都加一，但直到R为10的时候才进行读取操作，这里模仿了读取的延时
    //当需要写入的时候，W会从0加到1，W为1的时候会把输入写入，但是标志写入
    //成功的标志还是失败，不进行修改，之后每个CLK下降沿W加一
    //当W加到10的时候，把写入成功标志改成1，表示写入成功，这里模仿了写入延时
    integer R,W;
    assign isLastState = R == 9 || W == 9; //TODO
    initial begin
      R = 0;
      W = 0;
      readStatus = 0;
      writeStatus = 0;
    end
    reg [7:0] ram [0:60]; //瀛樺偍鍣?
    // 璁剧疆鐘舵?佸彉閲?
    always@( negedge clk) begin
        if (R == 0) begin
            if (nRD == 0) begin
                R <= 1;
            end
            else begin // nRD == 1
                R <= 0;
            end
        end
        else if (R == 10) begin
            R <= 0;            
        end
        else begin
            R <= R+1;
        end

        if (W == 0) begin
            if (nWR == 0) begin
                W <= 1;
            end
            else begin // nWR == 1
                W <= 0;
            end
        end
        else if (W == 10) begin
            W <= 0;            
        end
        else begin
            W <= W+1;
        end
    end
    always@(*) begin
        // if (readStatus == 1) begin
        if (R == 10) begin
            Dataout[7:0] = ram[address + 3]; 
            Dataout[15:8] = ram[address + 2];
            Dataout[23:16] = ram[address + 1];
            Dataout[31:24] = ram[address ];
            readStatus = 1;
        end
        else begin
            readStatus = 0;
        end
        if( W == 1 ) begin
            ram[address] = writeData[31:24];
            ram[address+1] = writeData[23:16];
            ram[address+2] = writeData[15:8];
            ram[address+3] = writeData[7:0];
        end
        if (W == 10) begin
            writeStatus = 1;
        end
        else begin
            writeStatus = 0;
        end
    end
endmodule