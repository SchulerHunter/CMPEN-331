`timescale 1ns / 1ps

module Top(input clk);
// Now timely, but still silent

// Stall Signals
wire HazardDetected;
wire NoHazardDetected;
assign HazardDetected = 1'b0;
assign NoHazardDetected = ~HazardDetected;

////////
////////
// YOUR TASK: Change the hazard management logic to: 
// 1) make the appropriate pipeline stages stall
// 2) insert NOPs as needed
// for the following two dangling stall-related signals
// the signals correctly indicate when the IMEM or DMEM are "not ready"
// but these signals are currently ignored
wire IMEM_READY; // Indicates that this fetch was successful. Repeat if not ready
wire DMEM_READY; // Indicates that this DMEM access was successful. Repeat if not ready
////////
////////


// Fetch Stage Signals
wire [31:0] IBits;      // bits of the instruction from IMEM
wire [31:0] IBits_temp;
wire [31:0] NextInst; // IBits or NOP
wire [31:0] NOPbits; // SLL $0, $0, 0 is the cannonical NOP
assign NOPbits = 32'h0000_0000;
wire [31:0] PCp4;       // PC + 4
wire [31:0] PC;         // PC
wire [31:0] NextPC;     // Next PC

// Decode Stage Signals

// INSTRUCTION RELATED SIGNALS
wire [31:0] ID_IBits;      // bits of the instruction in Decode stage
wire [5:0] Opcode;
wire [4:0] RS;
wire [4:0] RT;
wire [4:0] RD;
wire [4:0] ID_SHAMT;
wire [5:0] FUNCT;
wire [15:0] IMM;
wire [25:0] JBITS;

assign Opcode = ID_IBits[31:26];
assign RS = ID_IBits[25:21];
assign RT = ID_IBits[20:16];
assign RD = ID_IBits[15:11];
assign ID_SHAMT = ID_IBits[10:6];
assign FUNCT = ID_IBits[5:0];
assign IMM = ID_IBits[15:0];
assign JBITS = ID_IBits[26:0];

// Data Dependent Decode Signals
wire EQ;                // Forwarded RS==Forwarded RT
wire [31:0] RP1Out;     //REG[RS]
wire [31:0] RP2Out;     //REG[RT]
wire [31:0] RP1Forwarded; // REG[RS] Forwarded
wire [31:0] RP2Forwarded; // REG[RT] Forwarded
wire [31:0] NRP1Forwarded; // REG[RS] Forwarded or NOP
wire [31:0] NRP2Forwarded; // REG[RT] Forwarded or IMM or NOP
wire [31:0] NRTVAL; // REG[RT] Forwarded or NOP
                       // S or Z extended IMM
wire [31:0] ExtendedImmediate;
                        // Branch Target
wire [31:0] BranchTarget;   
wire [31:0] ID_PCp4;    // PC + 4 in Decode stage

wire [31:0] JumpTarget;     // Jump target
assign JumpTarget = {ID_PCp4[31:28],JBITS,2'b00};
wire [31:0] JorRTarget;       // Either jump or register target
wire [31:0] BorPCp4Target;     // Either Branch Target or PC+4

// CONTROL SIGNALS
wire ID_memToReg_ctrl;     // read from memory?
wire ID_memWrite_ctrl;     // write to memory?
wire ID_regWrite_ctrl;     // write to register file?
wire ID_LBU_ctrl;          // return unsigned byte from DMEM
wire ID_ByteSize_ctrl;     // byte op if 1, word op if 0
wire BranchSense_ctrl;  // BEQ if 0, BNE if 1
wire [3:0] ID_ALUOpSelect_ctrl;   // Selects ALU Op
wire SZExtension_ctrl;  // SignExtend if 1, else zero extend
wire Jump_ctrl;              // nextPC uses jumptarget
wire RegToPC_ctrl;           // nextPC uses regValue
wire Branch_ctrl;            // currentInst is branch
wire ID_Link_ctrl;             // JAL / JALR
wire ID_RegDest_ctrl;          // RD else RT
wire ID_SYSCALL_ctrl;          // Do Emulated Syscall
wire ID_UseRT_ctrl;           // Use RT else IMM

wire [31:0] ID_OperandB; // RT or IMM

wire NEX_memToReg_ctrl;     // read from memory?
assign NEX_memToReg_ctrl = HazardDetected?1'b0:ID_memToReg_ctrl;
wire NEX_memWrite_ctrl;     // write to memory?
assign NEX_memWrite_ctrl = HazardDetected?1'b0:ID_memWrite_ctrl;
wire NEX_regWrite_ctrl;     // write to register file?
assign NEX_regWrite_ctrl = HazardDetected?1'b0:ID_regWrite_ctrl;
wire NEX_LBU_ctrl;          // return unsigned byte from DMEM
assign NEX_LBU_ctrl = HazardDetected?1'b0:ID_LBU_ctrl;
wire NEX_ByteSize_ctrl;     // byte op if 1, word op if 0
assign NEX_ByteSize_ctrl = HazardDetected?1'b0:ID_ByteSize_ctrl;
wire [3:0] NEX_ALUOpSelect_ctrl;   // Selects ALU Op
assign NEX_ALUOpSelect_ctrl = HazardDetected?4'b1000:ID_ALUOpSelect_ctrl;
wire NEX_Link_ctrl;             // JAL / JALR
assign NEX_Link_ctrl = HazardDetected?1'b0:ID_Link_ctrl;
wire NEX_RegDest_ctrl;          // RD else RT
assign NEX_RegDest_ctrl = HazardDetected?1'b1:ID_RegDest_ctrl;
wire NEX_SYSCALL_ctrl;          // Do Emulated Syscall
assign NEX_SYSCALL_ctrl = HazardDetected?1'b0:ID_SYSCALL_ctrl;
wire NEX_UseRT_ctrl;           // Use RT else IMM
assign NEX_UseRT_ctrl = HazardDetected?1'b1:ID_UseRT_ctrl;

wire [4:0] ID_RegWriteDest; // RD, RT, 31
wire [4:0] NEX_RegWriteDest;
assign NEX_RegWriteDest = HazardDetected?5'b0000:ID_RegWriteDest;

wire [4:0] NEX_RS;
wire [4:0] NEX_RT;
wire [4:0] NEX_SHAMT;
assign NEX_RS = HazardDetected?5'b00000:RS; // RS = 0 if hazard
assign NEX_RT = HazardDetected?5'b00000:((ID_UseRT_ctrl|ID_memWrite_ctrl)?RT:5'b00000); // RT = 0 if hazard or used IMM
assign NEX_SHAMT = HazardDetected?5'b00000:ID_SHAMT;

wire EX_memToReg_ctrl;     // read from memory?
wire EX_memWrite_ctrl;     // write to memory?
wire EX_regWrite_ctrl;     // write to register file?
wire EX_LBU_ctrl;          // return unsigned byte from DMEM
wire EX_ByteSize_ctrl;     // byte op if 1, word op if 0
wire [3:0] EX_ALUOpSelect_ctrl;   // Selects ALU Op
wire EX_Link_ctrl;             // JAL / JALR
wire EX_SYSCALL_ctrl;          // Do Emulated Syscall
wire EX_UseRT_ctrl;           // Use RT else IMM

wire [4:0] EX_RegWriteDest; // RD, RT, 31

wire [4:0] EX_SHAMT;
wire [31:0] EX_A; // A operand pre-forwarding in EX
wire [31:0] EX_B; // B operand pre-forwarding in EX
wire [4:0] EX_RS;
wire [4:0] EX_RT;
wire [31:0] EX_PCp4;
wire [31:0] EX_RTVAL;
wire [31:0] EX_RTVALFwd;

// DATAPATH RELATED SIGNALS
wire [31:0] ALUPortA;   // REG[RS] or Forwarded
wire [31:0] ALUPortB;   // REG[RT] or ExtendedImmediate or Forwarded
wire [31:0] ALUOut;     // primary output of ALU
wire CarryOut_not_used; // Reserved for later use
wire Overflow_not_used; // Reserved for later use

wire [63:0] HILO;        // HILO
wire [63:0] NextHILO;   // Next HILO
assign NextHILO = 64'h00000000_00000000; // FIXME LATER - not used


wire [31:0] MEM_RTVAL;
wire [31:0] MEM_StoreValue;
wire [4:0] MEM_RT;
wire [4:0] MEM_RegWriteDest; // RD, RT, 31
wire MEM_memToReg_ctrl;     // read from memory?
wire MEM_memWrite_ctrl;     // write to memory?
wire MEM_regWrite_ctrl;     // write to register file?
wire MEM_LBU_ctrl;          // return unsigned byte from DMEM
wire MEM_ByteSize_ctrl;     // byte op if 1, word op if 0
wire MEM_Link_ctrl;             // JAL / JALR
wire MEM_SYSCALL_ctrl;          // Do Emulated Syscall
wire [31:0] MEM_PCp4;
wire [31:0] MEM_ALUOut;

// Memory Related Signals
wire [31:0] MemOut;     // memory read value, if memToReg, else 0
wire [31:0] MemOut_temp;
wire [31:0] WB_ALUOut;
wire [31:0] WB_PCp4;
wire [31:0] WB_MemOut;
wire WB_memToReg_ctrl;     // read from memory?
wire WB_Link_ctrl;             // JAL / JALR
wire WB_regWrite_ctrl;     // write to register file?
wire WB_SYSCALL_ctrl;          // Do Emulated Syscall
wire [4:0] WB_RegWriteDest; // RD, RT, 31
wire [31:0] WriteBackData;  // Data to be written to register file

// Data dependent control
wire BranchTaken;         // Was a branch taken?
wire IFlush;

// Stall wires
wire fStall;
wire fStallInit;
wire dStall;
wire mStall;
// No writeback stalls in this pipeline

wire memAccess;
assign memAccess = MEM_memToReg_ctrl | MEM_memWrite_ctrl;

assign fStallInit = ~IMEM_READY;

// Assign stalls
// Write back never stalls
assign mStall = memAccess & ~DMEM_READY; // Same thing as mStallInit
// Execute stalls if memory stalls; eStall = mStall since there is no init
assign dStall = HazardDetected | mStall;
assign fStall = (IFlush)?NOPbits:fStallInit | dStall;

// FETCH STATE = PC
                        // The PC
PC32 thePC(.in(NextPC),.out(PC),.en(~fStall),.reset(1'b0),.clk(clk));

////
// FETCH
////

                        // The Instruction Memory
IMEM thisIMEM(.Address(PC),.InstBits(IBits),.Ready(IMEM_READY),.clk(clk));

                        // Generates PC + 4
IncFour thisPCADDER(.in(PC),.out(PCp4));

assign JorRTarget = RegToPC_ctrl?RP1Out:JumpTarget; // JR/JALR else J/JAL
assign BorPCp4Target = (BranchTaken)?BranchTarget:PCp4; // Branch and branched else PC+4
assign NextPC = Jump_ctrl? JorRTarget:BorPCp4Target; // Jump side else branch side

assign NextInst = (IFlush|fStallInit)?NOPbits:IBits;

// IF-ID Pipeline Register
IF_ID_PR thisIF_ID_PR(.clk(clk),.en(~dStall),.BeingFetched(NextInst),.WasFetched(ID_IBits),.PCp4(fStallInit?NOPbits:PCp4),.ID_PCp4(ID_PCp4));


////
// DECODE
////

                        // The 64-bit HILO Register          
HILO64 theHILO(.in(NextHILO),.out(HILO),.en(~dStall),.reset(1'b0),.clk(clk));

HazardDetection thisHazardDetector(.ID_RS(RS),.ID_RT(RT),.ID_UseRT(ID_UseRT_ctrl),.ID_memWrite(ID_memWrite_ctrl),
.EX_Dest(EX_RegWriteDest),.EX_regWrite(EX_regWrite_ctrl),.EX_memToReg(EX_memToReg_ctrl),.MEM_Dest(MEM_RegWriteDest),
.MEM_memToReg(MEM_memToReg_ctrl),.ID_isBranch(Branch_ctrl),.ID_isJR(RegToPC_ctrl),.HazardDetected(HazardDetected));

DecodeForwarding thisDecodeForwarding(
    .ID_UseRT(ID_UseRT_ctrl),
    .ID_memWrite(ID_memWrite_ctrl),  
    .ID_RS(RS),
    .ID_RT(RT),
    .WriteValue(WriteBackData),
    .WB_Dest(WB_RegWriteDest),
    .WB_regWrite(WB_regWrite_ctrl),
    .RSVAL(RP1Out),
    .RTVAL(RP2Out),
    .RSF(RP1Forwarded),
    .RTF(RP2Forwarded));

// The 32 general purpose registers
REGFILE thisREGFILE(.clk(clk),.WP1(WB_RegWriteDest),.RP1(RS),.RP2(RT),.WriteEnable(WB_regWrite_ctrl),.WriteData(WriteBackData),.RPOut1(RP1Out),.RPOut2(RP2Out));  
// Equality Comparator
EQComp thisEQComp(.RRS(RP1Forwarded),.RRT(RP2Forwarded),.EQ(EQ)); 
// The Sign/Zero Extender
SZExtender SEXT(.IMM16(IMM),.SZ(SZExtension_ctrl),.EXT32(ExtendedImmediate));
// Generates Branch Target
ScaledAdder thisBRANCHADDER(.Unscaled(ID_PCp4),.Scaled(ExtendedImmediate),.Out(BranchTarget));
// Generates control signals
CONTROL thisCONTROL(.Opcode(Opcode),.Function(FUNCT),.memToReg_ctrl(ID_memToReg_ctrl),.memWrite_ctrl(ID_memWrite_ctrl),.regWrite_ctrl(ID_regWrite_ctrl),.LBU_ctrl(ID_LBU_ctrl),.ByteSize_ctrl(ID_ByteSize_ctrl),.BranchSense_ctrl(BranchSense_ctrl),.ALUOpSelect_ctrl(ID_ALUOpSelect_ctrl),.SZExtension_ctrl(SZExtension_ctrl),.Jump_ctrl(Jump_ctrl),.RegToPC_ctrl(RegToPC_ctrl),.Branch_ctrl(Branch_ctrl),.Link_ctrl(ID_Link_ctrl),.RegDest_ctrl(ID_RegDest_ctrl),.SYSCALL_ctrl(ID_SYSCALL_ctrl),.UseRT_ctrl(ID_UseRT_ctrl));

// Data-independent muxes
assign NRP1Forwarded = HazardDetected?32'h0000_0000:RP1Forwarded;
assign NRP2Forwarded = HazardDetected?32'h0000_0000:ID_OperandB;
assign NRTVAL = HazardDetected?32'h0000_0000:RP2Forwarded;
assign ID_RegWriteDest = ID_Link_ctrl?5'b11111:ID_RegDest_ctrl?RD:RT;
assign ID_OperandB = ID_UseRT_ctrl?RP2Forwarded:ExtendedImmediate;

// Data-dependent control muxes
assign BranchTaken = Branch_ctrl & (EQ ^ BranchSense_ctrl);
assign IFlush = BranchTaken | Jump_ctrl;

// ID-EX Pipeline Register
// mStall = eStall
// dStallInit = Hazard Detected
ID_EX_PR thisID_EX_PR(.clk(clk),.en(~mStall),
.memToReg_in(HazardDetected?NOPbits:NEX_memToReg_ctrl),.memToReg_out(EX_memToReg_ctrl),
.memWrite_in(HazardDetected?NOPbits:NEX_memWrite_ctrl),.memWrite_out(EX_memWrite_ctrl),
.regWrite_in(HazardDetected?NOPbits:NEX_regWrite_ctrl),.regWrite_out(EX_regWrite_ctrl),
.LBU_in(HazardDetected?NOPbits:NEX_LBU_ctrl),.LBU_out(EX_LBU_ctrl),
.ByteSize_in(HazardDetected?NOPbits:NEX_ByteSize_ctrl),.ByteSize_out(EX_ByteSize_ctrl),
.ALUOp_in(HazardDetected?NOPbits:NEX_ALUOpSelect_ctrl),.ALUOp_out(EX_ALUOpSelect_ctrl),
.Link_in(HazardDetected?NOPbits:NEX_Link_ctrl),.Link_out(EX_Link_ctrl),
.SYSCALL_in(HazardDetected?NOPbits:NEX_SYSCALL_ctrl),.SYSCALL_out(EX_SYSCALL_ctrl),
.UseRT_in(HazardDetected?NOPbits:NEX_UseRT_ctrl),.UseRT_out(EX_UseRT_ctrl),
.DestReg_in(HazardDetected?NOPbits:NEX_RegWriteDest),.DestReg_out(EX_RegWriteDest),
    .A_in(NRP1Forwarded),
    .B_in(NRP2Forwarded),
    .A_out(EX_A),
    .B_out(EX_B),
    .A_ID_in(HazardDetected?NOPbits:NEX_RS),
    .B_ID_in(HazardDetected?NOPbits:NEX_RT),
    .A_ID_out(EX_RS),
    .B_ID_out(EX_RT),
    .SHAMT_in(HazardDetected?NOPbits:NEX_SHAMT),
    .SHAMT_out(EX_SHAMT),
    .PCp4_in(HazardDetected?NOPbits:ID_PCp4),
    .EX_PCp4(EX_PCp4),
    .RTVAL(NRTVAL),
    .EX_RTVAL(EX_RTVAL)
    );

////
// Execute
////

EXForwarding thisEXForwarding(.EX_RS(EX_RS), .EX_RT(EX_RT),
    .EX_UseRT(EX_UseRT_ctrl),
    .EX_memWrite(EX_memWrite_ctrl),
    .ALUout(MEM_ALUOut),
    .WriteValue(WriteBackData),
    .MEM_Dest(MEM_RegWriteDest),
    .MEM_regWrite(MEM_regWrite_ctrl),
    .WB_Dest(WB_RegWriteDest),
    .WB_regWrite(WB_regWrite_ctrl),
    .AVAL(EX_A),
    .BVAL(EX_B),
    .AVF(ALUPortA),
    .BVF(ALUPortB),
    .RTVAL_in(EX_RTVAL),
    .RTVAL(EX_RTVALFwd));

// The ALU
ALU thisALU(.OpSelect(EX_ALUOpSelect_ctrl),.ALUPortA(ALUPortA),.ALUPortB(ALUPortB),.ALUOut(ALUOut),.ALUSHAMT(EX_SHAMT),.CarryOut(CarryOut_not_used),.Overflow(Overflow_not_used));

// EX-MEM Pipeline Register
// No NOP injection because execute doesn't cause stall in this pipeline
EX_MEM_PR thisEX_MEM_PR(.clk(clk),.en(~mStall),
.ALUOut_in(ALUOut),.MEM_ALUOut(MEM_ALUOut),
.RTVAL_in(EX_RTVALFwd),.MEM_RTVAL(MEM_RTVAL),
.PCp4_in(EX_PCp4),.MEM_PCp4(MEM_PCp4),
.RT_in(EX_RT),.MEM_RT(MEM_RT),
.memToReg_in(EX_memToReg_ctrl),.MEM_memToReg(MEM_memToReg_ctrl),
.memWrite_in(EX_memWrite_ctrl),.MEM_memWrite(MEM_memWrite_ctrl),
.regWrite_in(EX_regWrite_ctrl),.MEM_regWrite(MEM_regWrite_ctrl),
.LBU_in(EX_LBU_ctrl),.MEM_LBU(MEM_LBU_ctrl),
.ByteSize_in(EX_ByteSize_ctrl),.MEM_ByteSize(MEM_ByteSize_ctrl),
.Link_in(EX_Link_ctrl),.MEM_Link(MEM_Link_ctrl),
.SYSCALL_in(EX_SYSCALL_ctrl),.MEM_SYSCALL(MEM_SYSCALL_ctrl),
.DestReg_in(EX_RegWriteDest),.MEM_DestReg(MEM_RegWriteDest)
);

////
// MEM
////

MEMForwarding thisMEMForwarding(.MEM_RT(MEM_RT),
.MEM_memWrite(MEM_memWrite_ctrl),
.WriteValue(WriteBackData),
.WB_Dest(WB_RegWriteDest),
.WB_regWrite(WB_regWrite_ctrl),
.SWVAL(MEM_RTVAL),
.SWVALF(MEM_StoreValue));

                        // The Data Memory (IMEM is not coherent with DMEM)
DMEM thisDMEM(.Address(MEM_ALUOut),.SValue(MEM_StoreValue),.RValue(MemOut),.ReadMem(MEM_memToReg_ctrl),.WriteMem(MEM_memWrite_ctrl),.LBU(MEM_LBU_ctrl),.ByteOp(MEM_ByteSize_ctrl),.clk(clk),.Ready(DMEM_READY));

// MEM/WB Pipeline Register
// WB Stall is always 0 so this is always enabled
// which also means mStall = mStallInit = eStall
MEM_WB_PR thisMEM_WB_PR(.clk(clk),.en(1'b1),
.ALUOut_in(mStall?NOPbits:MEM_ALUOut),
.MemOut_in(mStall?NOPbits:MemOut),
.PCp4_in(mStall?NOPbits:MEM_PCp4),
.memToReg_in(mStall?NOPbits:MEM_memToReg_ctrl),
.Link_in(mStall?NOPbits:MEM_Link_ctrl),
.RegWrite_in(mStall?NOPbits:MEM_regWrite_ctrl),
.SYSCALL_in(mStall?NOPbits:MEM_SYSCALL_ctrl),
.RegWriteDest_in(mStall?NOPbits:MEM_RegWriteDest),
.WB_ALUout(WB_ALUOut),
.WB_MemOut(WB_MemOut),
.WB_PCp4(WB_PCp4),
.WB_memToReg_ctrl(WB_memToReg_ctrl),
.WB_Link_ctrl(WB_Link_ctrl),
.WB_RegWrite_ctrl(WB_regWrite_ctrl),
.WB_SYSCALL_ctrl(WB_SYSCALL_ctrl),
.WB_RegWriteDest(WB_RegWriteDest));

////
// WB
////

// Syscall emulation doesn't trigger until WB -- avoids messy forwarding/flushing concerns
SYSCALL_EMU actuallyAnOstrich(.KIWI(WB_SYSCALL_ctrl),.SCNUM(thisREGFILE.GPR[2]),.ARG(thisREGFILE.GPR[4])); // Non-synthesizable Verilog ahoy!

assign WriteBackData = WB_Link_ctrl?WB_PCp4:WB_memToReg_ctrl?WB_MemOut:WB_ALUOut; // JAL/JALR else LW/LB/LBU else ALU

endmodule