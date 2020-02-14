module s_box_forward (
  input clock,
  input reset,
  input input_valid,
  input output_ready,
  input [7:0] input_data,
  output input_ready,
  output output_valid,
  output [7:0] output_data
);

reg [7:0] one_shift = {input_data[6:0], input_data[7]};
reg [7:0] two_shift = {input_data[5:0], input_data[7:6]};
reg [7:0] three_shift = {input_data[4:0], input_data[7:5]};
reg [7:0] four_shift = {input_data[3:0], input_data[7:4]};
reg [7:0] affine_constant = 8'b0110_0011; // 0x63

reg [7:0] output_data;

// Instead of doing the matrix multiplication, I'd rather just follow the given formula that does round shifts and xors.
// FORMULA: s = x ^ (x <<< 1) ^ (x <<< 2) ^ (x <<< 3) ^ (x <<< 4) ^ 0x63, where s is the final 8 bit, 1 byte result, x is the multiplicative inverse of the 8 bit, 1 byte input, and <<< is a round shift left, meaning 1100_1100 <<< 1 becomes 1001_1001.

// For now assume INPUT IS ALREADY MULTIPLICATIVE INVERSE.
always @(posedge clock) begin
  output_data <= one_shift ^ two_shift ^ three_shift ^ four_shift ^ affine_constant;
end

// READY/VALID?
endmodule

// Abstract view, s-box takes the rounded key which is input XOR key as the actual input_data. The s-box operation takes the multiplicative inverse of the input_data. This I have yet to figure out a method for doing. With this multiplicative inverse, I need to do matrix multiplication with the affine matrix which I can represent row-wise using 8 registers. Then I need to add the affine constant which is 0x63. That's the entire answer. Don't worry about performance right now.

// Pipelining? The output bit is composed of 8 answers. Each 8 bit requires an intensive multiplication process so I could pipeline it, but that's a lot of work.

// Should be 2DIM matrix instead for access.
/*
reg [7:0] affine_row0 = {8'b10001111};
reg [7:0] affine_row1 = {8'b11000111};
reg [7:0] affine_row2 = {8'b11100011};
reg [7:0] affine_row3 = {8'b11110001};
reg [7:0] affine_row4 = {8'b11111000};
reg [7:0] affine_row5 = {8'b01111100};
reg [7:0] affine_row6 = {8'b00111110};
reg [7:0] affine_row7 = {8'b00011111};

reg [7:0] affine_constant = {8'b01100011};

reg [7:0] affine_state = {8'b00000000};
reg [7:0] output_state = {8'b00000000};

reg row_sum = 0; // Var declaration?

assign output = affine_state;

always @(posedge clock) begin
  if (reset) begin
    // Something reset?
  end

  // Var declaration?
  genvar row;
  genvar column;
  // For each bit, you need to do a multiplication with each bit placement.
  for (int row = 0; row < 8; row = row + 1) {
    row_sum = 0;
    for (int column = 0; column < 8; column = column + 1) {
      // The affine matrix should be a 2 dimensional array.
      row_sum = row_sum + (affine_matrix[row][column] * multiplicative_inverse[column])
    }
    affine_state[column] = row_sum + affine_constant[column];
    affine_state[column] = affine_state[column] % 2;
  }

  
end


*/

// Remember that this is essentially a hash table and the methodology of converting one byte to another byte is already established as a public algorithm. The only weird thing is the ready and valid bit for both input and output. Not sure how that is used at the moment. 