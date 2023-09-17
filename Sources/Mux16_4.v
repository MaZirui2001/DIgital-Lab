`timescale 1ns / 1ps

module Mux32_4(
    input [31:0] din,
    input [2:0] sel,
    output reg [3:0] dout
    );
    always @(*) begin
        case(sel)
        3'b000: dout = din[3:0];
        3'b001: dout = din[7:4];
        3'b010: dout = din[11:8];
        3'b011: dout = din[15:12];
        3'b100: dout = din[19:16];
        3'b101: dout = din[23:20];
        3'b110: dout = din[27:24];
        3'b111: dout = din[31:28];
        endcase
    end
endmodule
