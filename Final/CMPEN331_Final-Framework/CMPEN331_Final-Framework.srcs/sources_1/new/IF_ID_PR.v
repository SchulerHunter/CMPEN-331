`timescale 1ns / 1ps

module IF_ID_PR(
    input clk,
    input [31:0] BeingFetched,
    input [31:0] PCp4,
    output [31:0] WasFetched,
    output [31:0] ID_PCp4,
    input en,
    input [31:0] PC_in,
    output reg [31:0] ID_PC,
    input BTB_known_ctrl,
    output reg ID_known_ctrl,
    input PredictedBranchDirection,
    output reg ID_PredictedBranchDirection
    );
    
    reg [31:0] storedInst;
    reg [31:0] storedPCp4;
    
    assign WasFetched = storedInst;
    assign ID_PCp4 = storedPCp4;
    
    always @ (posedge clk)
    begin
        if (en)
            begin
            storedInst <= BeingFetched;
            storedPCp4 <= PCp4;
            ID_PC <= PC_in;
            ID_known_ctrl <= BTB_known_ctrl;
            ID_PredictedBranchDirection <=PredictedBranchDirection;
            end
    end
    
    initial
    begin
        storedInst <= 32'h0000_0000;
        storedPCp4 <= 32'h0000_0000;
        ID_PC <= 32'h0000_0000;
        ID_known_ctrl <= 1'b0;
        ID_PredictedBranchDirection <=1'b0;
    end
endmodule
