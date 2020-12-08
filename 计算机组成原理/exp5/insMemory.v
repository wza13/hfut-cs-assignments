module insMemory(
  input wire[11:0] insAd,
  output reg[15:0] ins
);

  reg[15:0] instructions[4095:0];
  always@* begin
    ins = instructions[insAd];
  end
  
  initial begin
    // 测试过程
    // dataMemory 0号1号内存单元初始值分别为1 2
    // 0.LDA 0    acc = 1
    // 1.CSL      acc = 2
    // 2.BAN 11   不会跳转
    // 3.COM      acc = -3
    // 4.SHR      acc = -2
    // 5.BAN 2    跳转到 7
    // 7.JMP      跳转到 9
    // 9.ADD 1    acc = -2 + 2 = 0
    // 10.STA 0   0号内存单元由1变0
    // 11.LDA 1   acc = 2
    // 12.CLA     acc = 0
    // 13.STP     停机
    // 14.STA 1   由于已停机，1号内存单元不会变为0
    instructions[0] = 16'b0111_0000_0000_0000;
    instructions[1] = 16'b0011_0000_0000_0000;
    instructions[2] = 16'b1001_0000_0000_1010;
    instructions[3] = 16'b0001_0000_0000_0000;
    instructions[4] = 16'b0010_0000_0000_0000;
    instructions[5] = 16'b1001_0000_0000_0010;
    instructions[7] = 16'b1000_0000_0000_1001;
    instructions[9] = 16'b0101_0000_0000_0001;
    instructions[10] = 16'b0110_0000_0000_0000;
    instructions[11] = 16'b0111_0000_0000_0001;
    instructions[12] = 16'b0000_0000_0000_0000;
    instructions[13] = 16'b0100_0000_0000_0000;
    instructions[14] = 16'b0110_0000_0000_0001;
  end

endmodule
