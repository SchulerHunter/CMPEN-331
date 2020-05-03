`timescale 1ns / 1ps

module ICACHE(
    input [31:0] Address,
    input clk,
    output reg [31:0] InstBits,
    output Ready,
    output IFill,
    output [31:0] IFill_Address,
    input [511:0] Fill_Contents
    );
    // Actual cache content
    reg [0:0] valid[31:0];
    // 32 bit address - 5 bit index - 6 bit offset = 21 bits of tag
    reg [20:0] tag[31:0];
    reg [511:0] cacheContent[31:0];
    
    // Content for tag, block, and offset parsed from Address input
    wire [20:0] tagIn;
    wire [4:0] index;
    wire [5:0] offset;
    assign offset = Address[5:0];
    assign index = Address[10:6];
    assign tagIn = Address[31:11];
    
    // Declare outputs dependant on index
    wire cacheHit;
    wire isValid;
    wire [20:0] tagOut;
    wire [511:0] blockOut;
    assign isValid = valid[index];
    assign tagOut = tag[index];
    assign blockOut = cacheContent[index];
    
    // Verify the hit
    assign cacheHit = (tagIn == tagOut) & isValid;
    
    assign IFill = ~cacheHit; // Always ask main memory for data - FIX THIS, should be !Ready
    assign Ready = cacheHit; // Always ready - FIX THIS, should be 
    
    assign IFill_Address = (IFill)?Address:32'h0000_0000;
    
    wire [15:0] ADDR16;
    assign ADDR16 = Address[15:0];
        
    //Should get bits from cache, and only if tag match and valid
    always @(*) begin
        case (ADDR16[5:2])
        4'b0000: InstBits = blockOut[511:480];
        4'b0001: InstBits = blockOut[479:448];
        4'b0010: InstBits = blockOut[447:416];
        4'b0011: InstBits = blockOut[415:384];
        4'b0100: InstBits = blockOut[383:352];
        4'b0101: InstBits = blockOut[351:320];
        4'b0110: InstBits = blockOut[319:288];
        4'b0111: InstBits = blockOut[287:256];
        4'b1000: InstBits = blockOut[255:224];
        4'b1001: InstBits = blockOut[223:192];
        4'b1010: InstBits = blockOut[191:160];
        4'b1011: InstBits = blockOut[159:128];
        4'b1100: InstBits = blockOut[127:96];
        4'b1101: InstBits = blockOut[95:64];
        4'b1110: InstBits = blockOut[63:32];
        4'b1111: InstBits = blockOut[31:0];
        endcase
        // If a cache miss occurs, zero the garbage data
        if (IFill) begin
            InstBits = 32'h0000_0000;
        end
    end
    
    always @(posedge clk) begin
        // write the fill data into the cache if filling. Also update metadata
        if (IFill) begin
            valid[index] <= 1'b1;
            tag[index] <= tagIn;
            cacheContent[index] <= Fill_Contents;
        end
    end
    
    integer i;
    initial begin
        // set all cache blocks to invalid
        for (i = 0; i < 32; i = i+1) valid[i]=1'b0;
    end
endmodule
