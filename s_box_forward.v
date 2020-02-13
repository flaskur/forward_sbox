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

// Abstract view, s-box takes the rounded key which is input XOR key as the actual input_data. The s-box operation takes the multiplicative inverse of the input_data. This I have yet to figure out a method for doing. With this multiplicative inverse, I need to do matrix multiplication with the affine matrix which I can represent row-wise using 8 registers. Then I need to add the affine constant which is 0x63. That's the entire answer. Don't worry about performance right now.

reg [7:0] affine_row1 = {}


endmodule;

// Remember that this is essentially a hash table and the methodology of converting one byte to another byte is already established as a public algorithm. The only weird thing is the ready and valid bit for both input and output. Not sure how that is used at the moment. 