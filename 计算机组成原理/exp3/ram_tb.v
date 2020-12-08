module ram_tb;
  
  reg clk, WE;
  reg[8:0] ad;
  reg[15:0] in;
  wire[15:0] out;
  
  always#5 clk = ~clk;
  
  initial begin
    clk = 0;
    
    WE = 0;
    ad = 0;
    in = 16'h000f;
    
    #10
    ad = 1;
    in = 16'h00f0;
    
    #10
    WE = 1;
    ad = 0;
    
    #10
    ad = 1;
    
    #10
    $stop;
  end
  
  ram uut(
    .clk(clk), .WE(WE),
    .ad(ad), .in(in),
    .out(out)
  );
  
endmodule
