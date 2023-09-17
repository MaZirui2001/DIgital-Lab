`timescale 1ns / 1ps

module Decoder_8(
    input [2:0] din,
    input [7:0]en,
    output reg [7:0] dout
    );
    initial dout = 4'b1110;
    always @(*)begin
        case(din)
        3'b000: dout = 8'b11111110;
        3'b001: if(en[1]) dout = 8'b11111101; else dout = 8'b11111111;
        3'b010: if(en[2]) dout = 8'b11111011; else dout = 8'b11111111;
        3'b011: if(en[3]) dout = 8'b11110111; else dout = 8'b11111111;
        3'b100: dout = 8'b11101111; 
        3'b101: if(en[5]) dout = 8'b11011111; else dout = 8'b11111111;
        3'b110: if(en[6]) dout = 8'b10111111; else dout = 8'b11111111;
        3'b111: if(en[7]) dout = 8'b01111111; else dout = 8'b11111111;
        endcase    
    end
endmodule
