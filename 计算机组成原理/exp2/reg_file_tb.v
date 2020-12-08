module reg_file_tb;
  
  reg WE, clk;
  reg [2:0] RA, RB, RW;
  reg [15:0] busW;
  wire [15:0] busA, busB;
  
  always#5 clk = ~clk;
  
  initial begin
    clk =0;
    RA = 3'b000;
    RB = 3'b001;
    
    RW = 3'b000;
    busW = 16'hff00;
    WE = 1;
    
    #10
    RW = 3'b001;
    busW = 16'h00ff;
    WE = 0;
    
    #10
    WE = 1;
    
    #10
    $stop;
    
  end
  
  
  reg_file uut(
    .WE(WE), .clk(clk),
    .RA(RA), .RB(RB), .RW(RW),
    .busW(busW),
    .busA(busA), .busB(busB)
);
  
endmodule
