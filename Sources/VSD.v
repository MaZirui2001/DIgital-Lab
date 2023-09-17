`timescale 1ns / 1ps

module VSD( 
    input pclk,
    input [11:0] pdata,
    output reg [10:0] hcount,
    output reg [9:0] vcount,
    output reg [11:0] vrgb,
    output reg hs, vs
);
    reg hen, ven;
    reg temp;
    reg [11:0] trgb;

    initial begin
        vcount <= 0;
        hcount <= 0;
    end

    always @( posedge pclk ) begin
        if ( hcount == 1039 ) begin
            hcount <= 0;
            if ( vcount == 665 ) vcount <= 0;
            else vcount <= vcount + 1;
        end
        else hcount <= hcount + 1;
    end

    always @( posedge pclk ) begin
        if ( hcount == 0 ) hen <= 1;
        if ( hcount == 800 ) hen <= 0;
    end

    always @( posedge pclk ) begin
        if ( vcount == 0 ) ven <= 1;
        if ( vcount == 600 ) ven <= 0;
    end

    always @( posedge pclk ) begin
        if ( hcount == 856 ) hs <= 1;
        if ( hcount == 976 ) hs <= 0;
    end

    always @( posedge pclk ) begin
        if ( vcount == 637 ) vs <= 1;
        if ( vcount == 643 ) vs <= 0;
    end

    always @(*) begin
        trgb = ( hen & ven ) ? pdata : 0; 
    end

    always @( posedge pclk ) begin
        vrgb <= trgb;
    end
endmodule
