`timescale 1ns / 1ps
module MEM_WB_PR(
    input clk,
    input en,
    input [31:0] ALUOut_in,
    input [31:0] MemOut_in,
    input [31:0] PCp4_in,
    input memToReg_in,
    input Link_in,
    input RegWrite_in,
    input SYSCALL_in,
    input [4:0] RegWriteDest_in,
    output reg [31:0] WB_ALUout,
    output reg [31:0] WB_MemOut,
    output reg [31:0] WB_PCp4,
    output reg WB_memToReg_ctrl,
    output reg WB_Link_ctrl,
    output reg WB_RegWrite_ctrl,
    output reg WB_SYSCALL_ctrl,
    output reg [4:0] WB_RegWriteDest
    );

always @ (posedge clk)
begin
if(en)
begin
    WB_ALUout<=ALUOut_in;
    WB_MemOut<=MemOut_in;
    WB_PCp4<=PCp4_in;
    WB_memToReg_ctrl<=memToReg_in;
    WB_Link_ctrl<=Link_in;
    WB_RegWrite_ctrl<=RegWrite_in;
    WB_SYSCALL_ctrl<=SYSCALL_in;
    WB_RegWriteDest<=RegWriteDest_in;
end
end

initial
begin
    WB_ALUout<=32'h0000_0000;
    WB_MemOut<=32'h0000_0000;
    WB_PCp4<=32'h0000_0000;
    WB_memToReg_ctrl<=1'b0;
    WB_Link_ctrl<=1'b0;
    WB_RegWrite_ctrl<=1'b0;
    WB_SYSCALL_ctrl<=1'b0;
    WB_RegWriteDest<=5'b00000;
end

endmodule
