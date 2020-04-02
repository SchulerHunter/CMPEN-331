`timescale 1ns / 1ps

module REGFILE(
    input [4:0] RP1,
    input [4:0] RP2,
    input [4:0] WP1,
    input [31:0] WriteData,
    input WriteEnable,
    output [31:0] RPOut1,
    output [31:0] RPOut2,
    input clk
    );
    reg [31:0] GPR [31:0];
    
    wire isZeroRP1;
    wire isZeroRP2;
    assign isZeroRP1 = RP1 == 5'b00000; 
    assign isZeroRP2 = RP2 == 5'b00000;
    assign RPOut1 = isZeroRP1?32'h00000000:GPR[RP1];
    assign RPOut2 = isZeroRP2?32'h00000000:GPR[RP2];    
    
    always @ (posedge clk)
    begin
        if (WriteEnable)
            GPR[WP1] <= WriteData;
    end
    
    initial
    begin
        $readmemh("reg.mem",GPR);
    end
    
endmodule
