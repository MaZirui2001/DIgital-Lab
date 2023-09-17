`timescale 1ns / 1ps

module ColorFile(
    input clk,
    input [2:0] addr,

    output reg[11:0] body_color,
    output reg[11:0] head_color
    );
    reg [23:0] colorfile [7:0];   //[23:12]body, [11:0]head
    initial begin
        colorfile[0] = 24'h00F448;//RED
        colorfile[1] = 24'h0FF06F;//YELOOW
        colorfile[2] = 24'hFF0F80;//BLUE
        colorfile[3] = 24'h4F0080;//GERRN
        colorfile[4] = 24'hC8FF0F;//PINK
        colorfile[5] = 24'h088048;//BROWN
        colorfile[6] = 24'h808408;//PURPUL
        colorfile[7] = 24'h88F008;//INCARNADINE
    end
    always @(*)begin
        body_color = colorfile[addr][23:12];
        head_color = colorfile[addr][11:0];
    end
endmodule