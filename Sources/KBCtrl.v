`timescale 1ns / 1ps

module KBCtrl(
    input [7:0] din,
    output reg [3:0] dir1, dir2,
    output reg choose, rechoose, nxtcolor,
    output reg restart, pause, esc_pause
    );
    parameter W = 8'h1D;
    parameter A = 8'h1C;
    parameter S = 8'h1B;
    parameter D = 8'h23;

    parameter UP = 8'h75;
    parameter DOWN = 8'h72;
    parameter LEFT = 8'h6B;
    parameter RIGHT = 8'h74;

    parameter ENTER = 8'h5A;
    parameter BACK = 8'h66;
    parameter SPACE = 8'h29;
    parameter ESC = 8'h76;
    always @(*) begin
        //initial
        dir1 = 0; dir2 = 0;
        choose = 0; rechoose = 0; nxtcolor = 0;
        restart = 0; pause = 0; esc_pause = 0;

        case(din)
        W: dir1[3] = 1;
        A: dir1[2] = 1;
        S: dir1[1] = 1;
        D: dir1[0] = 1;
        UP:dir2[3] = 1;
        LEFT:dir2[2] = 1;
        DOWN:dir2[1] = 1;
        RIGHT:dir2[0] = 1;

        SPACE: begin
            nxtcolor = 1;
            pause = 1;
        end
        ENTER: begin
            choose = 1;
            esc_pause = 1;
        end
        BACK: rechoose = 1;
        ESC: begin 
            restart = 1;
        end
        endcase
    end
endmodule
