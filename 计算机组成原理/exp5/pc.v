module pc(
  input wire clk, reset, stop,
             conditional, unConditional,
  input wire[11:0] inData,
  output reg[11:0] insAd
);

  reg stopped;
  
  always@* begin
    if (stop == 1) 
      stopped = 1;
  end
  
  always@(posedge clk) begin
    if (stopped == 1) ;
    else if (reset == 1)
      insAd = 0;
    else insAd = insAd + 1;
  end
  
  always@(negedge clk) begin
    if (conditional == 1)
      insAd = insAd + inData - 1;
    if (unConditional == 1)
      insAd = inData - 1;
  end
  
  initial begin
    insAd = 0;
    stopped = 0;
  end

endmodule
