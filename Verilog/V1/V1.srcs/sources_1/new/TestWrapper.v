`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2020 10:04:31 AM
// Design Name: 
// Module Name: TestWrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TestWrapper(
    );
    
    reg clk;                // Fake clock

    Top atop(clk);
    
initial
begin
    clk = 0;
end

initial
begin
    #16385 $finish;
end

always
begin
    #1 clk = ~clk; 
end
endmodule
