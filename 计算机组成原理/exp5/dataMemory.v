module dataMemory(
  input wire clk, wr,
  input wire[15:0] inData,
  input wire[11:0] address,
  output reg[15:0] datum
);

  reg[15:0] data[4095:0];

  always@* begin
    datum = data[address];
  end

  always@(negedge clk) begin
    if (wr == 1)
      data[address] = inData;
  end
  
  initial begin
    data[0] = 1;
    data[1] = 2; 
  end
  
endmodule
