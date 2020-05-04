`timescale 1ns / 1ps

module Top(input clk);
// Now timely, but still silent

// Stall Signals
wire HazardDetected;
wire NoHazardDetected;
assign NoHazardDetected = ~HazardDetected;

wire IMEM_READY; // Indicates that this fetch was successful. Repeat if not ready
wire DMEM_READY; // Indicates that this DMEM access was successful. Repeat if not ready

// Fetch Stage Signals
wire [31:0] IBits;      // bits of the instruction from IMEM
wire [31:0] NextInst; // IBits or NOP
wire [31:0] NOPbits; // SLL $0, $0, 0 is the cannonical NOP
assign NOPbits = 32'h0000_0000;
wire [31:0] PCp4;       // PC + 4
wire [31:0] PC;         // PC
wire [31:0] NextPC;     // Next PC

// DeumpSignal counter variables
wire [31:0] nextICount;
wire [31:0] ICount;
wire succesfulFetch;
wire pipeFlush;
wire dumpTrigger;

R32 iCount(.in(nextICount),.out(ICount),.en(succesfulFetch),.reset(1'b0),.clk(clk));

assign nextICount = pipeFlush?ICount:ICount+1;
assign pipeFlush = ICount == 100;
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
wire ID_UseHILO_ctrl;
wire ID_WriteHILO_ctrl;

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
wire EX_WriteHILO_ctrl;
wire EX_UseHILO_ctrl;
wire [61:0] EX_HILO;
wire [31:0] EX_HI;

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

wire [63:0] FWD_HILO;
wire [63:0] HILO;        // HILO
wire [63:0] NextHILO;   // Next HILO

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
wire MEM_WriteHILO_ctrl;
wire [31:0] MEM_HI;

// Memory Related Signals
wire [31:0] MemOut;     // memory read value, if memToReg, else 0

wire [31:0] WB_ALUOut;
wire [31:0] WB_PCp4;
wire [31:0] WB_MemOut;
wire WB_memToReg_ctrl;     // read from memory?
wire WB_Link_ctrl;             // JAL / JALR
wire WB_regWrite_ctrl;     // write to register file?
wire WB_SYSCALL_ctrl;          // Do Emulated Syscall
wire [4:0] WB_RegWriteDest; // RD, RT, 31
wire [31:0] WriteBackData;  // Data to be written to register file
wire WB_WriteHILO_ctrl;
wire [31:0] WB_HI;

assign NextHILO = {WB_HI,WB_ALUOut};

wire [31:0] ID_PC;
wire [31:0] EX_PC;

wire ID_known_ctrl;
wire EX_unknown_ctrl;

// Data dependent control
wire BranchTaken;         // Was a branch taken?
wire IFlush;

wire FetchStall;
wire DecodeStall;
wire ExecuteStall;
wire MemoryStall;
wire WritebackStall;

wire FetchInitiatesStall;
wire DecodeInitiatesStall;
wire ExecuteInitiatesStall;
wire MemoryInitiatesStall;
wire WritebackInitiatesStall;

wire MemAccessAttempt;
assign MemAccessAttempt = MEM_memWrite_ctrl | MEM_memToReg_ctrl;

assign WritebackInitiatesStall = 1'b0; // Writeback never stalls
assign MemoryInitiatesStall = MemAccessAttempt & ~DMEM_READY; // Memory only stalls when accessing memory and not ready
assign ExecuteInitiatesStall = ~IMEM_READY & EX_unknown_ctrl; // Only stalls when stage in front is stalled - does not initiate stalls
assign DecodeInitiatesStall = HazardDetected | pipeFlush; // Initiates stalls when hazard detected
assign FetchInitiatesStall = ~IMEM_READY; // Initiates stall if IMEM not ready

assign WritebackStall = 1'b0; // Writeback never stalls
assign MemoryStall = WritebackStall | MemoryInitiatesStall; // Memory only stalls when accessing memory and not ready
assign ExecuteStall = MemoryStall | ExecuteInitiatesStall; // Only stalls when stage in front is stalled - does not initiate stalls
assign DecodeStall =  ExecuteStall | DecodeInitiatesStall; // Initiates stalls when hazard detected, stalls when E is stalled
// Fetch Stall is different -- stalling means doing the instruction again, but flushed instructions shouldn't exist to be repeated
assign FetchStall = IFlush?1'b0:(DecodeStall | FetchInitiatesStall); // Flushes do not stall (don't want to repeat) Stalls if D stalls, initiates stall if IMEM not ready



// FETCH STATE = PC
                        // The PC
PC32 thePC(.in(NextPC),.out(PC),.en(~FetchStall),.reset(1'b0),.clk(clk));

wire [31:0] BTB_out;
wire [31:0] BTBTargetInst;
wire [31:0] BTBTargetPC;
wire BTB_hit;
wire BTB_is_jump;
wire PredictedBranchDirection;
wire ID_PredictedBranchDirection;

wire [31:0] BTB_InstBits;
wire [31:0] BTB_UpdateTargetPC;
                        // The Last Instruction Fetched from the BTB
R32 guessedInst(.in(BTBTargetInst),.out(BTB_InstBits),.en(BTB_hit),.reset(1'b0),.clk(clk));

////
// FETCH
////

BTB thisBTB(.clk(clk),
.accessPC(PC),.outInstBits(BTBTargetInst),.targetPC(BTBTargetPC),.btbHit(BTB_hit),.btbType(BTB_is_jump),
.update_ctrl(EX_unknown_ctrl),.updatePC(EX_PC),.updateInstBits(IBits),.updateTargetPC(BTB_UpdateTargetPC));

BHT thisBHT(.clk(clk),
.PC(PC),.Prediction(PredictedBranchDirection),
.DoUpdate(Branch_ctrl),.UpdatePC(ID_PC),.UpdateDirection(BranchTaken));

wire ICacheFillRequest;
wire [31:0] ICacheFillAddress;
wire [511:0] ICacheFillData;
                        // The Instruction Memory
ICACHE thisICACHE(.Address(PC),.InstBits(IBits),.Ready(IMEM_READY),.clk(clk),
.IFill(ICacheFillRequest),
.IFill_Address(ICacheFillAddress),
.Fill_Contents(ICacheFillData));
                        // Generates PC + 4
IncFour thisPCADDER(.in(PC),.out(PCp4));

wire bTmissNT; // Branch predicted not taken that was supposed to be taken
assign bTmissNT = ~DecodeStall & ((~ID_known_ctrl & BranchTaken)|(ID_known_ctrl & BranchTaken & ~ID_PredictedBranchDirection));
wire bNTmissT; // Branch predicted taken that was supposed to be not taken
assign bNTmissT = ~DecodeStall & ID_known_ctrl & Branch_ctrl & ~BranchTaken & ID_PredictedBranchDirection;
wire jTmissNT; // Jump predicted not taken despite always being taken
assign jTmissNT = (Jump_ctrl & ~ID_known_ctrl);

assign JorRTarget = RegToPC_ctrl?RP1Out:JumpTarget; // JR/JALR else J/JAL
assign BorPCp4Target = bTmissNT?BranchTarget
                         :bNTmissT?ID_PCp4
                           :(BTB_hit&(PredictedBranchDirection | BTB_is_jump))?BTBTargetPC
                             :PCp4; // Branch and branched else PC+4
assign NextPC = (jTmissNT)? JorRTarget:BorPCp4Target; // Jump side else branch side

assign NextInst = (IFlush|FetchInitiatesStall)?NOPbits:IBits;

assign succesfulFetch = ~IFlush & ~FetchStall;
wire noPendingRegWrites;
wire noPendingHILOWrites;
wire noPendingMemWrites;
wire noPendingSyscalls;

assign noPendingRegWrites = ~(EX_regWrite_ctrl | MEM_regWrite_ctrl | WB_regWrite_ctrl);
assign noPendingHILOWrites = ~(EX_WriteHILO_ctrl | MEM_WriteHILO_ctrl | WB_WriteHILO_ctrl);
assign noPendingMemWrites = ~(EX_memWrite_ctrl | MEM_memWrite_ctrl);
assign noPendingSyscalls = ~(EX_SYSCALL_ctrl | MEM_SYSCALL_ctrl | WB_SYSCALL_ctrl);

assign dumpTrigger = pipeFlush & noPendingRegWrites & noPendingHILOWrites & noPendingMemWrites & noPendingSyscalls;
// IF-ID Pipeline Register
IF_ID_PR thisIF_ID_PR(.clk(clk),.en(~DecodeStall),
.BeingFetched(FetchInitiatesStall?32'b0:NextInst),.WasFetched(ID_IBits),
.PCp4(FetchInitiatesStall?32'b0:PCp4),.ID_PCp4(ID_PCp4),
.PC_in(FetchInitiatesStall?32'b0:PC),.ID_PC(ID_PC),
.BTB_known_ctrl(FetchInitiatesStall?1'b0:BTB_hit),.ID_known_ctrl(ID_known_ctrl),
.PredictedBranchDirection(FetchInitiatesStall?1'b0:PredictedBranchDirection),.ID_PredictedBranchDirection(ID_PredictedBranchDirection));


////
// DECODE
////

                        // The 64-bit HILO Register          
HILO64 theHILO(.in(NextHILO),.out(HILO),.en(WB_WriteHILO_ctrl),.reset(1'b0),.clk(clk));

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
    .RTF(RP2Forwarded),
    .MEMValue(MEM_ALUOut),
    .MEM_Dest(MEM_RegWriteDest),
    .MEM_regWrite(MEM_regWrite_ctrl),
    .ComputesInDecode(Branch_ctrl | RegToPC_ctrl)
    );

assign FWD_HILO = DecodeInitiatesStall?64'h0:(WB_WriteHILO_ctrl?NextHILO:HILO);

// The 32 general purpose registers
REGFILE thisREGFILE(.clk(clk),.WP1(WB_RegWriteDest),.RP1(RS),.RP2(RT),.WriteEnable(WB_regWrite_ctrl),.WriteData(WriteBackData),.RPOut1(RP1Out),.RPOut2(RP2Out));  
// Equality Comparator
EQComp thisEQComp(.RRS(RP1Forwarded),.RRT(RP2Forwarded),.EQ(EQ)); 
// The Sign/Zero Extender
SZExtender SEXT(.IMM16(IMM),.SZ(SZExtension_ctrl),.EXT32(ExtendedImmediate));
// Generates Branch Target
ScaledAdder thisBRANCHADDER(.Unscaled(ID_PCp4),.Scaled(ExtendedImmediate),.Out(BranchTarget));
// Generates control signals
CONTROL thisCONTROL(.Opcode(Opcode),.Function(FUNCT),.memToReg_ctrl(ID_memToReg_ctrl),.memWrite_ctrl(ID_memWrite_ctrl),
.regWrite_ctrl(ID_regWrite_ctrl),.LBU_ctrl(ID_LBU_ctrl),.ByteSize_ctrl(ID_ByteSize_ctrl),.BranchSense_ctrl(BranchSense_ctrl),
.ALUOpSelect_ctrl(ID_ALUOpSelect_ctrl),.SZExtension_ctrl(SZExtension_ctrl),.Jump_ctrl(Jump_ctrl),.RegToPC_ctrl(RegToPC_ctrl),
.Branch_ctrl(Branch_ctrl),.Link_ctrl(ID_Link_ctrl),.RegDest_ctrl(ID_RegDest_ctrl),.SYSCALL_ctrl(ID_SYSCALL_ctrl),
.UseRT_ctrl(ID_UseRT_ctrl),.readHILO_ctrl(ID_UseHILO_ctrl),.writeHILO_ctrl(ID_WriteHILO_ctrl));

// Data-independent muxes
assign NRP1Forwarded = HazardDetected?32'h0000_0000:RP1Forwarded;
assign NRP2Forwarded = HazardDetected?32'h0000_0000:ID_OperandB;
assign NRTVAL = HazardDetected?32'h0000_0000:RP2Forwarded;
assign ID_RegWriteDest = ID_Link_ctrl?5'b11111:ID_RegDest_ctrl?RD:RT;
assign ID_OperandB = ID_UseRT_ctrl?RP2Forwarded:ExtendedImmediate;

// Data-dependent control muxes
assign BranchTaken = Branch_ctrl & (EQ ^ BranchSense_ctrl);

assign IFlush = bTmissNT | bNTmissT | jTmissNT;

// ID-EX Pipeline Register
    
ID_EX_PR thisID_EX_PR(.clk(clk),.en(~ExecuteStall),
.memToReg_in(DecodeInitiatesStall?1'h0:NEX_memToReg_ctrl),.memToReg_out(EX_memToReg_ctrl),
.memWrite_in(DecodeInitiatesStall?1'h0:NEX_memWrite_ctrl),.memWrite_out(EX_memWrite_ctrl),
.regWrite_in(DecodeInitiatesStall?1'h0:NEX_regWrite_ctrl),.regWrite_out(EX_regWrite_ctrl),
.LBU_in(DecodeInitiatesStall?1'h0:NEX_LBU_ctrl),.LBU_out(EX_LBU_ctrl),
.ByteSize_in(DecodeInitiatesStall?1'h0:NEX_ByteSize_ctrl),.ByteSize_out(EX_ByteSize_ctrl),
.ALUOp_in(DecodeInitiatesStall?4'h0:NEX_ALUOpSelect_ctrl),.ALUOp_out(EX_ALUOpSelect_ctrl),
.Link_in(DecodeInitiatesStall?1'h0:NEX_Link_ctrl),.Link_out(EX_Link_ctrl),
.SYSCALL_in(DecodeInitiatesStall?1'h0:NEX_SYSCALL_ctrl),.SYSCALL_out(EX_SYSCALL_ctrl),
.UseRT_in(DecodeInitiatesStall?1'h0:NEX_UseRT_ctrl),.UseRT_out(EX_UseRT_ctrl),
.DestReg_in(DecodeInitiatesStall?5'h0:NEX_RegWriteDest),.DestReg_out(EX_RegWriteDest),
    .A_in(DecodeInitiatesStall?32'h0:NRP1Forwarded),
    .B_in(DecodeInitiatesStall?32'h0:NRP2Forwarded),
    .A_out(EX_A),
    .B_out(EX_B),
    .A_ID_in(DecodeInitiatesStall?5'h0:NEX_RS),
    .B_ID_in(DecodeInitiatesStall?5'h0:NEX_RT),
    .A_ID_out(EX_RS),
    .B_ID_out(EX_RT),
    .SHAMT_in(DecodeInitiatesStall?5'h0:NEX_SHAMT),
    .SHAMT_out(EX_SHAMT),
    .PCp4_in(DecodeInitiatesStall?32'h0:ID_PCp4),
    .EX_PCp4(EX_PCp4),
    .RTVAL(DecodeInitiatesStall?32'h0:NRTVAL),
    .EX_RTVAL(EX_RTVAL),
    .PC_in(DecodeInitiatesStall?32'h0:ID_PC),
    .EX_PC(EX_PC),
    .ID_unknown_ctrlPC(DecodeInitiatesStall?1'h0:(~ID_known_ctrl & ((Branch_ctrl & BranchTaken) | (Jump_ctrl & ~RegToPC_ctrl)))),
    .EX_unknown_ctrlPC(EX_unknown_ctrl),
    .ID_Target(DecodeInitiatesStall?32'h0:Branch_ctrl?BranchTarget:JumpTarget),
    .EX_Target(BTB_UpdateTargetPC),
    .ID_WriteHILO_ctrl(DecodeInitiatesStall?1'b0:ID_WriteHILO_ctrl),
    .EX_WriteHILO_ctrl(EX_WriteHILO_ctrl),
    .ID_UseHILO_ctrl(DecodeInitiatesStall?1'b0:ID_UseHILO_ctrl),
    .EX_UseHILO_ctrl(EX_UseHILO_ctrl),
    .ID_HILO(DecodeInitiatesStall?64'h0:FWD_HILO),
    .EX_HILO(EX_HILO)
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

    wire [31:0] FWD_LO;
    assign FWD_LO = MEM_WriteHILO_ctrl?MEM_ALUOut:(WB_WriteHILO_ctrl?WB_ALUOut:EX_HILO[31:0]);

// The ALU
ALU thisALU(.OpSelect(EX_ALUOpSelect_ctrl),.ALUPortA(ALUPortA),.ALUPortB(ALUPortB),.ALUOut(ALUOut),
.ALUSHAMT(EX_SHAMT),.CarryOut(CarryOut_not_used),.Overflow(Overflow_not_used),.HIout(EX_HI));

// EX-MEM Pipeline Register
EX_MEM_PR thisEX_MEM_PR(.clk(clk),.en(~MemoryStall),
.ALUOut_in(ExecuteInitiatesStall?32'b0:EX_UseHILO_ctrl?FWD_LO:ALUOut),.MEM_ALUOut(MEM_ALUOut),
.RTVAL_in(ExecuteInitiatesStall?32'b0:EX_RTVALFwd),.MEM_RTVAL(MEM_RTVAL),
.PCp4_in(ExecuteInitiatesStall?32'b0:EX_PCp4),.MEM_PCp4(MEM_PCp4),
.RT_in(ExecuteInitiatesStall?5'b0:EX_RT),.MEM_RT(MEM_RT),
.memToReg_in(ExecuteInitiatesStall?1'b0:EX_memToReg_ctrl),.MEM_memToReg(MEM_memToReg_ctrl),
.memWrite_in(ExecuteInitiatesStall?1'b0:EX_memWrite_ctrl),.MEM_memWrite(MEM_memWrite_ctrl),
.regWrite_in(ExecuteInitiatesStall?1'b0:EX_regWrite_ctrl),.MEM_regWrite(MEM_regWrite_ctrl),
.LBU_in(ExecuteInitiatesStall?1'b0:EX_LBU_ctrl),.MEM_LBU(MEM_LBU_ctrl),
.ByteSize_in(ExecuteInitiatesStall?1'b0:EX_ByteSize_ctrl),.MEM_ByteSize(MEM_ByteSize_ctrl),
.Link_in(ExecuteInitiatesStall?1'b0:EX_Link_ctrl),.MEM_Link(MEM_Link_ctrl),
.SYSCALL_in(ExecuteInitiatesStall?1'b0:EX_SYSCALL_ctrl),.MEM_SYSCALL(MEM_SYSCALL_ctrl),
.DestReg_in(ExecuteInitiatesStall?5'b0:EX_RegWriteDest),.MEM_DestReg(MEM_RegWriteDest),
.EX_WriteHILO_ctrl(ExecuteInitiatesStall?1'b0:EX_WriteHILO_ctrl),.MEM_WriteHILO_ctrl(MEM_WriteHILO_ctrl),
.EX_HI(ExecuteInitiatesStall?64'b0:EX_HI),.MEM_HI(MEM_HI)
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

wire DCacheFillRequest;
wire [31:0] DCacheFillAddress;
wire [255:0] DCacheFillData;
wire DCacheWriteback; 
wire [31:0] DCacheWritebackAddress;
wire [255:0] DCacheWritebackData;
                        // The Data Memory (IMEM is not coherent with DMEM)
DCACHE thisDCACHE(.Address(MEM_ALUOut),.SValue(MEM_StoreValue),.RValue(MemOut),.ReadMem(MEM_memToReg_ctrl),.WriteMem(MEM_memWrite_ctrl),.LBU(MEM_LBU_ctrl),.ByteOp(MEM_ByteSize_ctrl),.clk(clk),.Ready(DMEM_READY),
.DFill(DCacheFillRequest),.DFill_Address(DCacheFillAddress),.Fill_Contents(DCacheFillData),
.WriteBack(DCacheWriteback),.WB_Address(DCacheWritebackAddress),.WB_Value(DCacheWritebackData));

// MEM/WB Pipeline Register
MEM_WB_PR thisMEM_WB_PR(.clk(clk),.en(~WritebackStall),
.ALUOut_in(MemoryInitiatesStall?32'h0000_0000:MEM_ALUOut),
.MemOut_in(MemoryInitiatesStall?32'h0000_0000:MemOut),
.PCp4_in(MemoryInitiatesStall?32'h0000_0000:MEM_PCp4),
.memToReg_in(MemoryInitiatesStall?1'b0:MEM_memToReg_ctrl),
.Link_in(MemoryInitiatesStall?1'b0:MEM_Link_ctrl),
.RegWrite_in(MemoryInitiatesStall?1'b0:MEM_regWrite_ctrl),
.SYSCALL_in(MemoryInitiatesStall?1'b0:MEM_SYSCALL_ctrl),
.RegWriteDest_in(MemoryInitiatesStall?5'b00000:MEM_RegWriteDest),
.MEM_WriteHILO_ctrl(MemoryInitiatesStall?1'b0:MEM_WriteHILO_ctrl),
.MEM_HI(MemoryInitiatesStall?64'b0:MEM_HI),
.WB_ALUout(WB_ALUOut),
.WB_MemOut(WB_MemOut),
.WB_PCp4(WB_PCp4),
.WB_memToReg_ctrl(WB_memToReg_ctrl),
.WB_Link_ctrl(WB_Link_ctrl),
.WB_RegWrite_ctrl(WB_regWrite_ctrl),
.WB_SYSCALL_ctrl(WB_SYSCALL_ctrl),
.WB_RegWriteDest(WB_RegWriteDest),
.WB_WriteHILO_ctrl(WB_WriteHILO_ctrl),
.WB_HI(WB_HI)
);

////
// WB
////

// Syscall emulation doesn't trigger until WB -- avoids messy forwarding/flushing concerns
SYSCALL_EMU actuallyAVelociraptor(.KIWI(WB_SYSCALL_ctrl),.SCNUM(thisREGFILE.GPR[2]),.ARG(thisREGFILE.GPR[4])); // Non-synthesizable Verilog ahoy!

assign WriteBackData = WB_Link_ctrl?WB_PCp4:WB_memToReg_ctrl?WB_MemOut:WB_ALUOut; // JAL/JALR else LW/LB/LBU else ALU

MainMemory thisMainMemory(.clk(clk),
.IMEM_Read_Address(ICacheFillAddress),.IMEM_Read_Data(ICacheFillData),.IMEM_Read_ctrl(ICacheFillRequest),
.DMEM_Read_Address(DCacheFillAddress),.DMEM_Read_Data(DCacheFillData),.DMEM_Read_ctrl(DCacheFillRequest),
.DMEM_Write_Address(DCacheWritebackAddress),.DMEM_Write_Data(DCacheWritebackData),.DMEM_Write_ctrl(DCacheWriteback));

integer pcFile;
integer memFile;
integer HILOFile;
integer regFile;
integer regNum;
integer memAddr;
integer dcacheIndex;
always @(*) begin
    if (dumpTrigger) begin // dump states to files and quits the simulation
        pcFile=$fopen("pc.rmh");
        memFile=$fopen("mem.rmh");
        HILOFile=$fopen("hilo.rmh");
        regFile=$fopen("reg.rmh");
        $fdisplay(pcFile,"%x %x %x %x",ID_PC[31:24],ID_PC[23:16],ID_PC[15:8],ID_PC[7:0]); // 100th instruction is in Decode - dump its PC
        $fdisplay(HILOFile,"%x %x %x %x\n%x %x %x %x",HILO[63:56],HILO[55:48],HILO[47:40],HILO[39:32],HILO[31:24],HILO[23:16],HILO[15:8],HILO[7:0]); // dump HILO
        for (regNum=0; regNum<32; regNum=regNum+1) begin
            $fdisplay(regFile,"%x %x %x %x",thisREGFILE.GPR[regNum][31:24],thisREGFILE.GPR[regNum][23:16],thisREGFILE.GPR[regNum][15:8],thisREGFILE.GPR[regNum][7:0]);
        end
        for (memAddr=0; memAddr<65536; memAddr = memAddr+4) begin
            $fdisplay(memFile,"%x %x %x %x",(
            (thisMainMemory.MEMCONTENTS[memAddr]===8'bxxxx_xxxx)?8'h0:thisMainMemory.MEMCONTENTS[memAddr]),
            ((thisMainMemory.MEMCONTENTS[memAddr+1]===8'bxxxx_xxxx)?8'h0:thisMainMemory.MEMCONTENTS[memAddr+1]),
            ((thisMainMemory.MEMCONTENTS[memAddr+2]===8'bxxxx_xxxx)?8'h0:thisMainMemory.MEMCONTENTS[memAddr+2]),
            ((thisMainMemory.MEMCONTENTS[memAddr+3]===8'bxxxx_xxxx)?8'h0:thisMainMemory.MEMCONTENTS[memAddr+3]));
        end
        for (dcacheIndex = 0; dcacheIndex < 32; dcacheIndex = dcacheIndex+1) begin
            if (thisDCACHE.valid0[dcacheIndex] & thisDCACHE.dirty0[dcacheIndex]) begin // write dirty lines as diff
                $fdisplay(memFile,"@ %x\n%x %x %x %x\n%x %x %x %x\n%x %x %x %x\n%x %x %x %x\n%x %x %x %x\n%x %x %x %x\n%x %x %x %x\n%x %x %x %x", 
                {thisDCACHE.tag0[dcacheIndex],dcacheIndex[4:0],5'b00000},
                ((thisDCACHE.content0[dcacheIndex][255:248]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][255:248]),
                ((thisDCACHE.content0[dcacheIndex][247:240]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][247:240]),
                ((thisDCACHE.content0[dcacheIndex][239:232]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][239:232]),
                ((thisDCACHE.content0[dcacheIndex][231:224]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][231:224]),
                ((thisDCACHE.content0[dcacheIndex][223:216]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][223:216]),
                ((thisDCACHE.content0[dcacheIndex][215:208]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][215:208]),
                ((thisDCACHE.content0[dcacheIndex][207:200]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][207:200]),
                ((thisDCACHE.content0[dcacheIndex][199:192]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][199:192]),
                ((thisDCACHE.content0[dcacheIndex][191:184]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][191:184]),
                ((thisDCACHE.content0[dcacheIndex][183:176]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][183:176]),
                ((thisDCACHE.content0[dcacheIndex][175:168]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][175:168]),
                ((thisDCACHE.content0[dcacheIndex][167:160]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][167:160]),
                ((thisDCACHE.content0[dcacheIndex][159:152]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][159:152]),
                ((thisDCACHE.content0[dcacheIndex][151:144]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][151:144]),
                ((thisDCACHE.content0[dcacheIndex][143:136]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][143:136]),
                ((thisDCACHE.content0[dcacheIndex][135:128]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][135:128]),
                ((thisDCACHE.content0[dcacheIndex][127:120]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][127:120]),
                ((thisDCACHE.content0[dcacheIndex][119:112]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][119:112]),
                ((thisDCACHE.content0[dcacheIndex][111:104]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][111:104]),
                ((thisDCACHE.content0[dcacheIndex][103:96]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][103:96]),
                ((thisDCACHE.content0[dcacheIndex][95:88]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][95:88]),
                ((thisDCACHE.content0[dcacheIndex][87:80]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][87:80]),
                ((thisDCACHE.content0[dcacheIndex][79:72]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][79:72]),
                ((thisDCACHE.content0[dcacheIndex][71:64]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][71:64]),
                ((thisDCACHE.content0[dcacheIndex][63:56]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][63:56]),
                ((thisDCACHE.content0[dcacheIndex][55:48]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][55:48]),
                ((thisDCACHE.content0[dcacheIndex][47:40]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][47:40]),
                ((thisDCACHE.content0[dcacheIndex][39:32]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][39:32]),
                ((thisDCACHE.content0[dcacheIndex][31:24]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][31:24]),
                ((thisDCACHE.content0[dcacheIndex][23:16]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][23:16]),
                ((thisDCACHE.content0[dcacheIndex][15:8]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][15:8]),
                ((thisDCACHE.content0[dcacheIndex][7:0]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content0[dcacheIndex][7:0]));
            end if (thisDCACHE.valid1[dcacheIndex]&thisDCACHE.dirty1[dcacheIndex]) begin
                $fdisplay(memFile,"@ %x\n%x %x %x %x\n%x %x %x %x\n%x %x %x %x\n%x %x %x %x\n%x %x %x %x\n%x %x %x %x\n%x %x %x %x\n%x %x %x %x",
                {thisDCACHE.tag1[dcacheIndex],dcacheIndex[4:0],5'b00000},
                ((thisDCACHE.content1[dcacheIndex][255:248]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][255:248]),
                ((thisDCACHE.content1[dcacheIndex][247:240]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][247:240]),
                ((thisDCACHE.content1[dcacheIndex][239:232]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][239:232]),
                ((thisDCACHE.content1[dcacheIndex][231:224]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][231:224]),
                ((thisDCACHE.content1[dcacheIndex][223:216]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][223:216]),
                ((thisDCACHE.content1[dcacheIndex][215:208]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][215:208]),
                ((thisDCACHE.content1[dcacheIndex][207:200]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][207:200]),
                ((thisDCACHE.content1[dcacheIndex][199:192]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][199:192]),
                ((thisDCACHE.content1[dcacheIndex][191:184]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][191:184]),
                ((thisDCACHE.content1[dcacheIndex][183:176]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][183:176]),
                ((thisDCACHE.content1[dcacheIndex][175:168]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][175:168]),
                ((thisDCACHE.content1[dcacheIndex][167:160]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][167:160]),
                ((thisDCACHE.content1[dcacheIndex][159:152]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][159:152]),
                ((thisDCACHE.content1[dcacheIndex][151:144]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][151:144]),
                ((thisDCACHE.content1[dcacheIndex][143:136]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][143:136]),
                ((thisDCACHE.content1[dcacheIndex][135:128]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][135:128]),
                ((thisDCACHE.content1[dcacheIndex][127:120]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][127:120]),
                ((thisDCACHE.content1[dcacheIndex][119:112]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][119:112]),
                ((thisDCACHE.content1[dcacheIndex][111:104]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][111:104]),
                ((thisDCACHE.content1[dcacheIndex][103:96]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][103:96]),
                ((thisDCACHE.content1[dcacheIndex][95:88]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][95:88]),
                ((thisDCACHE.content1[dcacheIndex][87:80]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][87:80]),
                ((thisDCACHE.content1[dcacheIndex][79:72]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][79:72]),
                ((thisDCACHE.content1[dcacheIndex][71:64]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][71:64]),
                ((thisDCACHE.content1[dcacheIndex][63:56]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][63:56]),
                ((thisDCACHE.content1[dcacheIndex][55:48]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][55:48]),
                ((thisDCACHE.content1[dcacheIndex][47:40]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][47:40]),
                ((thisDCACHE.content1[dcacheIndex][39:32]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][39:32]),
                ((thisDCACHE.content1[dcacheIndex][31:24]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][31:24]),
                ((thisDCACHE.content1[dcacheIndex][23:16]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][23:16]),
                ((thisDCACHE.content1[dcacheIndex][15:8]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][15:8]),
                ((thisDCACHE.content1[dcacheIndex][7:0]===8'bxxxx_xxxx)?8'h0:thisDCACHE.content1[dcacheIndex][7:0]));
            end
        end
        $fclose(pcFile);
        $fclose(memFile);
        $fclose(HILOFile);
        $fclose(regFile);
        $finish;
    end
end

endmodule