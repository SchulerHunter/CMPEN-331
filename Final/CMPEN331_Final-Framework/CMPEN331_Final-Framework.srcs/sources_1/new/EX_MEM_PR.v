`timescale 1ns / 1ps

module EX_MEM_PR(
    input clk,
    input en,
    input [31:0] ALUOut_in,
    output reg [31:0] MEM_ALUOut,
    input [31:0] RTVAL_in,
    output reg [31:0] MEM_RTVAL,
    input [31:0] PCp4_in,
    output reg [31:0] MEM_PCp4,
    input [4:0] RT_in,
    output reg [4:0] MEM_RT,
    input memToReg_in,
    output reg MEM_memToReg,
    input memWrite_in,
    output reg MEM_memWrite,
    input regWrite_in,
    output reg MEM_regWrite,
    input LBU_in,
    output reg MEM_LBU,
    input ByteSize_in,
    output reg MEM_ByteSize,
    input Link_in,
    output reg MEM_Link,
    input SYSCALL_in,
    output reg MEM_SYSCALL,
    input [4:0] DestReg_in,
    output reg [4:0] MEM_DestReg,
    input EX_WriteHILO_ctrl,
    output reg MEM_WriteHILO_ctrl,
    input EX_UseHILO_ctrl,
    output reg MEM_UseHILO_ctrl,
    input EX_HI, 
    output reg [31:0] MEM_HI
    );
    
always @ (posedge clk)
begin
if(en)
begin
    MEM_ALUOut<=ALUOut_in;
    MEM_RTVAL<=RTVAL_in;
    MEM_PCp4<=PCp4_in;
    MEM_RT<=RT_in;
    MEM_memToReg<=memToReg_in;
    MEM_memWrite<=memWrite_in;
    MEM_regWrite<=regWrite_in;
    MEM_LBU<=LBU_in;
    MEM_ByteSize<=ByteSize_in;
    MEM_Link<=Link_in;
    MEM_SYSCALL<=SYSCALL_in;
    MEM_DestReg<=DestReg_in;
    MEM_WriteHILO_ctrl <= EX_WriteHILO_ctrl;
    MEM_UseHILO_ctrl <= EX_UseHILO_ctrl;
    MEM_HI <= EX_HI;
end
end

initial
begin
    MEM_ALUOut<=32'h0000_0000;
    MEM_RTVAL<=32'h0000_0000;
    MEM_PCp4<=32'h0000_0000;
    MEM_RT<=5'b00000;
    MEM_memToReg<=1'b0;
    MEM_memWrite<=1'b0;
    MEM_regWrite<=1'b0;
    MEM_LBU<=1'b0;
    MEM_ByteSize<=1'b0;
    MEM_Link<=1'b0;
    MEM_SYSCALL<=1'b0;
    MEM_DestReg<=5'b00000;
    MEM_WriteHILO_ctrl <= 1'b0;
    MEM_UseHILO_ctrl <= 1'b0;
    MEM_HI <= 32'b0;
end

endmodule
