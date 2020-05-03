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
    output [31:0] RTF,
    input [31:0] MEMValue,
    input [4:0] MEM_Dest,
    input MEM_regWrite,
    input ComputesInDecode
    );
    
    wire RT_MemMatch;
    wire RT_WBMatch;
    assign RT_MemMatch = (ID_RT!=5'b00000) & (ID_RT==MEM_Dest) & MEM_regWrite;
    assign RT_WBMatch = (ID_RT!=5'b00000) & (ID_RT==WB_Dest) & WB_regWrite;
    
    wire RS_MemMatch;
    wire RS_WBMatch;
    assign RS_MemMatch = (ID_RS!=5'b00000) & (ID_RS==MEM_Dest) & MEM_regWrite;
    assign RS_WBMatch = (ID_RS!=5'b00000) & (ID_RS==WB_Dest) & WB_regWrite;
 
    
    assign RTF = ComputesInDecode?(RT_MemMatch?MEMValue:RT_WBMatch?WriteValue:RTVAL)
    :((ID_UseRT|ID_memWrite) & (ID_RT!=5'b00000) & (ID_RT==WB_Dest) & WB_regWrite)?WriteValue:RTVAL;
    assign RSF = ComputesInDecode?(RS_MemMatch?MEMValue:RS_WBMatch?WriteValue:RSVAL)
    :RS_WBMatch?WriteValue:RSVAL;
    
endmodule
