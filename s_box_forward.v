`timescale 1ns / 1ps

// This forward s-box assume that the input data, idata is a single byte of 8 bits and it represents the multiplicative inverse of the actual input that should be encrypted in AES standard.
module s_box_forward # (
    parameter AFFINE_CONSTANT = 8'b0110_0011 // 0x63
)(
    input clk,
    input rst,
    input [7:0] idata, // 8 bit, 1 byte, input data.
    output [7:0] odata, // 8 bit, 1 byte, output data.
    output iready, // Means s-box is ready to receive valid idata requests.
    input ivalid, // Means the testbench is sending valid data to s-box.
    input oready, // Means the testbench is ready to receive output data from s-box.
    output ovalid // Means that the s-box is sending valid data to testbench, so testbench should start to evaluate the output data.
);

// Initial Thoughts...
// There are two methods that I want to try. The first is the circular shift method which takes the entire byte and returns the entire byte. The second one is the bit modulus method which calculates a single byte.
// Likely, I'll try the circular shift method first and see if it is it works, then do the bit modulus method with pipelining since we can break it down into byte calculations.
// The ready and valid stuff interfaces the testbench but it can definitely get confusing on what should happen. For now I wouldn't pay too much attention on that.

// Circular Shift Method...
// After testing with the testbench it works. The cycles are a bit off since I don't know how to properly create a testbench, but the right values do appear.
// This is a single cycle solution which is probably poor in terms of performance, but it works.

reg [7:0] one_shift;
reg [7:0] two_shift;
reg [7:0] three_shift;
reg [7:0] four_shift;

reg [7:0] output_data;

reg input_ready;
reg output_valid;


always @(posedge clk) begin
    if (rst) begin // RESET: I imagine that the testbench starts by triggering rst as 1 to give registers initial state.
        one_shift <= 8'b0000_0000;
        two_shift <= 8'b0000_0000;
        three_shift <= 8'b0000_0000;
        four_shift <= 8'b0000_0000;
        
        output_data <= 8'b0000_0000;
        input_ready <= 1'b1; // After reset, trigger input_ready so that the testbench can start giving valid input.
    end else if (ivalid && oready) begin // OPERATING: The input data is valid and the testbench is ready to receive output data.
        one_shift <= {idata[6:0], idata[7]};
        two_shift <= {idata[5:0], idata[7:6]};
        three_shift <= {idata[4:0], idata[7:5]};
        four_shift <= {idata[3:0], idata[7:4]};
        
        output_data <= idata ^ one_shift ^ two_shift ^ three_shift ^ four_shift ^ AFFINE_CONSTANT;
        
        input_ready <= 1'b1;
        output_valid <= 1'b1;
    end
    // Since this is a one cycle operation with circular shift method, no pipelining here. If you were to have pipelines, you would have a finish logic and set oready to 1 based on number of pipeline stages.
    
end

assign odata = output_data;
assign iready = input_ready;
assign ovalid = output_valid;


// Bit Modulus Method
// I did it by hand for the 0x3D -> 0xBB -> 0x27 case and it seems to work. This is definitely more pipeline friendly since the operations are split into 8 distinct parts. 
// I would likely model this similar to the first lab with several pipeline registers. It's incredibly tedious though. 



endmodule


/* OLD
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
*/