`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/13 20:22:22
// Design Name: 
// Module Name: dirc_helper
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


module dirc_updater(
    input [1:0] dirc,
    input [6:0] x, y,
    output reg [6:0] update_x, update_y
);
    always @( * ) begin
        case ( dirc )
            2'b00: begin
                if ( x == 0 ) update_x = 74;
                else update_x = x - 1;
                update_y = y;
            end
            2'b01: begin
                if ( x == 74 ) update_x = 0;
                else update_x = x + 1;
                update_y = y;
            end
            2'b10: begin
                update_x = x;
                if ( y == 0 ) update_y = 74;
                else update_y = y - 1;
            end
            2'b11: begin
                update_x = x;
                if ( y == 74 ) update_y = 0;
                else update_y = y + 1;
            end
        endcase
    end
endmodule
