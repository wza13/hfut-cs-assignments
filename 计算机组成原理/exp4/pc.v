module pc(
  input wire clk, rst,
  output reg[7:0] pc
);
  
  always@(posedge clk) begin
    if (rst == 1) pc = 0;
    else pc = pc + 1;
  end
 
endmodule
