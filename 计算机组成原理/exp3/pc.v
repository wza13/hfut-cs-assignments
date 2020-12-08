module pc(
  input wire clk, reset,
  output reg[7:0] pc
);

  always@(posedge clk) begin
    if (reset == 1) pc = 0;
    else pc = pc + 1;
  end

endmodule
