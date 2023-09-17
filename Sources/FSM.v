`timescale 1ns / 1ps

module FSM(
    input clk,
    input continue,
    input pause,
    input esc_pause,
    input restart,
    input over,

    output reg choose_en,
    output reg playing_en,
    output reg pause_en,
    output reg over_en
    );
    parameter CHOOSE  = 2'b00;
    parameter PLAYING = 2'b01;
    parameter PAUSE   = 2'b10;
    parameter OVER    = 2'b11;

    //status
    reg [1:0] crt, nxt;
    initial begin
        crt = CHOOSE;
        nxt = CHOOSE;
    end
    always @(posedge clk) begin
        crt <= nxt;
    end

    always @(*)begin
        case(crt)
        CHOOSE: begin
            if(continue) nxt = PLAYING;
            else nxt = CHOOSE;
        end
        PLAYING: begin
            if(pause) nxt = PAUSE;
            else if(over) nxt = OVER;
            else nxt = PLAYING;
        end
        PAUSE: begin
            if(esc_pause) nxt = PLAYING;
            else nxt = PAUSE;
        end
        OVER: begin
            if(restart) nxt = CHOOSE;
            else nxt = OVER;
        end
        default nxt = OVER;
        endcase
    end

    always @(*) begin
        case(crt)
        CHOOSE: begin
            choose_en <= 1;
            playing_en <= 0;
            pause_en <= 0;
            over_en <= 0;
        end
        PLAYING: begin
            choose_en <= 0;
            playing_en <= 1;
            pause_en <= 0;
            over_en <= 0;
        end
        PAUSE: begin
            choose_en <= 0;
            playing_en <= 0;
            pause_en <= 1;
            over_en <= 0;
        end
        OVER: begin
            choose_en <= 0;
            playing_en <= 0;
            pause_en <= 0;
            over_en <= 1;
        end
        endcase
    end
endmodule
