`timescale 1ns / 1ps


module EQComp(
    input [31:0] RRS,
    input [31:0] RRT,
    output EQ
    );
    assign EQ = RRS==RRT;
endmodule
