module fulladder4(
  input wire [3:0] a, b,
  input wire cIn,
  output reg [3:0] s,
  output reg cOut
);

  always@* begin
    { cOut, s } = a + b + cIn;
  end

endmodule
