`timescale 1ns / 1ps

module IMEM(
    input [31:0] Address,
    output [31:0] InstBits
    );
    
    reg [7:0] IMEMCONTENTS [65535:0];
    wire [15:0] IADDR16_00; 
    assign IADDR16_00 = {Address[15:2],2'b00};
    wire [15:0] IADDR16_01; 
    assign IADDR16_01 = {Address[15:2],2'b01};
    wire [15:0] IADDR16_10; 
    assign IADDR16_10 = {Address[15:2],2'b10};
    wire [15:0] IADDR16_11; 
    assign IADDR16_11 = {Address[15:2],2'b11};
    
    assign InstBits = {IMEMCONTENTS[IADDR16_00],IMEMCONTENTS[IADDR16_01],IMEMCONTENTS[IADDR16_10],IMEMCONTENTS[IADDR16_11]};
    
initial
begin
    $readmemh("mem.mem",IMEMCONTENTS);
end    
endmodule
