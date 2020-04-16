`timescale 1ns / 1ps

module ALU(
    input [31:0] ALUPortA,
    input [31:0] ALUPortB,
    input [3:0] OpSelect,
    input [4:0] ALUSHAMT,
    output reg [31:0] ALUOut,
    output CarryOut,
    output Overflow
    );
    assign CarryOut = 1'b0; // FIXME LATER
    assign Overflow = 1'b0; // FIXME LATER
    wire signed [31:0] ALUPortBSigned;
    wire signed [31:0] ALUPortASigned;
    assign ALUPortBSigned=ALUPortB;
    assign ALUPortASigned=ALUPortA;
    
    always @(*)
    begin
    case (OpSelect)
    0: ALUOut = ALUPortA + ALUPortB;
    1: ALUOut = ALUPortA - ALUPortB;
    2: ALUOut = ALUPortA & ALUPortB;
    3: ALUOut = ALUPortA | ALUPortB;
    4: ALUOut = ~(ALUPortA | ALUPortB);
    5: ALUOut = ALUPortA ^ ALUPortB;
    6: ALUOut = ALUPortASigned < ALUPortBSigned;
    7: ALUOut = {1'b0,ALUPortA} < {1'b0,ALUPortB};
    8: ALUOut = ALUPortB << ALUSHAMT;
    9: ALUOut = ALUPortB >> ALUSHAMT;
    10: ALUOut = ALUPortBSigned >>> ALUSHAMT;
    11: ALUOut = ALUPortB << 16;
    12: ALUOut = 32'h00000000; // MUL NOT IMPLEMENTED
    13: ALUOut = 32'h00000000; // DIV NOT IMPLEMENTED
    14: ALUOut = 32'h00000000; // MULU NOT IMPLEMENTED;
    15: ALUOut = 32'h00000000; // DIVU NOT IMPLEMENTED;
    endcase
    end
    
endmodule
