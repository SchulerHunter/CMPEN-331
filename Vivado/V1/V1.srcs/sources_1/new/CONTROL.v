`timescale 1ns / 1ps

module CONTROL(
    input [5:0] Opcode,
    input [5:0] Function,
    output reg memToReg_ctrl,     // read from memory?
    output reg memWrite_ctrl,     // write to memory?
    output reg regWrite_ctrl,     // write to register file?
    output reg LBU_ctrl,          // return unsigned byte from DMEM
    output reg ByteSize_ctrl,     // byte op if 1, word op if 0
    output reg BranchSense_ctrl,  // BEQ if 0, BNE if 1
    output reg [3:0] ALUOpSelect_ctrl,   // Selects ALU Op
    output reg SZExtension_ctrl,  // SignExtend if 1, else zero extend
    output reg Jump_ctrl,              // nextPC uses jumptarget
    output reg RegToPC_ctrl,           // nextPC uses regValue
    output reg Branch_ctrl,            // currentInst is branch
    output reg Link_ctrl,             // JAL / JALR
    output reg RegDest_ctrl,          // RD else RT
    output reg SYSCALL_ctrl,          // Do Emulated Syscall
    output reg UseRT_ctrl            // Use RT else Immediate
    );
    
    always @ (*)
    begin
    memToReg_ctrl = 1'b0;     // read from memory?
    memWrite_ctrl = 1'b0;     // write to memory?
    regWrite_ctrl = 1'b0;     // write to register file?
    LBU_ctrl = 1'b0;          // return unsigned byte from DMEM
    ByteSize_ctrl = 1'b0;     // byte op if 1, word op if 0
    BranchSense_ctrl = 1'b0;  // BEQ if 0, BNE if 1
    ALUOpSelect_ctrl  = 4'b0000;   // Selects ALU Op
    SZExtension_ctrl = 1'b0;  // SignExtend if 1, else zero extend
    Jump_ctrl = 1'b0;              // nextPC uses jumptarget
    RegToPC_ctrl = 1'b0;           // nextPC uses regValue
    Branch_ctrl = 1'b0;            // currentInst is branch
    Link_ctrl = 1'b0;             // JAL / JALR
    RegDest_ctrl = 1'b0;          // RD else RT
    SYSCALL_ctrl = 1'b0;          // Do Emulated Syscall
    UseRT_ctrl = 1'b0;            // Use RT else IMM 
    case (Opcode)
    0:  begin // SPECIAL e.g. R-TYPE, Syscall
        regWrite_ctrl = 1'b1;     // write to register file?
        RegDest_ctrl = 1'b1;          // RD else RT
        UseRT_ctrl = 1'b1;            // Use RT else IMM
        case (Function)
        0:  begin // SLL
             ALUOpSelect_ctrl  = 4'h8;   // Selects ALU Op   
            end
        2:  begin // SRL
             ALUOpSelect_ctrl  = 4'h9;   // Selects ALU Op   
            end
        3:  begin // SRA
             ALUOpSelect_ctrl  = 4'hA;   // Selects ALU Op   
            end
        8:  begin // JR
            Jump_ctrl = 1'b1;              // nextPC uses jumptarget
            RegToPC_ctrl = 1'b1;           // nextPC uses regValue
            Link_ctrl = 1'b0;             // JAL / JALR
            end
        9:  begin // JALR
            Jump_ctrl = 1'b1;              // nextPC uses jumptarget
            RegToPC_ctrl = 1'b1;           // nextPC uses regValue
            Link_ctrl = 1'b1;             // JAL / JALR
            end
        12:  begin // SYSCALL --- EMULATED
            regWrite_ctrl = 1'b0;     // write to register file?
            SYSCALL_ctrl = 1'b1;          // Do Emulated Syscall
            end
        16:  begin // MFHI
            end
        18:  begin // MFLO
            end
        24:  begin // MULT
            ALUOpSelect_ctrl  = 4'hC;   // Selects ALU Op   
            end
        25:  begin // MULTU
            ALUOpSelect_ctrl  = 4'hE;   // Selects ALU Op   
            end
        26:  begin // DIV
             ALUOpSelect_ctrl  = 4'hD;   // Selects ALU Op   
            end
        27:  begin // DIVU
             ALUOpSelect_ctrl  = 4'hF;   // Selects ALU Op   
            end
        32:  begin // ADD
             ALUOpSelect_ctrl  = 4'h0;   // Selects ALU Op   
            end
        33:  begin // ADDU
             ALUOpSelect_ctrl  = 4'h0;   // Selects ALU Op   
            end
        34:  begin // SUB
             ALUOpSelect_ctrl  = 4'h1;   // Selects ALU Op   
            end
        35:  begin // SUBU
             ALUOpSelect_ctrl  = 4'h1;   // Selects ALU Op   
            end
        36:  begin // AND
             ALUOpSelect_ctrl  = 4'h2;   // Selects ALU Op   
            end
        37:  begin // OR
             ALUOpSelect_ctrl  = 4'h3;   // Selects ALU Op   
            end
        38:  begin // XOR
             ALUOpSelect_ctrl  = 4'h5;   // Selects ALU Op   
            end
        39:  begin // NOR
             ALUOpSelect_ctrl  = 4'h4;   // Selects ALU Op   
            end
        42:  begin // SLT
             ALUOpSelect_ctrl  = 4'h6;   // Selects ALU Op   
            end
        43:  begin // SLTU
             ALUOpSelect_ctrl  = 4'h7;   // Selects ALU Op   
            end
        default: 
            begin
            $display("Unknown Function Code for Opcode Zero: %x -- exiting", Function);
            $finish;
            end
        endcase
        end
    2:  begin // J
        Jump_ctrl = 1'b1;              // nextPC uses jumptarget
        Branch_ctrl = 1'b0;            // currentInst is branch
        Link_ctrl = 1'b0;             // JAL / JALR
        end
    3:  begin // JAL
        regWrite_ctrl = 1'b1;     // write to register file?
        Jump_ctrl = 1'b1;              // nextPC uses jumptarget
        Branch_ctrl = 1'b0;            // currentInst is branch
        Link_ctrl = 1'b1;             // JAL / JALR
        end
    4:  begin // BEQ
        BranchSense_ctrl = 1'b0;  // BEQ if 0, BNE if 1
        SZExtension_ctrl = 1'b1;  // SignExtend if 1, else zero extend
        Jump_ctrl = 1'b0;              // nextPC uses jumptarget
        Branch_ctrl = 1'b1;            // currentInst is branch
        Link_ctrl = 1'b0;             // JAL / JALR
        UseRT_ctrl = 1'b1;            // Use RT else IMM 
        end
    5:  begin // BNE
        BranchSense_ctrl = 1'b1;  // BEQ if 0, BNE if 1
        SZExtension_ctrl = 1'b1;  // SignExtend if 1, else zero extend
        Jump_ctrl = 1'b0;              // nextPC uses jumptarget
        Branch_ctrl = 1'b1;            // currentInst is branch
        Link_ctrl = 1'b0;             // JAL / JALR
        UseRT_ctrl = 1'b1;            // Use RT else IMM 
        end
    8:  begin // ADDI
        memToReg_ctrl = 1'b0;     // read from memory?
        memWrite_ctrl = 1'b0;     // write to memory?
        regWrite_ctrl = 1'b1;     // write to register file?
        LBU_ctrl = 1'b0;          // return unsigned byte from DMEM
        ByteSize_ctrl = 1'b0;     // byte op if 1, word op if 0
        ALUOpSelect_ctrl  = 4'h0;   // Selects ALU Op
        SZExtension_ctrl = 1'b1;  // SignExtend if 1, else zero extend
        end
    9:  begin // ADDIU
        memToReg_ctrl = 1'b0;     // read from memory?
        memWrite_ctrl = 1'b0;     // write to memory?
        regWrite_ctrl = 1'b1;     // write to register file?
        LBU_ctrl = 1'b0;          // return unsigned byte from DMEM
        ByteSize_ctrl = 1'b0;     // byte op if 1, word op if 0
        ALUOpSelect_ctrl  = 4'h0;   // Selects ALU Op
        SZExtension_ctrl = 1'b1;  // SignExtend if 1, else zero extend
        end
    10:  begin // SLTI
        memToReg_ctrl = 1'b0;     // read from memory?
        memWrite_ctrl = 1'b0;     // write to memory?
        regWrite_ctrl = 1'b1;     // write to register file?
        LBU_ctrl = 1'b0;          // return unsigned byte from DMEM
        ByteSize_ctrl = 1'b0;     // byte op if 1, word op if 0
        ALUOpSelect_ctrl  = 4'h6;   // Selects ALU Op
        SZExtension_ctrl = 1'b1;  // SignExtend if 1, else zero extend
        end
    11:  begin // SLTIU
        memToReg_ctrl = 1'b0;     // read from memory?
        memWrite_ctrl = 1'b0;     // write to memory?
        regWrite_ctrl = 1'b1;     // write to register file?
        LBU_ctrl = 1'b0;          // return unsigned byte from DMEM
        ByteSize_ctrl = 1'b0;     // byte op if 1, word op if 0
        ALUOpSelect_ctrl  = 4'h7;   // Selects ALU Op
        SZExtension_ctrl = 1'b1;  // SignExtend if 1, else zero extend
        end
    12:  begin // ANDI
        memToReg_ctrl = 1'b0;     // read from memory?
        memWrite_ctrl = 1'b0;     // write to memory?
        regWrite_ctrl = 1'b1;     // write to register file?
        LBU_ctrl = 1'b0;          // return unsigned byte from DMEM
        ByteSize_ctrl = 1'b0;     // byte op if 1, word op if 0
        ALUOpSelect_ctrl  = 4'h2;   // Selects ALU Op
        SZExtension_ctrl = 1'b0;  // SignExtend if 1, else zero extend
        end
    13:  begin // ORI
        memToReg_ctrl = 1'b0;     // read from memory?
        memWrite_ctrl = 1'b0;     // write to memory?
        regWrite_ctrl = 1'b1;     // write to register file?
        LBU_ctrl = 1'b0;          // return unsigned byte from DMEM
        ByteSize_ctrl = 1'b0;     // byte op if 1, word op if 0
        ALUOpSelect_ctrl  = 4'h3;   // Selects ALU Op
        SZExtension_ctrl = 1'b0;  // SignExtend if 1, else zero extend
        end
    14:  begin // XORI
        memToReg_ctrl = 1'b0;     // read from memory?
        memWrite_ctrl = 1'b0;     // write to memory?
        regWrite_ctrl = 1'b1;     // write to register file?
        LBU_ctrl = 1'b0;          // return unsigned byte from DMEM
        ByteSize_ctrl = 1'b0;     // byte op if 1, word op if 0
        ALUOpSelect_ctrl  = 4'h5;   // Selects ALU Op
        SZExtension_ctrl = 1'b0;  // SignExtend if 1, else zero extend
        end
    15:  begin // LUI
        memToReg_ctrl = 1'b0;     // read from memory?
        memWrite_ctrl = 1'b0;     // write to memory?
        regWrite_ctrl = 1'b1;     // write to register file?
        LBU_ctrl = 1'b0;          // return unsigned byte from DMEM
        ByteSize_ctrl = 1'b0;     // byte op if 1, word op if 0
        ALUOpSelect_ctrl  = 4'hB;   // Selects ALU Op
        SZExtension_ctrl = 1'b0;  // SignExtend if 1, else zero extend   
        end
    32:  begin // LB
        memToReg_ctrl = 1'b1;     // read from memory?
        memWrite_ctrl = 1'b0;     // write to memory?
        regWrite_ctrl = 1'b1;     // write to register file?
        LBU_ctrl = 1'b0;          // return unsigned byte from DMEM
        ByteSize_ctrl = 1'b1;     // byte op if 1, word op if 0
        ALUOpSelect_ctrl  = 4'h0;   // Selects ALU Op
        SZExtension_ctrl = 1'b1;  // SignExtend if 1, else zero extend
        end
    35:  begin // LW
        memToReg_ctrl = 1'b1;     // read from memory?
        memWrite_ctrl = 1'b0;     // write to memory?
        regWrite_ctrl = 1'b1;     // write to register file?
        LBU_ctrl = 1'b0;          // return unsigned byte from DMEM
        ByteSize_ctrl = 1'b0;     // byte op if 1, word op if 0
        ALUOpSelect_ctrl  = 4'h0;   // Selects ALU Op
        SZExtension_ctrl = 1'b1;  // SignExtend if 1, else zero extend
        end
    36:  begin // LBU
        memToReg_ctrl = 1'b1;     // read from memory?
        memWrite_ctrl = 1'b0;     // write to memory?
        regWrite_ctrl = 1'b1;     // write to register file?
        LBU_ctrl = 1'b1;          // return unsigned byte from DMEM
        ByteSize_ctrl = 1'b1;     // byte op if 1, word op if 0
        ALUOpSelect_ctrl  = 4'h0;   // Selects ALU Op
        SZExtension_ctrl = 1'b1;  // SignExtend if 1, else zero extend
        end
    40:  begin // SB
        memToReg_ctrl = 1'b0;     // read from memory?
        memWrite_ctrl = 1'b1;     // write to memory?
        regWrite_ctrl = 1'b0;     // write to register file?
        LBU_ctrl = 1'b0;          // return unsigned byte from DMEM
        ByteSize_ctrl = 1'b1;     // byte op if 1, word op if 0
        ALUOpSelect_ctrl  = 4'h0;   // Selects ALU Op
        SZExtension_ctrl = 1'b1;  // SignExtend if 1, else zero extend
        end
    43:  begin // SW
        memToReg_ctrl = 1'b0;     // read from memory?
        memWrite_ctrl = 1'b1;     // write to memory?
        regWrite_ctrl = 1'b0;     // write to register file?
        LBU_ctrl = 1'b0;          // return unsigned byte from DMEM
        ByteSize_ctrl = 1'b0;     // byte op if 1, word op if 0
        ALUOpSelect_ctrl  = 4'h0;   // Selects ALU Op
        SZExtension_ctrl = 1'b1;  // SignExtend if 1, else zero extend
        end
    default: 
        begin
            $display("Unknown Opcode: %x -- exiting", Opcode);
            $finish;
        end
    endcase
    end
endmodule
