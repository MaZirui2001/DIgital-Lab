`timescale 1ns / 1ps
module digit_pro(
    input [15:0]d,
    output reg [3:1]en
    );
    initial begin
        en = 3'b0;
    end
    always @(*)begin
        if(d[15:12] == 4'b0)begin
            if(d[11:8] == 4'b0)begin
                if(d[7:4] == 4'b0) begin
                    en = 3'b000;
                end
                else en = 3'b001;
            end
            else en = 3'b011;
        end
        else en = 3'b111;
    end
endmodule
