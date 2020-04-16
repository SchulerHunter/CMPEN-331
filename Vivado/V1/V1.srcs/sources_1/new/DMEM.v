`timescale 1ns / 1ps

module DMEM(
    input [31:0] Address,
    input [31:0] SValue,
    output [31:0] RValue,
    output Ready,
    input ReadMem,
    input WriteMem,
    input LBU,
    input ByteOp,
    input clk
    );

    wire [15:0] ADDR16;
    assign ADDR16=Address[15:0];
    reg [7:0] DMEMCONTENTS [65535:0];
    reg [0:0] DMEMPRESENCE [65535:0];
    wire [15:0] DADDR16_00; 
    assign DADDR16_00 = {Address[15:2],2'b00};
    wire [15:0] DADDR16_01; 
    assign DADDR16_01 = {Address[15:2],2'b01};
    wire [15:0] DADDR16_10; 
    assign DADDR16_10 = {Address[15:2],2'b10};
    wire [15:0] DADDR16_11; 
    assign DADDR16_11 = {Address[15:2],2'b11};
    
    wire [31:0] lwval;
    wire [31:0] lbval;
    wire [31:0] lbuval;
    wire [7:0] byteValue;
    assign byteValue = SValue[7:0];
    
    assign lwval = {DMEMCONTENTS[DADDR16_00],DMEMCONTENTS[DADDR16_01],DMEMCONTENTS[DADDR16_10],DMEMCONTENTS[DADDR16_11]};
    assign lbval = {{24{DMEMCONTENTS[ADDR16][7]}},DMEMCONTENTS[ADDR16]};
    assign lbuval = {{24{1'b0}},DMEMCONTENTS[ADDR16]};
    wire [31:0] readValue;
    assign readValue = ByteOp?LBU?lbuval:lbval:lwval;
    assign RValue = ReadMem?readValue:32'h00000000;

    assign Ready = (ReadMem|WriteMem)?DMEMPRESENCE[DADDR16_00]:1'b0;
    
    always@(posedge clk)
    begin
    if (WriteMem | ReadMem)
        DMEMPRESENCE[DADDR16_00] <= 1'b1;

    if (WriteMem)
        begin
            if (ByteOp)
            begin
                DMEMCONTENTS[ADDR16]<=byteValue;
            end
            else
            begin
                DMEMCONTENTS[DADDR16_00]<=SValue[31:24];
                DMEMCONTENTS[DADDR16_01]<=SValue[23:16];
                DMEMCONTENTS[DADDR16_10]<=SValue[15:8];
                DMEMCONTENTS[DADDR16_11]<=SValue[7:0];
            end
        end
    end

integer i; 
initial
begin
    $readmemh("mem.mem",DMEMCONTENTS);
    for(i=0;i<65536;i=i+1) DMEMPRESENCE[i]=1'b0;
end  
endmodule
