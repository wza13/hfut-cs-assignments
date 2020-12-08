module comparator8(
  input wire [7:0] a, b,
  output reg greater,
  output reg equal
);

  always@* begin
    if (a > b)
      begin
      greater = 1;
      equal = 0;
      end
    else if (a < b)
      begin
      greater = 0;
      equal = 0;
      end
    else
      equal = 1;
  end

endmodule
