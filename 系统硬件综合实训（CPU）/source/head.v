// ALUopcode
`define ALUAdd 3'b000
`define ALUSub 3'b001
`define ALUAnd 3'b010
`define ALUOr 3'b011
`define ALUXor 3'b100
`define ALUNor 3'b101
`define ALUSlt 3'b110

`define ALUMultiple 1'b0
`define ALUDivide 1'b1

// ExtSel
`define ZesroExd 1'b0
`define SignExd 1'b1

// PCSrc
`define NextIns 2'b00
`define RelJmp 2'b01 //relative jump
`define AbsJmp 2'b10 //absolute jump
`define RsJmp 2'b11 // Jump to Rs, by JR instrustion

// for instruction
// op code
`define opRFormat 6'b000000
`define opADD 6'b000000
`define opSUB 6'b000000
`define opAND 6'b000000
`define opOR 6'b000000
`define opSLL 6'b000000
`define opSLT 6'b000000
`define opJR 6'b000000
`define opXOR 6'b000000
`define opNOR 6'b000000

`define opSLTI 6'b001010
`define opADDI 6'b001000
`define opORI 6'b001101
`define opSW 6'b101011
`define opLW 6'b100011
`define opANDI 6'b001100
`define opXORI 6'b001110

`define opBEQ 6'b000100
`define opBNE 6'b000101
`define opBGTZ 6'b000111
`define opJ 6'b000010
`define opJAL 6'b011000
`define opMULIU 6'b000000
`define opDIVU 6'b000000
`define opHALT 6'b111111

// func code
`define funcADD 6'b100000
`define funcSUB 6'b100011
`define funcAND 6'b100100
`define funcOR 6'b100101
`define funcSLL 6'b000000
`define funcSLT 6'b101010
`define funcXOR 6'b100110
`define funcNOR 6'b100111
`define funcJR 6'b000001
`define funcMULU 6'b001011
`define funcDIVU 6'b011011
// ALU state
`define sIdle 0
`define sPremitiveIns 2'b01
`define sInverse 2'b10 // for Inverse
`define sMAdd 2'b11 // for Minus Add


`define sMul32 3'b001
`define sMul16 3'b010 
`define sMul8 3'b011
`define sMul4 3'b100
`define sMul2 3'b101
`define sMulAnswer 3'b110

`define sFPMatchExp 2'b01
`define sFPSumUp 2'b10
`define sFPNorm 2'b11

`define sWorking 1'b1

// for RAMStation
`define opLoad 1'b1
`define opStore 1'b0

// Labels code
// dd-dd
// category - id
`define ALU0 4'b00_00 
`define ALU1 4'b00_01 
`define ALU2 4'b00_10 
`define MUL0 4'b01_00 
`define MUL1 4'b01_01 
`define MUL2 4'b01_10 
`define DIV0 4'b10_01 
`define DIV1 4'b10_10 
`define DIV2 4'b10_11 
`define QUE0 4'b11_00 
`define QUE1 4'b11_01
`define QUE2 4'b11_10

// for ALUSel
`define addsubALU 2'b00 
`define multipleALU 2'b01 
`define divideALU 2'b11

// RegDst
`define FromRd 1'b0
`define FromRt 1'b1
// vkSrc
`define FromRtData 1'b0
`define FromImmd 1'b1