module reg_file(
  input wire clk, wr_en,
  input wire[2:0] read_reg1, read_reg2, write_reg,
  input wire[15:0] write_data,
  output reg[15:0] reg1, reg2
);

  reg[15:0] regs[7:0];
   
  integer i;
  initial begin
    for (i = 0; i < 8; i = i + 1) begin
      regs[i] = 1;
    end
  end
  
  always@* begin
    reg1 <= regs[read_reg1];
    reg2 <= regs[read_reg2];
  end
  
  always@(negedge clk) begin
      if(wr_en == 1)
        regs[write_reg] = write_data;
  end
  
endmodule
