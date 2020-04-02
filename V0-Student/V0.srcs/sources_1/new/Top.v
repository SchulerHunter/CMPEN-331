`timescale 1ns / 1ps

module Top();
// LOOK MA, NO I/O!

reg clk;                // Fake clock

// INSTRUCTION RELATED SIGNALS
wire [31:0] IBits;      // bits of the instruction from IMEM
wire [5:0] Opcode;
wire [4:0] RS;
wire [4:0] RT;
wire [4:0] RD;
wire [4:0] SHAMT;
wire [5:0] FUNCT;
wire [15:0] IMM;
wire [25:0] JBITS;
assign Opcode = IBits[31:26];
assign RS = IBits[25:21];
assign RT = IBits[20:16];
assign RD = IBits[15:11];
assign SHAMT = IBits[10:6];
assign FUNCT = IBits[5:0];
assign IMM = IBits[15:0];
assign JBITS = IBits[26:0];

// DATAPATH RELATED SIGNALS
wire [31:0] ALUPortA;   // REG[RS]
wire [31:0] ALUPortB;   // REG[RT] or ExtendedImmediate
wire [31:0] ALUOut;     // primary output of ALU
wire EQ;                // ALUPortA==ALUPortB
wire CarryOut_not_used; // Reserved for later use
wire Overflow_not_used; // Reserved for later use
wire [31:0] RP2Out;     //REG[RT]
wire [31:0] MemOut;     // memory read value, if memToReg, else 0
                        // S or Z extended IMM
wire [31:0] ExtendedImmediate;
                        // Branch Target
wire [31:0] BranchTarget;   
wire [31:0] PCp4;       // PC + 4
wire [31:0] PC;         // PC
wire [63:0] HILO;        // HILO
wire [31:0] NextPC;     // Next PC
wire [63:0] NextHILO;   // Next HILO
assign NextHILO = 64'h00000000_00000000; // FIXME LATER - not used
wire [4:0] RegWriteDest; // RD, RT, 31
wire [31:0] WriteBackData;  // Data to be written to register file
wire [31:0] JumpTarget;     // Jump target
assign JumpTarget = {PCp4[31:28],JBITS,2'b00};
wire [31:0] JorRTarget;       // Either jump or register target
wire [31:0] BorPCp4Target;     // Either Branch Target or PC+4

// CONTROL SIGNALS
wire memToReg_ctrl;     // read from memory?
wire memWrite_ctrl;     // write to memory?
wire regWrite_ctrl;     // write to register file?
wire LBU_ctrl;          // return unsigned byte from DMEM
wire ByteSize_ctrl;     // byte op if 1, word op if 0
wire BranchSense_ctrl;  // BEQ if 0, BNE if 1
wire [3:0] ALUOpSelect_ctrl;   // Selects ALU Op
wire SZExtension_ctrl;  // SignExtend if 1, else zero extend
wire Jump_ctrl;              // nextPC uses jumptarget
wire RegToPC_ctrl;           // nextPC uses regValue
wire Branch_ctrl;            // currentInst is branch
wire Link_ctrl;             // JAL / JALR
wire RegDest_ctrl;          // RD else RT
wire SYSCALL_ctrl;          // Do Emulated Syscall
wire UseRT_ctrl;           // Use RT else IMM

// HW MODULES
                        // The PC
PC32 thePC(.in(NextPC),.out(PC),.en(1'b1),.reset(1'b0),.clk(clk));
                        // The 64-bit HILO Register          
HILO64 theHILO(.in(NextHILO),.out(HILO),.en(1'b1),.reset(1'b0),.clk(clk));
REGFILE thisREGFILE(.clk(clk),.WP1(RegWriteDest),.RP1(RS),.RP2(RT),.WriteEnable(regWrite_ctrl),.WriteData(WriteBackData),.RPOut1(ALUPortA),.RPOut2(RP2Out));  // The 32 general purpose registers
                        // The Instruction Memory
IMEM thisIMEM(.Address(PC),.InstBits(IBits));
                        // The Data Memory (IMEM is not coherent with DMEM)
DMEM thisDMEM(.Address(ALUOut),.SValue(RP2Out),.RValue(MemOut),.ReadMem(memToReg_ctrl),.WriteMem(memWrite_ctrl),.LBU(LBU_ctrl),.ByteOp(ByteSize_ctrl),.clk(clk));
                        // The ALU
ALU thisALU(.OpSelect(ALUOpSelect_ctrl),.ALUPortA(ALUPortA),.ALUPortB(ALUPortB),.ALUOut(ALUOut),.EQ(EQ),.ALUSHAMT(SHAMT),.CarryOut(CarryOut_not_used),.Overflow(Overflow_not_used));
                        // The Sign/Zero Extender
SZExtender SEXT(.IMM16(IMM),.SZ(SZExtension_ctrl),.EXT32(ExtendedImmediate));
                        // Generates PC + 4
IncFour thisPCADDER(.in(PC),.out(PCp4));
                        // Generates Branch Target
ScaledAdder thisBRANCHADDER(.Unscaled(PCp4),.Scaled(ExtendedImmediate),.Out(BranchTarget));
                        // Generates control signals
CONTROL thisCONTROL(.Opcode(Opcode),.Function(FUNCT),.memToReg_ctrl(memToReg_ctrl),.memWrite_ctrl(memWrite_ctrl),.regWrite_ctrl(regWrite_ctrl),.LBU_ctrl(LBU_ctrl),.ByteSize_ctrl(ByteSize_ctrl),.BranchSense_ctrl(BranchSense_ctrl),.ALUOpSelect_ctrl(ALUOpSelect_ctrl),.SZExtension_ctrl(SZExtension_ctrl),.Jump_ctrl(Jump_ctrl),.RegToPC_ctrl(RegToPC_ctrl),.Branch_ctrl(Branch_ctrl),.Link_ctrl(Link_ctrl),.RegDest_ctrl(RegDest_ctrl),.SYSCALL_ctrl(SYSCALL_ctrl),.UseRT_ctrl(UseRT_ctrl));

SYSCALL_EMU actuallyAnOstrich(.KIWI(SYSCALL_ctrl),.SCNUM(thisREGFILE.GPR[2]),.ARG(thisREGFILE.GPR[4])); // Non-synthesizable Verilog ahoy!

// MUXES

assign JorRTarget = RegToPC_ctrl?ALUPortA:JumpTarget; // JR/JALR else J/JAL
assign BorPCp4Target = (Branch_ctrl & (EQ ^ BranchSense_ctrl))?BranchTarget:PCp4; // Branch and branched else PC+4
assign NextPC = Jump_ctrl? JorRTarget:BorPCp4Target; // Jump side else branch side

assign WriteBackData = Link_ctrl?PCp4:memToReg_ctrl?MemOut:ALUOut; // JAL/JALR else LW/LB/LBU else ALU
assign RegWriteDest = Link_ctrl?5'b11111:RegDest_ctrl?RD:RT;

assign ALUPortB = UseRT_ctrl?RP2Out:ExtendedImmediate;

initial
begin
    clk = 0;
end

initial
begin
    #16385 $finish;
end

always
begin
    #1 clk = ~clk ; 
end

endmodule