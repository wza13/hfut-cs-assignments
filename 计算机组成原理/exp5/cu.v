module cu(
  input wire[3:0] opIn,
  output reg[3:0] opOut,
  output reg unConditional, stop, 
             wrAcc, wrDataM
);

  always@* begin
    case (opIn)
      // 0.CLA
      4'b0000: {wrAcc, wrDataM} = 2'b10;
      // 1.COM
      4'b0001: {wrAcc, wrDataM} = 2'b10;
      // 2.SHR
      4'b0010: {wrAcc, wrDataM} = 2'b10;
      // 3.CSL
      4'b0011: {wrAcc, wrDataM} = 2'b10;
      // 4.STOP 4'b0100
      // 5.ADD
      4'b0101: {wrAcc, wrDataM} = 2'b10;
      // 6.STA
      4'b0110: {wrAcc, wrDataM} = 2'b01;
      // 7.LDA
      4'b0111: {wrAcc, wrDataM} = 2'b10;
      // 8.JMP 4'b1000
      // 9.BAN 4'b1001
      default: {wrAcc, wrDataM} = 4'b0000;
    endcase
    
    opOut = opIn;
    if (opIn == 4'b0100) stop = 1;
    else stop = 0;
    if (opIn == 4'b1000) unConditional = 1;
    else unConditional = 0;
  end

endmodule
