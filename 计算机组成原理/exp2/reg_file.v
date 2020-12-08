module reg_file(
  input wire WE, clk,
  input wire [2:0] RA, RB, RW,
  input wire [15:0] busW,
  output wire [15:0] busA, busB
);

  reg [15:0] regs[0:7];
  
  assign busA = regs[RA];
  assign busB = regs[RB];
  always@(posedge clk) begin
    if (WE == 1)
      regs[RW] = busW;
  end

endmodule
