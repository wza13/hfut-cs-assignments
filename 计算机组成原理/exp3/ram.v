module ram(
  input wire clk, WE,
  input wire[8:0] ad,
  input wire[15:0] in,
  output wire[15:0] out
);

  reg[15:0] words[511:0];
  
  assign out = words[ad];
  
  always@(posedge clk) begin
    if (WE == 0)
      words[ad] = in;
  end

endmodule
