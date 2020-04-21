`timescale 1ns / 1ps

module EXForwarding(
    input [4:0] EX_RS,
    input [4:0] EX_RT,
    input EX_UseRT,
    input EX_memWrite,
    input [31:0] ALUout,
    input [31:0] WriteValue,
    input [4:0] MEM_Dest,
    input MEM_regWrite,
    input [4:0] WB_Dest,
    input WB_regWrite,
    input [31:0] AVAL,
    input [31:0] BVAL,
    output [31:0] AVF,
    output [31:0] BVF,
    output [31:0] RTVAL,
    input [31:0] RTVAL_in
    );
    
    assign AVF = (((EX_RS!=5'b00000) & (EX_RS==MEM_Dest) & MEM_regWrite)?ALUout:(((EX_RS!=5'b00000) & (EX_RS==WB_Dest) & WB_regWrite)?WriteValue:AVAL));
    assign BVF = (EX_UseRT)?(((EX_RT!=5'b00000) & (EX_RT==MEM_Dest) & MEM_regWrite)?ALUout:((EX_RT!=5'b00000) & (EX_RT==WB_Dest) & WB_regWrite)?WriteValue:BVAL):BVAL;
    assign RTVAL = (EX_memWrite & (EX_RT!=5'b00000) & (EX_RT==WB_Dest) & WB_regWrite)?WriteValue:RTVAL_in;
endmodule
