`include "head.v"
`timescale 1ns/1ps
module top(
    input clk_in,
    input nRST,
    output wire [15:0] pc_right16
);
    wire clk;
    frequencyChanger clkGenerator(
        .clk_in(clk_in),
        .clk_out(clk)
    );
    wire [5:0] op;
    //TODO:: not finished 
    wire pcWrite = op == `opHALT ? 0 : 1;
    wire [1:0]sel = 0;
    //TODO END
    wire labelEN;
    wire [31:0] pc;
    assign pc_right16 = pc[15:0];
    
    wire [3:0] alu_labelOut;
    
    wire [3:0]memory_labelOut;
    
    wire [31:0] newpc;
    wire [31:0] ins;
    wire isFullOut;
    wire [5:0] func;
    wire [4:0] sftamt;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [15:0] immd16;
    wire [25:0] immd26;
    wire [31:0] rsData;
    wire [31:0] rtData;
    wire [3:0] rsLabel;
    wire [3:0] rtLabel;
    wire BCEN;
    wire [31:0] BCdata;
    wire [3:0] BClabel;
    wire [3:0] alu_label;
    wire mul_EXEable;
    wire [2:0]mul_op;
    wire [31:0] mul_A;
    wire [31:0] mul_B;
    wire mul_isReady;
    wire [3:0] mul_label;
    wire mul_isfull;
    wire [31:0] mul_result;
    wire [3:0] mul_labelOut;
    wire RegDst;
    wire [1:0]ResStationDst;
    wire vkSrc;
    wire [3:0]queue_writeable_label;
    PC pc_instance(
        .clk(clk),
        .nRST(nRST),
        .newpc(newpc),
        .pcWrite(labelEN & pcWrite),
        .pc(pc)
    );
    PCHelper pc_helper(
        .pc(pc),
        .immd16(immd16),
        .immd26(immd26),
        .sel(sel),
        .rs(0), // rs here is data
        .newpc(newpc)
    );
    ROM rom(
        .nrd(1'b0),
        .dataOut(ins),
        .addr(pc)
    );
    Decoder decoder(
        .ins(ins),
        .op(op),
        .func(func),
        .sftamt(sftamt),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .immd16(immd16),
        .immd26(immd26)
    );

    wire [3:0] cur_label;
    reg [4:0] writeDst;

    RegFile regfile(
        .clk(clk),
        .nRST(nRST),
        .ReadAddr1(rs), // TODO:
        .ReadAddr2(rt),
        .RegWr(labelEN),
        .WriteAddr(writeDst),
        .WriteLabel(cur_label), //TODO
        .op(op),
        .DataOut1(rsData),
        .DataOut2(rtData),
        .LabelOut1(rsLabel),
        .LabelOut2(rtLabel),
        .BCEN(BCEN),
        .BClabel(BClabel),
        .BCdata(BCdata)
    );


    // 假�?�已经搞定，译码完成，以下就�?我想要的
    wire [3:0] ResStationEN;// 3,2,1,0 : lw,div,mul,alu
    wire [1:0] opcode;// updated by control_unit
    // wire [1:0] ResStationDst; // updated by control_unit
    wire [3:0] Qj;
    reg [3:0] Qk;
    wire [31:0] Vj;
    reg [31:0] Vk;
    // wire [31:0] Qi;
    // wire [31:0] A;
    //--------------------------
    assign Qj = rsLabel;
    // assign Qk = rtLabel;
    assign Vj = rsData;
    //TODO : simplify this
    always@(*) begin
        if (vkSrc == `FromRtData) begin
            Vk = rtData;
            Qk = rtLabel;
            writeDst = rd;
        end
        else begin
            if (op == `opORI || op == `opANDI || op == `opXORI) begin
                Vk = {16'b0, immd16};
                Qk = 4'b0000;
                writeDst = rt; 
            end
            else begin
                Vk = {{16{immd16[15]}},immd16};
                Qk = 4'b0000;
                writeDst = rt;
            end 
        end
    end

    wire [3:0] alu_writeable_label;
    wire [3:0] mul_writeable_label;

    mux4to1_4 my_mux4to1_4(
        .sel((op == `opLW || op == `opSW) ? 2'b11 : ResStationDst),
        .dataIn0(alu_writeable_label),
        .dataIn1(mul_writeable_label),
        .dataIn2(4'b0),
        .dataIn3(queue_writeable_label),
        .dataOut(cur_label)
    );

    //-------------------------------

    wire alu_EXEable;
    wire [1:0]alu_op;
    wire [31:0] alu_A;
    wire [31:0] alu_B;
    wire alu_isReady;
    wire alu_isfull;
    wire [31:0] alu_result;
    

    ReservationStation alu_reservationstation(
        .clk(clk),
        .nRST(nRST),
        .EXEable(alu_EXEable),
        .WEN(ResStationEN[0]),
        .ResStationDst(2'b01),
        .opCode(opcode),
        .dataIn1(Vj),
        .label1(Qj),
        .dataIn2(Vk),
        .label2(Qk),
        .BCEN(BCEN),
        .BClabel(BClabel),
        .BCdata(BCdata),
        .opOut(lu_op),
        .dataOut1(alu_A),
        .dataOut2(alu_B),
        .isFull(alu_isfull),
        .OutEn(alu_isReady),
        .ready_labelOut(alu_label),
        .writeable_labelOut(alu_writeable_label)
    );

    wire [1:0]pmfStateOut;
    wire pmfALUAvailable;
    wire pmfALUEN;
    wire pmfRequire;
    pmfState pmf_state(
        .clk(clk),
        .nRST(nRST),
        .stateOut(pmfStateOut),
        .WEN(alu_isReady),
        .requireAC(requireAC_s[0]),
        .available(alu_EXEable),
        .pmfALUEN(pmfALUEN),
        .op(alu_op),
        .require(require_s[0])
    );

    pmfALU pmf_alu(
        .clk(clk),
        .nRST(nRST),
        .op(alu_op),
        .EN(pmfALUEN),
        .dataIn1(alu_A),
        .dataIn2(alu_B),
        .labelIn(alu_label),
        .state(pmfStateOut),
        .result(alu_result),
        .labelOut(alu_labelOut)
    );






    ReservationStation mul_reservationstation(
        .clk(clk),
        .nRST(nRST),
        .EXEable(mul_EXEable),
        .WEN(ResStationEN[1]),
        .ResStationDst(2'b10),
        .opCode(opcode),
        .dataIn1(Vj),
        .label1(Qj),
        .dataIn2(Vk),
        .label2(Qk),
        .BCEN(BCEN),
        .BClabel(BClabel),
        .BCdata(BCdata),
        .opOut(mul_op),
        .dataOut1(mul_A),
        .dataOut2(mul_B),
        .isFull(mul_isfull),
        .OutEn(mul_isReady),
        .ready_labelOut(mul_label),
        .writeable_labelOut(mul_writeable_label)
    );

    wire [2:0]mfStateOut;
    wire mfALUAvailable;
    wire mfALUEN;
    wire mfRequire;
    mfState mf_state(
        .clk(clk),
        .nRST(nRST),
        .stateOut(mfStateOut),
        .WEN(mul_isReady),
        .requireAC(requireAC_s[1]),
        .available(mul_EXEable),
        .mfALUEN(mfALUEN),
        .op(mul_op),
        .require(require_s[1])
    );

    mfALU mf_alu(
        .clk(clk),
        .nRST(nRST),
        .EN(mfALUEN),
        .dataIn1(mul_A),
        .dataIn2(mul_B),
        .labelIn(mul_label),
        .state(mfStateOut),
        .result(mul_result),
        .labelOut(mul_labelOut)
    );



    // wire div_EXEable;
    // wire div_op;
    // wire [31:0] div_A;
    // wire [31:0] div_B;
    // wire div_isReady;
     wire [3:0] div_label;
    // wire div_isfull;
    // wire [31:0] div_result;

    // ReservationStation div_reservationstation(
    //     .clk(clk),
    //     .nRST(nRST),
    //     .EXEable(div_EXEable),// TODO:
    //     .WEN(ResStationEN[2]),
    //     .ResStationDst(ResStationDst),
    //     .opCode(op),
    //     .dataIn1(Vj),
    //     .label1(Qj),
    //     .dataIn2(Vk),
    //     .label2(Qk),
    //     .BCEN,
    //     .BClabel,
    //     .BCdata,
    //     .opOut(div_op),
    //     .dataOut1(div_A),
    //     .DataOut2(div_B),
    //     .isFull(div_isfull),
    //     .OutEn(div_isReady),
    //     .labelOut(div_label), 
    // );

    // wire [1:0]dfStateOut;
    // wire dfALUAvailable;
    // wire dfALUEN;
    // wire dfRequire;
    // dfState df_state(
    //     .clk,
    //     .nRST,
    //     .stateOut(dfStateOut),
    //     .WEN(div_isReady),
    //     .requireAC(),// TODO:
    //     .available(div_EXEable),
    //     .dfALUEN,
    //     .op(div_op),
    //     .require()// TODO:
    // );

    // dfALU df_alu(
    //     .clk,
    //     .nRST,
    //     .EN(dfALUEN),
    //     .dataIn1(div_A),
    //     .dataIn2(div_B),
    //     .state(dfStateOut),
    //     .result(div_result)
    // );


    // 3,2,1,0 ls, div ,mul ,alu
    wire [3:0] require_s;
    wire [3:0] requireAC_s;

    // test memory
    assign require_s[2] = 0;

    wire memory_available;
    wire QueueOp;

    wire RTOpOut;
    wire [31:0]RTDataOut;
    wire [3:0]RTLabelOut;
    wire queue_isfull;
    wire [2:0]queue_require;
    wire isLastState; //TODO

    Queue opprendRT_queue(
        .clk(clk),
        .nRST(nRST),
        .requireAC(memory_available),
        .WEN(ResStationEN[3]),
        .isFull(queue_isfull),
        .require(queue_require[0]),
        .dataIn(rtData),
        .labelIn(rtLabel),
        .opIN(QueueOp),
        .BCEN(BCEN),
        .BClabel(BClabel),
        .BCdata(BCdata),
        .opOut(RTOpOut),
        .dataOut(RTDataOut),
        .labelOut(RTLabelOut),
        .isLastState(isLastState),
        .queue_writeable_label(queue_writeable_label)
    );
    wire ImmdOpOut;
    wire [31:0]ImmdDataOut;
    wire [3:0]ImmdLabelOut;
    
    wire immdQueueIsFull;
    wire immdQueueWriteableLabel;
    Queue opprendImmd_queue(
        .clk(clk),
        .nRST(nRST),
        .requireAC(memory_available),
        .WEN(ResStationEN[3]),
        .isFull(immdQueueIsFull),
        .require(queue_require[1]),
        .dataIn({{16{immd16[15]}},immd16}), // TODO: not generated
        .labelIn(4'b0),
        .opIN(QueueOp),
        .BCEN(BCEN),
        .BClabel(BClabel),
        .BCdata(BCdata),
        .opOut(ImmdOpOut),
        .dataOut(ImmdDataOut),
        .labelOut(ImmdLabelOut),
        .isLastState(isLastState),
        .queue_writeable_label(immdQueueWriteableLabel)
    );
    wire RSOpOut;
    wire [31:0]RSDataOut;
    wire [3:0]RSLabelOut;
    wire rsQueueIsFull;
    wire rsQueueWriteableLabel;
    Queue opprendRS_queue(
        .clk(clk),
        .nRST(nRST),
        .requireAC(memory_available),
        .WEN(ResStationEN[3]),
        .isFull(rsQueueIsFull),
        .require(queue_require[2]),
        .dataIn(rsData),
        .labelIn(rsLabel),
        .opIN(QueueOp),
        .BCEN(BCEN),
        .BClabel(BClabel),
        .BCdata(BCdata),
        .opOut(RSOpOut),
        .dataOut(RSDataOut),
        .labelOut(RSLabelOut),
        .isLastState(isLastState),
        .queue_writeable_label(rsQueueWriteableLabel)
    );
    wire [31:0]memory_loadData;
    wire memory_require_CDB;
    
    Memory yf_memory(
        .clk(clk),
        .WEN(&queue_require),
        .dataIn1(RSDataOut),
        .dataIn2(ImmdDataOut),
        .op(RTOpOut),
        .writeData(RTDataOut),
        .loadData(memory_loadData),
        .available(memory_available),
        .require(require_s[3]),
        .requireAC(requireAC_s[3]),
        .labelIn(RTLabelOut),
        .labelOut(memory_labelOut),
        .isLastState(isLastState)
    );




    CDBHelper cdb_helper(
        .requires(require_s),
        .accepts(requireAC_s)
    );

    CDB cdb(
        .data0(alu_result),
        .label0(alu_labelOut),
        .data1(mul_result),
        .label1(mul_labelOut),
        // TODO: no link dfalu
        .data2(0),
        .label2(4'b0),
        .data3(memory_loadData),
        .label3(memory_labelOut),

        .sel(require_s),
        .dataOut(BCdata),
        .labelOut(BClabel),
        .EN(BCEN)
    );

    CU contril_unit(
        .op(op),
        .func(func),
        .ALUop(opcode),
        .ALUSel(ResStationDst),
        .ResStationEN(ResStationEN),
        .isFull({queue_isfull, mul_isfull, alu_isfull}),
        .isFullOut(isFullOut),
        .vkSrc(vkSrc),
        .RegDst(RegDst),
        .QueueOp(QueueOp)
    );

    assign labelEN = ~isFullOut;

endmodule