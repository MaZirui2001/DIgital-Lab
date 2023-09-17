`timescale 1ns / 1ps

module Digit_Decoder(
    input  [3:0]din,
    output reg [6:0]dout
    );
    initial dout = 7'b00000001;
    always@(*) begin
        case(din)
            4'b0000: begin dout = 7'b0000001;end//0
            4'b0001: begin dout = 7'b1001111;end//1
            4'b0010: begin dout = 7'b0010010;end//2
            4'b0011: begin dout = 7'b0000110;end//3
            4'b0100: begin dout = 7'b1001100;end//4
            4'b0101: begin dout = 7'b0100100;end//5
            4'b0110: begin dout = 7'b0100000;end//6
            4'b0111: begin dout = 7'b0001111;end//7
            4'b1000: begin dout = 7'b0000000;end//8
            4'b1001: begin dout = 7'b0000100;end//9
            4'b1010: begin dout = 7'b0001000;end//A
            4'b1011: begin dout = 7'b1100000;end//b
            4'b1100: begin dout = 7'b0110001;end//C
            4'b1101: begin dout = 7'b1000010;end//d
            4'b1110: begin dout = 7'b0110000;end//E
            4'b1111: begin dout = 7'b0111000;end//F
        endcase
    end
endmodule
