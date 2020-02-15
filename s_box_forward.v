module s_box_forward (
  input clk,
  input rst,
  input [7:0] idata,
  output [7:0] odata,
  output iready,
  input ivalid,
  input oready,
  output ovalid
);

reg [7:0] one_shift = {idata[6:0], idata[7]};
reg [7:0] two_shift = {idata[5:0], idata[7:6]};
reg [7:0] three_shift = {idata[4:0], idata[7:5]};
reg [7:0] four_shift = {idata[3:0], idata[7:4]};
reg [7:0] affine_constant = 8'b0110_0011; // 0x63

reg input_ready;
reg [7:0] output_data;

// CIRCULAR SHIFT FORMULA: s = x ^ (x <<< 1) ^ (x <<< 2) ^ (x <<< 3) ^ (x <<< 4) ^ 0x63, where s is the final 8 bit, 1 byte result, x is the multiplicative inverse of the 8 bit, 1 byte input, and <<< is a round shift left, meaning 1100_1100 <<< 1 becomes 1001_1001.

// For now assume INPUT IS ALREADY MULTIPLICATIVE INVERSE.
// always @(posedge clock) begin
//   output_data <= one_shift ^ two_shift ^ three_shift ^ four_shift ^ affine_constant;
// end

assign iready = input_ready;

always @(posedge clk) begin
  if (rst) begin

    input_ready <= 1'b1;
  end else if (ivalid and oready) begin
    output_data <= one_shift ^ two_shift ^ three_shift ^ four_shift ^ affine_constant;
  end
  
end

endmodule

// Some clarification about the testbench and input/output. On reset I guess everything is set to 0 including input, output, pipelines, etc. The ivalid means that the testbench is sending a valid input. So we shouldn't do any operation unless ivalid is 1. The oready means that the testbench is ready to receive the output data from s-box. Wait, what??? So, does that mean we can't assign output but we can do operations? That's fucking weird. The idata is just the data we get which I expect to be a single byte. The iready means that the s-box is ready to recieve valid idata requests. This should be marked when the thing finishes right? The ovalid means that the sbox is sending valid output data that has the finished sbox stuff, so the testbench should start evaluating it. That's fucking confusing. So from what I can understand, you only do operations if ivalid is 1. You only assign to output if oready is 1. You set iready to 1 when you finish meaning you've complete the one you're already on. You set ovalid to 1 to show the testbench that the output is legit. 
// This implies that the testbench has some registers to carry the output values. That's fucking weird... Since we have no pipelines on reset that only thing that would happen is that the output data should be 0'd I think. On finish reset we set iready to 1. 