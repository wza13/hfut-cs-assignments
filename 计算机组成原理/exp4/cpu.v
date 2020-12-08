module cpu(
  input wire clk, reset
);
 
  wire wr;
  wire[7:0] insAd;
  wire[15:0] ins;
  wire[2:0] alu_op;
  wire[15:0] alu_in1, alu_in2, alu_z;
  
  pc pc(
    .clk(clk), .rst(reset), .pc(insAd)
  );
  
  insMemory insMemory(
    .Addr(insAd), .Ins(ins)
  );
  
  cu cu(
    .ins_op(ins[15:9]), .alu_op(alu_op), .wr_en(wr) 
  );
  
  reg_file reg_file(
    .clk(clk), .wr_en(wr),
    .read_reg1(ins[8:6]), .read_reg2(ins[5:3]),
    .reg1(alu_in1), .reg2(alu_in2),
    .write_reg(ins[2:0]), .write_data(alu_z)
  );
  
  alu alu(
    .alu_op(alu_op),
    .in1(alu_in1), .in2(alu_in2), .Z(alu_z)
  );
  
endmodule
