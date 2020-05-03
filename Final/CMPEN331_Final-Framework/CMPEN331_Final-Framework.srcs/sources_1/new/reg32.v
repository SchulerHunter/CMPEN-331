`timescale 1ns / 1ps

module PC32(
    input [31:0] in,
    output [31:0] out,
    input en,
    input reset,
    input clk
    );
    reg [31:0] Value[0:0];
    assign out = Value[0];
    always @( posedge clk)
    begin
        if (reset)
            Value[0] <= 32'h00000000;
        else
            if (en)
                Value[0] <= in;
            else
                Value[0] <= Value[0];
    end
    
    initial
    begin
        $readmemh("pc.mem",Value);
    end
    
endmodule

module R32(
    input [31:0] in,
    output [31:0] out,
    input en,
    input reset,
    input clk
    );
    reg [31:0] Value[0:0];
    assign out = Value[0];
    always @( posedge clk)
    begin
        if (reset)
            Value[0] <= 32'h00000000;
        else
            if (en)
                Value[0] <= in;
            else
                Value[0] <= Value[0];
    end
    
    initial
    begin
        Value[0] <= 32'h00000000;
    end
    
endmodule