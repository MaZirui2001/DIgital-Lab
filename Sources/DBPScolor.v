`timescale 1ns / 1ps

module DBPS(
    input clk, 
    input x, 
    output y
    );
    reg [27:0] cnt1;
    reg a;
    initial begin
        cnt1 = 0;
        a = 0;
    end
    //DB
    always @(posedge clk)begin
        if(x == 1) begin 
            if(cnt1 == 10000000) a <= 1;
            else cnt1 <= cnt1 + 1; 
        end
        else begin
            cnt1 <= 0;
            a <= 0;
        end
    end
    //PS
    reg s1, s2, s3;
    initial begin 
        s1 = 0; 
        s2 = 0; 
        s3 = 0; 
    end
    always@(posedge clk)begin
        s1 <= a;
        s2 <= s1;
        s3 <= s2;
    end
    assign y = s2 & (~s3);
endmodule
