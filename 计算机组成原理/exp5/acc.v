module acc(
  input wire clk, wr,
  input wire[15:0] inData,
  output reg[15:0] acc
);

  always@(negedge clk) begin
    if (wr == 1)
      acc = inData;
  end
  
  initial begin
    acc = 0;
  end

endmodule
