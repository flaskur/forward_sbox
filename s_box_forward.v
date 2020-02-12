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


endmodule;

// Remember that this is essentially a hash table and the methodology of converting one byte to another byte is already established as a public algorithm. The only weird thing is the ready and valid bit for both input and output. Not sure how that is used at the moment. 