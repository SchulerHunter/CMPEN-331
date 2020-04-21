`timescale 1ns / 1ps

module ScaledAdder(
    input [31:0] Unscaled,
    input [31:0] Scaled,
    output [31:0] Out
    );
    assign Out = Unscaled + {Scaled[29:0],2'b00};
endmodule