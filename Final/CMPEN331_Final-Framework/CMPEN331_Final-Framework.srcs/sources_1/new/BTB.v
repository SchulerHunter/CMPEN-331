module BTB(
    input clk,
    input [31:0] accessPC,
    output [31:0] outInstBits,
    output [31:0] targetPC,
    output btbHit,
    output btbType,
    input update_ctrl,
    input [31:0] updatePC,
    input [31:0] updateInstBits,
    input [31:0] updateTargetPC
    );
    // Actual cache content
    reg [0:0] valid[31:0];
    reg [26:0] tag[31:0];
    reg [31:0] iContent[31:0];
    reg [31:0] iAddress[31:0];
    reg [0:0] isJump[31:0];
    
    // Determine index and tag
    wire [4:0] index;
    wire [26:0] tagIn;
    wire [4:0] updateIndex;
    wire [26:0] updateTag;
    assign index = accessPC[6:2];
    assign tagIn = accessPC[31:5];
    assign updateIndex = updatePC[6:2];
    assign updateTag = updatePC[31:5];
    
    // Assign outputs
    assign btbHit = valid[index] & (tagIn == tag[index]);
    assign outInstBits = (btbHit)?iContent[index]:32'b0;
    assign targetPC = (btbHit)?iAddress[index]:32'b0;
    assign btbType = (btbHit)?isJump[index]:1'b0;
    
    always @(posedge clk) begin
        if (update_ctrl) begin
            valid[updateIndex] <= 1'b1;
            tag[updateIndex] <= updateTag;
            iContent[updateIndex] <= updateInstBits;
            iAddress[updateIndex] <= updateTargetPC;
            // check if J (Opcode = 2) or JAL (Opcode = 3)
            isJump[updateIndex] <= (updateInstBits[5:0] == 6'd2 | updateInstBits[5:0] == 6'd3);
        end
    end
    
    integer i;
    initial begin
        for (i=0; i<32; i=i+1) valid[i] <=1'b0;
    end
endmodule