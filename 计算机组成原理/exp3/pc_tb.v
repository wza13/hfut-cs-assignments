module pc_tb;
  
  reg clk, reset;
  wire[7:0] pc;
  
  always#5 clk = ~clk;
  
  initial begin
    clk = 0;
    reset = 1;
    
    #10
    reset = 0;
    
    #80
    reset = 1;
    
    #20
    reset = 0;
    
    #40
    $stop;
  end
  
  pc uut(
    .clk(clk),
    .reset(reset),
    .pc(pc)
  );
  
endmodule
