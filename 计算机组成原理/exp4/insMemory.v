module insMemory(
  input wire[7:0] Addr,
  output reg[15:0] Ins
);

  reg[15:0] instructions[255:0];

  integer i;
  initial begin
    for (i = 0; i < 256; i = i + 1) begin
      instructions[i][2:0] = (i + 2) % 8;
      instructions[i][5:3] = (i + 1) % 8;
      instructions[i][8:6] = i % 8;
      instructions[i][15:9] = 0;
    end
  end
  
  always@* begin
    Ins = instructions[Addr];
  end
  
endmodule
