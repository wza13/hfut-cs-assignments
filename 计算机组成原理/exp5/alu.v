module alu(
  input wire[3:0] op,
  input wire[15:0] inAcc, inDataM,
  output reg[15:0] Z,
  output reg conditional
);

  always@* begin
    case (op)
      // 0.CLA
      4'b0000: Z = 0;
      // 1.COM
      4'b0001: Z = ~inAcc;
      // 2.SHR
      4'b0010: begin
        Z[15] <= inAcc[15] == 1 ? 1 : 0;
        Z[14:0] <= inAcc[15:1]; end
      // 3.CSL
      4'b0011: Z = {inAcc[14:0], inAcc[15]};
      // 4.STOP 4'b0100
      // 5.ADD
      4'b0101: Z = inAcc + inDataM;
      // 6.STA
      4'b0110: Z = inAcc;
      // 7.LDA
      4'b0111: Z = inDataM;
      // 8.JMP 4'b1000
      // 9.BAN
      4'b1001: conditional = inAcc[15] == 1 ? 1 : 0;
      default: conditional = 0;
    endcase
  end

endmodule
