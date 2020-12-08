module mux41_tb;
  
  reg [3:0] in1, in2, in3, in4;
  reg [1:0] select;
  wire [3:0] out;
  
  initial begin
    in1 = 4'b0001;
    in2 = 4'b0011;
    in3 = 4'b0111;
    in4 = 4'b1111;
    
    select = 2'b00;
    #10 select = 2'b01;
    #10 select = 2'b10;
    #10 select = 2'b11;
    
    #10 $stop;
  end
  
  mux41 uut(
    .in1(in1), .in2(in2), .in3(in3), .in4(in4),
    .select(select),
    .out(out)
  );

endmodule
