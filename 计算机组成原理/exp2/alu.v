module alu(
  input wire [15:0] in1, in2,
  input wire [2:0] op,
  output reg [15:0] out
);

  always@* begin
    case (op)
      3'b000: out = in1 + in2;
      3'b001: out = in1 - in2;
      3'b010: out = in1 & in2;
      3'b011: out = in1 | in2;
      3'b100: out = in1 << in2;
      3'b101: out = in1 >> in2;
    endcase
  end

endmodule
