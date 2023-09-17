`timescale 1ns / 1ps

module WriteColor(
    input clk, en,
    input [11:0] body_color,
    input [11:0] head_color,
    input choose_DBn,
    input rechoose_DBn,
    input nxtcolor_DBn,
    
    output reg [2:0] addr,
    output reg [11:0] body_A,
    output reg [11:0] head_A,
    output reg [11:0] body_B,
    output reg [11:0] head_B,
    output reg continue
    );
    DBPS choose_(clk, choose_DBn, choose);
    DBPS rechoose_(clk, rechoose_DBn, rechoose);
    DBPS nxtcolor_(clk, nxtcolor_DBn, nxtcolor);


    parameter IDLE = 3'b000;
    parameter COLORA = 3'b001;
    parameter COLORB = 3'b010;
    parameter READY = 3'b011;
    parameter CHO_OVER = 3'b100;

    reg[2:0] crt, nxt;
    initial begin
        crt = 0;
        nxt = 0;
        continue = 0;
        addr = 0;
    end
    always @(posedge clk)begin
        crt <= nxt;
    end

    reg s1, s2, s3;
    wire en_PS;
    initial begin 
        s1 = 0; 
        s2 = 0; 
        s3 = 0; 
    end
    always@(posedge clk)begin
        s1 <= en;
        s2 <= s1;
        s3 <= s2;
    end
    assign en_PS = s2 & (~s3);
    //Here it can be solved by a counter, but I want to make it more clear
    always @(*)begin
        case(crt)
        IDLE: begin
            if(en_PS) nxt = COLORA;
            else nxt = IDLE;
        end
        COLORA: begin
            if(choose) nxt = COLORB;
            else nxt = COLORA;
        end
        COLORB: begin
            if(choose) nxt = READY;
            else if(rechoose) nxt = COLORA;
            else nxt = COLORB;
        end
        READY: begin
            if(choose) nxt = CHO_OVER;
            else if(rechoose) nxt = COLORB;
            else nxt = READY;
        end
        default nxt = IDLE;
        endcase
    end

    reg [2:0] colora;
    always @(posedge clk) begin
        case(crt)
        IDLE: begin
            continue <= 0;
            addr <= 0;
        end
        COLORA: begin
            if(nxtcolor) addr <= addr + 1;
            colora <= addr;
            body_A <= body_color;
            head_A <= head_color;
            body_B <= 0;
            head_B <= 0;
        end
        COLORB:begin
            if(addr == colora || nxtcolor) addr <= addr + 1;
            body_B <= body_color;
            head_B <= head_color;
        end
        CHO_OVER: begin
            continue <= 1;
        end
        endcase
    end
endmodule