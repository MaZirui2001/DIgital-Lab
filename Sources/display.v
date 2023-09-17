`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/15 20:41:31
// Design Name: 
// Module Name: display
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


module display(
    input pclk,
    input [11:0] head_A, body_A, head_B, body_B,
    input game_board_data,
    input [15:0] snake_data,
    input [2:0] food_time,
    input [5:0] food_count,
    input [3:0] state,
    input [1:0] winner,
    input [31:0] len_a, len_b,
    output [12:0] raddr1, raddr2,
    output [11:0] rgb,
    output hs, vs,
    output [7:0] an,
    output [6:0] c
);
    reg [11:0] pdata;
    wire [10:0] hcount, htemp;
    wire [9:0] vcount;
    VSD VSD(
        pclk,
        pdata, hcount, vcount,
        rgb, hs, vs
    );

    assign htemp = hcount - 1;
    assign raddr1 = hcount[9:2] + { vcount[9:2], 5'b00000 } + 
        { vcount[9:2], 4'b0000 } + { vcount[9:2], 1'b0 };
    assign raddr2 = hcount[9:3] - 25 + 
        { vcount[9:3], 6'b000000 } + { vcount[9:3], 3'b000 } + 
        { vcount[9:3], 1'b0 } + vcount[9:3];

    reg [11:0] rdata;
    wire [11:0] gdata;
    always @( * ) begin
        if ( game_board_data ) rdata = 12'hFFF;
        else rdata = 12'h000;
    end

    Info Info(
        htemp[9:2], vcount[9:2],
        head_A, body_A,
        head_B, body_B,
        rdata,
        food_count, food_time, state, winner,
        gdata
    );

    always @( * ) begin
        if ( htemp < 200 ) begin
            if ( gdata == rdata ) pdata = rdata;
            else pdata = gdata;
        end
        else pdata = snake_data[15:4];
    end

    DIS LEN(pclk, {len_a, len_b}, an, c);

endmodule
