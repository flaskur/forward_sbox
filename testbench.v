`timescale 1ns / 1ps

module testbench();

reg clk;
reg rst;
reg [7:0] idata;
wire [7:0] odata;
wire iready;
reg ivalid;
reg oready;
wire ovalid;

s_box_forward s_instance(.clk(clk), .rst(rst), .idata(idata), .odata(odata), .iready(iready), .ivalid(ivalid), .oready(oready), .ovalid(ovalid));

always 
    #5 clk = !clk;
    
initial begin
    clk <= 0;
    rst <= 1;
    #60;
    $display($time, "%10d => %10d", idata, odata);
    rst <= 0;
    idata <= 8'b1011_1011;
    ivalid <= 1;
    oready <= 1;
    #60;  
    $display($time, "%10d => %10d", idata, odata); // I expect 0x27 or 0010_0111.
    idata <= 8'h1C;
    #60;
    $display($time, "%10d => %10d", idata, odata);
    idata <= 8'h56;
    #60
    $display($time, "%10d => %10d", idata, odata);
    
    $finish;
end

endmodule
