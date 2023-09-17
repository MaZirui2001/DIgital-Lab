`timescale 1ns / 1ps

module Keyboard_Input(
    input clk,
    input clkin,
    input datain,
    output reg[7:0] data

    );
    reg[7:0] store;
    reg[1:0] clk_judge;
    reg[7:0] datatemp, datafull;
    wire clk_negedge;
    //get negedge
    reg ps2_clk0, ps2_clk1, ps2_clk2;
    wire ps2_clk_neg;  //negedge
    reg ps2_state;
    initial begin 
        datatemp = 0; 
    end
    always @ (posedge clk) begin
        ps2_clk0 <= clkin;
        ps2_clk1 <= ps2_clk0;
        ps2_clk2 <= ps2_clk1;
    end

    assign ps2_clk_neg = ~ps2_clk1 & ps2_clk2;
    reg [3:0]num;  

    always @ (posedge clk) begin
        if (ps2_clk_neg)begin
                if (num == 0) num <= num + 1'b1;//skip the first number
                else if (num <= 8)              
                    begin
                        num <= num + 1'b1;
                        datatemp[num - 1] <= datain;
                    end
                else if (num == 9) num <= num + 1'b1;//skip the check number
                else  num <= 4'd0;
            end
    end
    
    reg cnt;
    initial cnt = 0;
    parameter ENTER = 8'h5A;
    parameter BACK = 8'h66;
    parameter SPACE = 8'h29;
    parameter ESC = 8'h76;
    always@(posedge clk)begin
        if(num >= 8) begin
            if(datatemp == ENTER || datatemp == BACK || 
               datatemp == SPACE || datatemp == ESC) begin
                cnt = ~cnt;
                if(cnt) data <= datatemp;
            end
            else data <= datatemp;
        end
    end
endmodule
