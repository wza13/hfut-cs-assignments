module mux41 (
  input wire [3:0] in1, in2, in3, in4,
  input wire [1:0] select,
  output reg [3:0] out
);

  always@* begin
    case (select)
      2'b00: out = in1;
      2'b01: out = in2;
      2'b10: out = in3;
      2'b11: out = in4;
      default: out = 4'bx;
    endcase
  end
  
endmodule
