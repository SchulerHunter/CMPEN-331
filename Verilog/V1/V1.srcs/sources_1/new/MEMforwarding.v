`timescale 1ns / 1ps


module MEMForwarding(
    input [4:0] MEM_RT,
    input MEM_memWrite,
    input [31:0] WriteValue,
    input [4:0] WB_Dest,
    input WB_regWrite,
    input [31:0] SWVAL,
    output [31:0] SWVALF
    );
    
    assign SWVALF = (MEM_memWrite & (MEM_RT!=5'b00000) & (MEM_RT==WB_Dest) & WB_regWrite)?WriteValue:SWVAL;

endmodule
