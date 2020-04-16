`timescale 1ns / 1ps


module DecodeForwarding(
    input ID_UseRT,
    input ID_memWrite,
    input [4:0] ID_RS,
    input [4:0] ID_RT,
    input [31:0] WriteValue,
    input [4:0] WB_Dest,
    input WB_regWrite,
    input [31:0] RSVAL,
    input [31:0] RTVAL,
    output [31:0] RSF,
    output [31:0] RTF
    );
    
    assign RTF = ((ID_UseRT|ID_memWrite) & (ID_RT!=5'b00000) & (ID_RT==WB_Dest) & WB_regWrite)?WriteValue:RTVAL;
    assign RSF = ((ID_RS!=5'b00000) & (ID_RS==WB_Dest) & WB_regWrite)?WriteValue:RSVAL;
    
endmodule
