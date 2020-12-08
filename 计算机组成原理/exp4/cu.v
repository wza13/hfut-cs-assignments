module cu(
  input wire[6:0] ins_op,
  output reg wr_en,
  output reg[2:0] alu_op
);
 
  always@* begin
    if (ins_op == 0) begin
      wr_en = 1;
      alu_op = 0;
    end
  end

endmodule
