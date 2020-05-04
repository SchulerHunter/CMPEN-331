`timescale 1ns / 1ps

module BHT(
    input clk,
    input [31:0] PC,
    output Prediction,
    input DoUpdate,
    input [31:0] UpdatePC,
    input UpdateDirection
    );
    // 2K entry array of 2-bit saturating counters
    // Declare actual memory contents
    reg [1:0] hTable [2047:0];

    // Use log2(2K)=(11) bits of PC for index
    wire [10:0] index;
    wire [10:0] updateIndex;
    assign index = PC[12:2];
    assign updateIndex = UpdatePC[12:2];
        
    // Prediction should be upper bit of PC-associated hTable
    wire [1:0] initialPrediction;
    assign Prediction = hTable[index][1];
    assign initialPrediction = hTable[updateIndex];
    
    // Possible states map as N:00, n:01, t:10, and T:11
    always @(posedge clk) begin
        if (DoUpdate) begin
            if (UpdateDirection) begin
                if (initialPrediction == 2'b11) begin
                    // Stay 3
                    hTable[updateIndex] <= 2'b11;
                end else begin
                    // Increment
                    hTable[updateIndex] <= initialPrediction + 1;
                end
            end else begin
                if (initialPrediction == 2'b00) begin
                    // Stay 0
                    hTable[updateIndex] <= 2'b00;
                end else begin
                    // Decrement
                    hTable[updateIndex] <= initialPrediction - 1;
                end
            end
        end
    end

    integer i;
    initial begin
        // Initialize memeory to weakly taken
        for(i = 0; i < 2048; i=i+1) hTable[i] <= 2'b10;
    end
endmodule