`timescale 1ns / 1ps
module ChangeHtoD(bdata, odata);//32位二进制转换为8位十进制//移位加3
    input [31:0]bdata;
    output [15:0]odata;
    reg [63:0] idata;
    integer i; 
    always @(*)
    begin
        idata = bdata;      
        for(i = 0; i < 32; i = i + 1)
        begin         
            if(idata[35:32] > 4'h4)
                idata[35:32] = idata[35:32] + 4'h3;
            if(idata[39:36] > 4'h4)
                idata[39:36] = idata[39:36] + 4'h3;
            if(idata[43:40] > 4'h4)
                idata[43:40] = idata[43:40] + 4'h3;
            if(idata[47:44] > 4'h4)
                idata[47:44] = idata[47:44] + 4'h3;   
            if(idata[51:48] > 4'h4)
                idata[51:48] = idata[51:48] + 4'h3; 
            if(idata[55:52] > 4'h4)
                    idata[55:52] = idata[55:52] + 4'h3; 
            if(idata[59:56] > 4'h4)
                    idata[59:56] = idata[59:56] + 4'h3; 
            if(idata[63:60] > 4'h4)
                    idata[63:60] = idata[63:60] + 4'h3; 
            idata = idata << 1;      
        end             
    end 
        assign odata = idata[47:32];
endmodule
