`timescale 1ns / 1ps


module ID_EX_PR(
    input clk,
    input en,
    input memToReg_in,
    output reg memToReg_out,
    input memWrite_in,
    output reg memWrite_out,
    input regWrite_in,
    output reg regWrite_out,
    input LBU_in,
    output reg LBU_out,
    input ByteSize_in,
    output reg ByteSize_out,
    input [3:0] ALUOp_in,
    output reg [3:0] ALUOp_out,
    input Link_in,
    output reg Link_out,
    input SYSCALL_in,
    output reg SYSCALL_out,
    input UseRT_in,
    output reg UseRT_out,
    input [4:0] DestReg_in,
    output reg [4:0] DestReg_out,
    input [31:0] A_in,
    input [31:0] B_in,
    output reg [31:0] A_out,
    output reg [31:0] B_out,
    input [4:0] A_ID_in,
    input [4:0] B_ID_in,
    output reg [4:0] A_ID_out,
    output reg [4:0] B_ID_out,
    input [4:0] SHAMT_in,
    output reg [4:0] SHAMT_out,
    input [31:0] PCp4_in,
    output reg [31:0] EX_PCp4,
    input [31:0] RTVAL,
    output reg [31:0] EX_RTVAL
    );
    
    always @ (posedge clk)
    begin
    if(en)
        begin
        memToReg_out<=memToReg_in;
        memWrite_out<=memWrite_in;
        regWrite_out<=regWrite_in;
        LBU_out<=LBU_in;
        ByteSize_out<=ByteSize_in;
        ALUOp_out<=ALUOp_in;
        Link_out<=Link_in;
        SYSCALL_out<=SYSCALL_in;
        UseRT_out<=UseRT_in;
        DestReg_out<=DestReg_in;
        A_out<=A_in;
        B_out<=B_in;
        A_ID_out<=A_ID_in;
        B_ID_out<=B_ID_in;
        SHAMT_out<=SHAMT_in;
        EX_PCp4 <= PCp4_in;
        EX_RTVAL<= RTVAL;
        end
    end

initial
    begin
        memToReg_out<=1'b0;
        memWrite_out<=1'b0;
        regWrite_out<=1'b0;
        LBU_out<=1'b0;
        ByteSize_out<=1'b0;
        ALUOp_out<=4'b1000;
        Link_out<=1'b0;
        SYSCALL_out<=1'b0;
        UseRT_out<=1'b1;
        DestReg_out<=5'b00000;
        A_out<=32'h0000_0000;
        B_out<=32'h0000_0000;
        A_ID_out<=5'b00000;
        B_ID_out<=5'b00000;
        SHAMT_out<=5'b00000;
        EX_PCp4<=32'h0000_0000;
        EX_RTVAL<=32'h0000_0000;
    end

endmodule
