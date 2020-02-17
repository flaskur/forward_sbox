`timescale 1ns / 1ps

// This is the actual calculation portion. I need to give the normal 8 bit input and return a single bit based on the formula with modulus. I also need the affine constant.
module bitmod # (
  parameter [7:0] AFFINE_CONSTANT = 8'h63 
)(
  input clk,
  input [2:0] ibit, // Meaning which particular bit index you want like b0, b1, etc.
  input [7:0] idata,
  output obit
);

reg output_bit;

assign obit = output_bit;

// Following the bit modulus formula given on wikipedia, this finds the single bit value for a particular index, ibit.
always @(posedge clk) begin
    output_bit <= idata[ibit] ^ idata[(ibit + 4) % 8] ^ idata[(ibit + 5) % 8] ^ idata[(ibit + 6) % 8] ^ idata[(ibit + 7) % 8] + AFFINE_CONSTANT[ibit];
end

// Debugging.
always @(*) begin
    $display("%3b", ibit);
    $display("%b", obit);
end

endmodule
