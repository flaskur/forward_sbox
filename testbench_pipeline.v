// This is the testbench that I used for the base logic. It works but it ignores the testbench interface stuff.

`timescale 1ns / 1ps

module testbench_pipeline();

reg clk;
reg [7:0] input_data;
wire [7:0] output_data;

s_box_forward sbox(.clk(clk), .idata(input_data), .odata(output_data));

always #5 clk = !clk;

initial begin
    clk <= 0;
    input_data <= 8'hB4; // Expect 0x82
    #100
    input_data <= 8'hAA; // Expect 0xC9
    #100
    input_data <= 8'h4B; // Expect 0x7D
    #100
    input_data <= 8'h99; // Expect 0xFA
    #100
    input_data <= 8'hBB; // Expect 0x27
    #100
    $finish;
end

endmodule
