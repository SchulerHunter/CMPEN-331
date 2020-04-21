`timescale 1ns / 1ps

module IMEM(
    input [31:0] Address,
    input clk,
    output [31:0] InstBits,
    output Ready
    );
    
    wire [15:0] ADDR16;
    assign ADDR16 = Address[15:0];
    
    reg [7:0] IMEMCONTENTS [65535:0];
    reg [0:0] IMEMPRESENCE [65535:0];
    wire [15:0] IADDR16_00; 
    assign IADDR16_00 = {Address[15:2],2'b00};
    wire [15:0] IADDR16_01; 
    assign IADDR16_01 = {Address[15:2],2'b01};
    wire [15:0] IADDR16_10; 
    assign IADDR16_10 = {Address[15:2],2'b10};
    wire [15:0] IADDR16_11; 
    assign IADDR16_11 = {Address[15:2],2'b11};
    
    assign InstBits = {IMEMCONTENTS[IADDR16_00],IMEMCONTENTS[IADDR16_01],IMEMCONTENTS[IADDR16_10],IMEMCONTENTS[IADDR16_11]};

    assign Ready = IMEMPRESENCE[IADDR16_00];

    always @ (posedge clk)
        IMEMPRESENCE[IADDR16_00] <= 1'b1;

integer i;    
initial
begin
    $readmemh("mem.mem",IMEMCONTENTS);
    for (i=0; i<65536; i=i+1) IMEMPRESENCE[i]=1'b0;
end    
endmodule
