`timescale 1ns / 1ps

module HazardDetection(
    input [4:0] ID_RS,
    input [4:0] ID_RT,
    input ID_UseRT,
    input ID_memWrite,
    input [4:0] EX_Dest,
    input EX_regWrite,
    input EX_memToReg,
    input [4:0] MEM_Dest,
    input MEM_memToReg,
    input ID_isBranch,
    input ID_isJR,
    output HazardDetected
    );
    
    reg RSHazardDetected;
    reg RTHazardDetected;
    
    assign HazardDetected = RSHazardDetected | RTHazardDetected;
    
    always @ (*)
    begin
    RSHazardDetected=1'b0;
    RTHazardDetected=1'b0;
    if(ID_isBranch | ID_isJR) // needs operands immediately
        begin
        RSHazardDetected=(ID_RS!=5'b00000)&((ID_RS==EX_Dest)&EX_regWrite) | ((ID_RS==MEM_Dest) & MEM_memToReg); // stall on ALU in E or LW in E/M
        RTHazardDetected=ID_isBranch & (ID_RT!=5'b00000)&(((ID_RT==EX_Dest)&EX_regWrite) | ((ID_RT==MEM_Dest) & MEM_memToReg)); // stall on ALU in E or LW in E/M
        end
    else if(ID_memWrite) // SW in ID
        begin
        RTHazardDetected=(ID_RT!=5'b00000)&((ID_RT==EX_Dest)&EX_memToReg); // stall on LW in E, RT field only - can forward RS
        end
    else // ALU op or non-register op
        begin
        RSHazardDetected=(ID_RS!=5'b00000)&((ID_RS==EX_Dest)&EX_memToReg); // stall on LW in E
        RTHazardDetected=ID_UseRT & (ID_RT!=5'b00000)&((ID_RT==EX_Dest)&EX_memToReg); // stall on LW in E if using RT, not imm        
        end
    end
endmodule
