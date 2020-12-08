module alu_tb;
  
  reg [15:0] in1, in2;
  reg [2:0] op;
  wire [15:0] out;
  
  initial begin
    in1 = 16'b0000111101011010;
    in2 = 16'b0000000001010101;
    
    op = 3'b000;
    
    #10
    op = 3'b001;
    
    #10
    op = 3'b010;
    
    #10
    op = 3'b011;
    
    #10
    in2 = 4'h08;
    op = 3'b100;
    
    #10
    op = 3'b101;
    
    #10 $stop;
  end
  
  alu uut(
    .in1(in1), .in2(in2), .op(op),
    .out(out)
  );
  
endmodule
