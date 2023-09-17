`timescale 1ns / 1ps

module DIS(    
    input clk,
    input [63:0] din_h,
    output [7:0]an,
    output [6:0]c
    );
    reg clkd;
    reg [2:0]sel;
    wire [3:0]digit;
    wire [31:0]d;
    wire [7:0]en;
    //Fre_Div
    parameter N = 100000;
    reg [30:0] cnt;
    initial cnt = 0;
    always @(posedge clk)begin
        if(cnt == (N - 1)) cnt <= 0;
        else cnt <= cnt + 1;
        clkd <= (cnt == (N - 1));
    end
    //selector
    always @(posedge clkd)begin
        sel <= sel + 1;
    end

    ChangeHtoD changera(din_h[63:32], d[31:16]);
    ChangeHtoD changerb(din_h[31:0], d[15:0]);

    digit_pro ctrla(d[31:16], en[7:5]);
    digit_pro ctrlb(d[15:0], en[3:1]);

    Decoder_8 ans(sel, en, an);
    Mux32_4 mux(d, sel, digit);
    Digit_Decoder out(digit, c);

endmodule
