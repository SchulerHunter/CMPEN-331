`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2020 04:10:56 PM
// Design Name: 
// Module Name: SZExtender
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SZExtender(
    input [15:0] IMM16,
    input SZ,
    output [31:0] EXT32
    );
    assign EXT32 = (SZ)?{{16{IMM16[15]}},IMM16}:{{16{1'b0}},IMM16};
endmodule
