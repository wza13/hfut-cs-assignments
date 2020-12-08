module fulladde4_tb;
  
  reg [3:0] a, b;
  reg cIn;
  wire [3:0] s;
  wire cOut;
  
  initial begin
    a = 4'b0001;
    b = 4'b1110;
    cIn = 1'b0;
    #10 cIn = 1'b1;
    #10 $stop;
  end
  
  fulladder4 uut(
    .a(a), .b(b), .cIn(cIn),
    .s(s), .cOut(cOut)
  );
  
endmodule
