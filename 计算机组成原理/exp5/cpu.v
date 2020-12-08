module cpu(
  input wire clk, reset
);

  wire unConditional, stop,
       wrAcc, wrDataM;
  wire[3:0] cuOut;
  
  wire[11:0] insAd;
  wire[15:0] ins;
  wire[15:0] accToAlu;
  wire[15:0] Z; wire conditional;
  wire[15:0] dataMToAlu;
  
  cu cu(
    .opIn(ins[15:12]),
    .opOut(cuOut),
    .unConditional(unConditional),
    .stop(stop),
    .wrAcc(wrAcc), .wrDataM(wrDataM)
  );

  pc pc(
    .clk(clk), .reset(reset),
    .inData(ins[11:0]),
    .insAd(insAd),
    .unConditional(unConditional), .stop(stop),
    .conditional(conditional)
  );
  
  insMemory insMemory(
    .insAd(insAd), .ins(ins)
  );
  
  acc acc(
    .clk(clk), .wr(wrAcc),
    .inData(Z), .acc(accToAlu)
  );

  alu alu(
    .op(cuOut),
    .inAcc(accToAlu), .inDataM(dataMToAlu),
    .Z(Z),
    .conditional(conditional)
  );

  dataMemory dataMemory(
    .clk(clk), .wr(wrDataM),
    .inData(Z), .address(ins[11:0]),
    .datum(dataMToAlu)
  );

endmodule
