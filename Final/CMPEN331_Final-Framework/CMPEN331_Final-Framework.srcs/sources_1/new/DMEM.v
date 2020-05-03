`timescale 1ns / 1ps

module DCACHE(
    input [31:0] Address,
    input [31:0] SValue,
    output [31:0] RValue,
    output Ready,
    input ReadMem,
    input WriteMem,
    input LBU,
    input ByteOp,
    input clk,
    output DFill,
    output [31:0] DFill_Address,
    input [255:0] Fill_Contents,
    output WriteBack,
    output [31:0] WB_Address,
    output [255:0] WB_Value    
    );
    
    // 2KB 2-way associative LRU cache with 32 byte block size
    // 32 sets of 32 byte blocks, 5 bit index [9:5], 5 bit address for block [4:0]
    // Remainder used for tag size, 32 - 5 - 5 = 22 [31:10]
    // Declare memory
    // Way 0
    reg [0:0] valid0[31:0];
    reg [0:0] dirty0[31:0];
    reg [21:0] tag0[31:0];
    reg [255:0] content0[31:0];
    // Way 1
    reg [0:0] valid1[31:0];
    reg [0:0] dirty1[31:0];
    reg [21:0] tag1[31:0];
    reg [255:0] content1[31:0];
    // MRU cache to show most recent way
    reg [0:0] MRU[31:0];
    reg [255:0] updateContents;

    // Content for tag, block, and offset parsed from Address input
    wire [21:0] tagIn;
    wire [4:0] index;
    wire [4:0] offset;
    assign offset = Address[4:0];
    assign index = Address[9:5];
    assign tagIn = Address[31:10];
    
    wire access;
    assign access = (ReadMem | WriteMem);
    
    // Declare outputs dependant on index
    wire cacheHit;
    wire isValid0;
    wire isValid1;
    wire tagMatch0;
    wire tagMatch1;
    wire [255:0] blockOut0;
    wire [255:0] blockOut1;
    assign blockOut0 = content0[index];
    assign blockOut1 = content1[index];
    assign tagMatch0 = tag0[index] == tagIn;
    assign tagMatch1 = tag1[index] == tagIn;
    assign isValid0 = valid0[index];
    assign isValid1 = valid1[index];
    
    wire way;
    wire [255:0] returnBlock;
    assign way = tagMatch1 & isValid1;
    assign returnBlock = (way)?blockOut1:blockOut0;
    // Verify the hit
    assign cacheHit = ((isValid0 & tagMatch0) | (isValid1 & tagMatch1));
    
    assign DFill = access & ~cacheHit; // fill on a miss when accessed
    assign Ready = access & cacheHit; // ready on a hit when accessed

    // Assign eviction and writeback data using original direction
    wire [21:0] evictionTag;
    wire [255:0] evictionData;
    assign evictionData = (MRU[index])?blockOut0:blockOut1;
    assign evictionTag = (MRU[index])?tag0[index]:tag1[index];
    
    assign DFill_Address = DFill?(Address):32'h0000_0000;
    assign WriteBack = DFill & ((MRU[index])?(valid0[index] & dirty0[index]):(valid1[index] & dirty1[index])); // should only be true if access caused an eviction
    
    assign WB_Address = WriteBack?({evictionTag,index,5'b00000}):32'h0; 
    //assign WB_Value = WriteBack?(evictionData):256'h0;

    wire [15:0] ADDR16;
    assign ADDR16 = Address[15:0];
    wire [7:0] byteValue;
    assign byteValue = SValue[7:0];

    reg [31:0] mergedVal;
    reg [31:0] lwval;
    reg [31:0] lbval;
    reg [31:0] lbuval;
            
     //Should get bits from cache, and only if tag match and valid
    always @ (*) begin
        case (ADDR16[4:2])
        3'b000: lwval = returnBlock[255:224];
        3'b001: lwval = returnBlock[223:192];
        3'b010: lwval = returnBlock[191:160];
        3'b011: lwval = returnBlock[159:128];
        3'b100: lwval = returnBlock[127:96];
        3'b101: lwval = returnBlock[95:64];
        3'b110: lwval = returnBlock[63:32];
        3'b111: lwval = returnBlock[31:0];
        endcase
        case (ADDR16[1:0])
        2'b00: begin
            lbval = {{24{lwval[31]}},lwval[31:24]};
            lbuval = {{24{1'b0}},lwval[31:24]};
        end
        2'b01:begin
            lbval = {{24{lwval[23]}},lwval[23:16]};
            lbuval = {{24{1'b0}},lwval[23:16]};
        end
        2'b10:begin
            lbval = {{24{lwval[15]}},lwval[15:8]};
            lbuval = {{24{1'b0}},lwval[15:8]};
        end
        2'b11:begin
            lbval = {{24{lwval[7]}},lwval[7:0]};
            lbuval = {{24{1'b0}},lwval[7:0]};
        end
        endcase
        mergedVal=lwval;
        if (ByteOp) begin
            case (WB_Address[1:0])
            2'b00: mergedVal={byteValue,lwval[23:0]};
            2'b01: mergedVal={lwval[31:24],byteValue,lwval[15:0]};
            2'b10: mergedVal={lwval[31:16],byteValue,lwval[7:0]};
            2'b11: mergedVal={lwval[31:8],byteValue};
            endcase
        end else begin
            mergedVal=SValue;
        end
    end
    
    wire [31:0] readValue;
    assign readValue = ByteOp?(LBU?lbuval:lbval):lwval;
    assign RValue = ReadMem?readValue:32'h0000_0000;
    
    always @(posedge clk) begin
    // update cache contents, metadata
        if (DFill) begin
            MRU[index]<=~MRU[index];
            // Most recently used becomes filled
            if (~MRU[index]) begin
                valid1[index] <= 1'b1;
                dirty1[index] <= 1'b0;
                tag1[index] <= tagIn;
                content1[index] <= Fill_Contents;
            end else begin
                valid0[index] <= 1'b1;
                dirty0[index] <= 1'b0;
                tag0[index] <= tagIn;
                content0[index] <= Fill_Contents;
            end
        end else begin
            if (cacheHit & WriteMem) begin
                case (WB_Address[4:2])
                3'b000: updateContents = {mergedVal,returnBlock[223:0]};
                3'b001: updateContents = {returnBlock[255:224],mergedVal,returnBlock[191:0]};
                3'b010: updateContents = {returnBlock[255:192],mergedVal,returnBlock[159:0]};
                3'b011: updateContents = {returnBlock[255:160],mergedVal,returnBlock[127:0]};
                3'b100: updateContents = {returnBlock[255:128],mergedVal,returnBlock[95:0]};
                3'b101: updateContents = {returnBlock[255:96],mergedVal,returnBlock[63:0]};
                3'b110: updateContents = {returnBlock[255:64],mergedVal,returnBlock[31:0]};
                3'b111: updateContents = {returnBlock[255:32],mergedVal};
                endcase
                MRU[index] <= way;
                if (way) begin
                    dirty1[index] = 1'b1;
                    content1[index] = updateContents;
                end else begin
                    dirty0[index] = 1'b1;
                    content0[index] = updateContents;
                end
            end
            
            if (cacheHit & ReadMem) begin
                MRU[index] <= way;
            end
        end
    end
    
    integer i;
    initial begin
        // set metadata to invalid, initialize MRU bits
        for (i=0; i<32; i=i+1) begin
            MRU[i]=1'b0;
            valid0[i]=1'b0;
            valid1[i]=1'b0;
        end
    end  
endmodule
