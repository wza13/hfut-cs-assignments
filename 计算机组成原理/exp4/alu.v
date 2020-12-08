module alu(
  input wire[15:0] in1, in2,
  input wire[2:0] alu_op,
  output reg[15:0] Z
);

  always@* begin
    case(alu_op)
      3'b000: Z = in1 + in2;
      3'b001: Z = in1 - in2;
      3'b010: Z = in1 & in2;
      3'b011: Z = in1 | in2;
      3'b100: Z = in1 << in2;
      3'b101: Z = in1 >> in2;
    endcase
  end
  
endmodule
