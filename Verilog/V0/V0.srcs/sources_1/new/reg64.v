`timescale 1ns / 1ps

module HILO64(
    input [63:0] in,
    output [63:0] out,
    input en,
    input reset,
    input clk
    );
    reg [63:0] Value[0:0];
    assign out = Value[0];
    always @( posedge clk)
    begin
        if (reset)
            Value[0] <= 64'h00000000_00000000;
        else
            if (en)
                Value[0] <= in;
            else
                Value[0] <= Value[0];
    end
    
    initial
    begin
        $readmemh("hilo.mem",Value);
    end
    
endmodule