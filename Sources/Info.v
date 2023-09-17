`timescale 1ns / 1ps
module Info#(
    parameter HEADAX = 14,
    parameter HEADAY = 30,
    parameter BODYAX = 14,
    parameter BODYAY = 33,
    parameter HEADBX = 35,
    parameter HEADBY = 30,
    parameter BODYBX = 35,
    parameter BODYBY = 33,
    parameter HEADWID = 4,
    parameter HEADHEIGHT = 4,
    parameter BODYWID = 4,
    parameter BODYHEIGHT = 24,

    parameter POINTERX = 3,
    parameter POINTER1Y = 10,
    parameter POINTER2Y = 63,
    parameter POINTER3Y = 122,
    parameter POINTER4Y = 139,

    parameter WINNERAX = 6,
    parameter WINNERBX = 27,
    parameter WINNERY = 24,

    parameter FOODX = 9,
    parameter FOODY = 73,
    parameter TIMEX = 6,
    parameter TIMEY = 110
)(
    input [7:0] x,
    input [7:0] y,
    input [11:0] head_A, body_A,
    input [11:0] head_B, body_B,
    input [11:0] rdata,
    input [5:0] foodnum,
    input [2:0] food_time_left,
    input [3:0] state,
    input [1:0] vict,

    output reg [11:0] pdata

    );
    integer i, j;
    integer k;
    always @(*) begin
        //snake
        if(x > HEADAX && x < HEADAX + HEADWID && y > HEADAY && y < HEADAY + HEADHEIGHT) pdata = head_A;
        else if(x > BODYAX && x < BODYAX + BODYWID && y > BODYAY && y < BODYAY + BODYHEIGHT) pdata = body_A;
        else if(x > HEADBX && x < HEADBX + HEADWID && y > HEADBY && y < HEADBY + HEADHEIGHT) pdata = head_B;
        else if(x > BODYBX && x < BODYBX + BODYWID && y > BODYBY && y < BODYBY + BODYHEIGHT) pdata = body_B;
        else if(x == POINTERX && y > POINTER1Y - 3 && y < POINTER1Y + 3 || 
                x == POINTERX + 1 && y > POINTER1Y - 2 && y < POINTER1Y + 2 ||
                x == POINTERX + 2 && y == POINTER1Y) begin
                    if(state[0]) pdata = 12'hFFF;
                    else pdata = 0;
                end

        else if(x == POINTERX && y > POINTER2Y - 3 && y < POINTER2Y + 3 || 
                x == POINTERX + 1 && y > POINTER2Y - 2 && y < POINTER2Y + 2 ||
                x == POINTERX + 2 && y == POINTER2Y) begin
                    if(state[1]) pdata = 12'hFFF;
                    else pdata = 0;
                end
        else if(x == POINTERX && y > POINTER3Y - 3 && y < POINTER3Y + 3 || 
                x == POINTERX + 1 && y > POINTER3Y - 2 && y < POINTER3Y + 2 ||
                x == POINTERX + 2 && y == POINTER3Y) begin
                    if(state[2]) pdata = 12'hFFF;
                    else pdata = 0;
                end
        else if(x == POINTERX && y > POINTER4Y - 3 && y < POINTER4Y + 3 || 
                x == POINTERX + 1 && y > POINTER4Y - 2 && y < POINTER4Y + 2 ||
                x == POINTERX + 2 && y == POINTER4Y) begin
                    if(state[3]) pdata = 12'hFFF;
                    else pdata = 0;
                end

        //victory
        else if(x == WINNERAX && y > WINNERY - 3 && y < WINNERY + 3 ||
                x == WINNERAX + 1 && y > WINNERY - 2 && y < WINNERY + 2 ||
                x == WINNERAX + 2 && y == WINNERY)begin
                    if(vict[1]) pdata = 12'h00F;
                    else pdata = 0;
                end
        else if(x == WINNERBX && y > WINNERY - 3 && y < WINNERY + 3 ||
                x == WINNERBX + 1 && y > WINNERY - 2 && y < WINNERY + 2 ||
                x == WINNERBX + 2 && y == WINNERY)begin
                    if(vict[0]) pdata = 12'h00F;
                    else pdata = 0;
                end
        else pdata = rdata;
        
        //foodnum
        for(i = 0; i < 6; i = i + 1) begin
            for(j = 0; j < 6; j = j + 1)begin
                if(x >= FOODX + 6 * j && x < FOODX + 6 * j + 3 && 
                   y >= FOODY + 6 * i && y < FOODY + 6 * i + 3)begin
                    if(i * 6 + j < 36 - foodnum) begin
                        pdata = 12'h0;
                    end
                    else begin
                        if((i * 6 + j + 1) % 4 == 0) pdata = 12'h00E;
                        else pdata = 12'h48F;
                    end
                end
            end
        end
        //food time left
        for(k = 0; k < 42; k = k + 6)begin  
            if(x >= TIMEX + k && x < TIMEX + k + 3 && y >= TIMEY && y < TIMEY + 3)begin
                if(k < 6 * (7 - food_time_left)) pdata = 12'h0;
                else pdata = 12'h00E;
            end
        end
    end
endmodule
