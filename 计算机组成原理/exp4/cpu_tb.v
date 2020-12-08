module cpu_tb;
  
  reg clk, reset;
  
  always#5 clk = ~clk;
  
  initial begin
    clk = 1;
    reset = 1;
    
    #10 reset = 0;
    
    #100 $stop;
  end
  
  cpu uut(
    .clk(clk), .reset(reset)
  );
  
endmodule
