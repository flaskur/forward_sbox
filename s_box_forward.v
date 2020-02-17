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
// IF TESTBENCH BREAKS, REMOVE READY AND VALID, ONLY TEST WITH BASICS.

// Initial Thoughts...
// There are two methods that I want to try. The first is the circular shift method which takes the entire byte and returns the entire byte. The second one is the bit modulus method which calculates a single byte.
// Likely, I'll try the circular shift method first and see if it is it works, then do the bit modulus method with pipelining since we can break it down into byte calculations.
// The ready and valid stuff interfaces the testbench but it can definitely get confusing on what should happen. For now I wouldn't pay too much attention on that.


// Bit Modulus Method
// I did it by hand for the 0x3D -> 0xBB -> 0x27 case and it seems to work. This is definitely more pipeline friendly since the operations are split into 8 distinct parts. 
// I would likely model this similar to the first lab with several pipeline registers. It's incredibly tedious though. 
// UPDATE: This works completely. I tested on the testcases and some other ones by checking a mult inverse table and s-box result table. Have not included the testbench logic yet though.

// Pipeline input delay.
reg [7:0] pipe2_indelay1;
    
reg [7:0] pipe3_indelay1;
reg [7:0] pipe3_indelay2;

reg [7:0] pipe4_indelay1;
reg [7:0] pipe4_indelay2;
reg [7:0] pipe4_indelay3;

reg [7:0] pipe5_indelay1;
reg [7:0] pipe5_indelay2;
reg [7:0] pipe5_indelay3;
reg [7:0] pipe5_indelay4;

reg [7:0] pipe6_indelay1;
reg [7:0] pipe6_indelay2;
reg [7:0] pipe6_indelay3;
reg [7:0] pipe6_indelay4;
reg [7:0] pipe6_indelay5;

reg [7:0] pipe7_indelay1;
reg [7:0] pipe7_indelay2;
reg [7:0] pipe7_indelay3;
reg [7:0] pipe7_indelay4;
reg [7:0] pipe7_indelay5;
reg [7:0] pipe7_indelay6;

reg [7:0] pipe8_indelay1;
reg [7:0] pipe8_indelay2;
reg [7:0] pipe8_indelay3;
reg [7:0] pipe8_indelay4;
reg [7:0] pipe8_indelay5;
reg [7:0] pipe8_indelay6;
reg [7:0] pipe8_indelay7;

// The output of the bitmod module for each bit calculation.
wire bit_out1;
wire bit_out2;
wire bit_out3;
wire bit_out4;
wire bit_out5;
wire bit_out6;
wire bit_out7;
wire bit_out8; 

// Pipeline output delay.
reg pipe1_outdelay1;
reg pipe1_outdelay2;
reg pipe1_outdelay3;
reg pipe1_outdelay4;
reg pipe1_outdelay5;
reg pipe1_outdelay6;
reg pipe1_outdelay7;

reg pipe2_outdelay1;
reg pipe2_outdelay2;
reg pipe2_outdelay3;
reg pipe2_outdelay4;
reg pipe2_outdelay5;
reg pipe2_outdelay6;

reg pipe3_outdelay1;
reg pipe3_outdelay2;
reg pipe3_outdelay3;
reg pipe3_outdelay4;
reg pipe3_outdelay5;

reg pipe4_outdelay1;
reg pipe4_outdelay2;
reg pipe4_outdelay3;
reg pipe4_outdelay4;

reg pipe5_outdelay1;
reg pipe5_outdelay2;
reg pipe5_outdelay3;

reg pipe6_outdelay1;
reg pipe6_outdelay2;

reg pipe7_outdelay1;


reg input_ready;
reg output_valid;


reg [7:0] counter;
reg [7:0] finish;

assign iready = input_ready;
assign ovalid = output_valid;
// Assignment of output data concatenates all the bitmod calculations.
assign odata = {bit_out8, pipe7_outdelay1, pipe6_outdelay2, pipe5_outdelay3, pipe4_outdelay4, pipe3_outdelay5, pipe2_outdelay6, pipe1_outdelay7};

// Instantiating the bitmod modules for each bit.
bitmod #(.AFFINE_CONSTANT(AFFINE_CONSTANT)) b0(.clk(clk), .ibit(3'b000), .idata(idata), .obit(bit_out1));
bitmod #(.AFFINE_CONSTANT(AFFINE_CONSTANT)) b1(.clk(clk), .ibit(3'b001), .idata(pipe2_indelay1), .obit(bit_out2));
bitmod #(.AFFINE_CONSTANT(AFFINE_CONSTANT)) b2(.clk(clk), .ibit(3'b010), .idata(pipe3_indelay2), .obit(bit_out3));
bitmod #(.AFFINE_CONSTANT(AFFINE_CONSTANT)) b3(.clk(clk), .ibit(3'b011), .idata(pipe4_indelay3), .obit(bit_out4));
bitmod #(.AFFINE_CONSTANT(AFFINE_CONSTANT)) b4(.clk(clk), .ibit(3'b100), .idata(pipe5_indelay4), .obit(bit_out5));
bitmod #(.AFFINE_CONSTANT(AFFINE_CONSTANT)) b5(.clk(clk), .ibit(3'b101), .idata(pipe6_indelay5), .obit(bit_out6));
bitmod #(.AFFINE_CONSTANT(AFFINE_CONSTANT)) b6(.clk(clk), .ibit(3'b110), .idata(pipe7_indelay6), .obit(bit_out7));
bitmod #(.AFFINE_CONSTANT(AFFINE_CONSTANT)) b7(.clk(clk), .ibit(3'b111), .idata(pipe8_indelay7), .obit(bit_out8));


// The testbench interface might mess everything up. I can't really test accurately though since they don't give the testbench.
always @(posedge clk) begin

  // IF THE LOGIC BELOW BREAKS BECAUSE OF TESTBENCH INTERFACE, UNCOMMENT BOTTOM AND DELETE THIS ENTIRE PART.

  // On reset I clear all the pipeline registers, set counter and finish to 0 and set iready to 1 so testbench knows it can start.
  if (rst) begin
    // Setting pipeline registers to 0, should probably be null instead though.
    pipe2_indelay1 <= 0;
    
    pipe3_indelay1 <= 0;
    pipe3_indelay2 <= 0;
    
    pipe4_indelay1 <= 0;
    pipe4_indelay2 <= 0;
    pipe4_indelay3 <= 0;
    
    pipe5_indelay1 <= 0;
    pipe5_indelay2 <= 0;
    pipe5_indelay3 <= 0;
    pipe5_indelay4 <= 0;
    
    pipe6_indelay1 <= 0;
    pipe6_indelay2 <= 0;
    pipe6_indelay3 <= 0;
    pipe6_indelay4 <= 0;
    pipe6_indelay5 <= 0;
    
    pipe7_indelay1 <= 0;
    pipe7_indelay2 <= 0;
    pipe7_indelay3 <= 0;
    pipe7_indelay4 <= 0;
    pipe7_indelay5 <= 0;
    pipe7_indelay6 <= 0;
    
    pipe8_indelay1 <= 0;
    pipe8_indelay2 <= 0;
    pipe8_indelay3 <= 0;
    pipe8_indelay4 <= 0;
    pipe8_indelay5 <= 0;
    pipe8_indelay6 <= 0;
    pipe8_indelay7 <= 0;
    
    pipe1_outdelay1 <= 0;
    pipe1_outdelay2 <= 0;
    pipe1_outdelay3 <= 0;
    pipe1_outdelay4 <= 0;
    pipe1_outdelay5 <= 0;
    pipe1_outdelay6 <= 0;
    pipe1_outdelay7 <= 0;
    
    pipe2_outdelay1 <= 0;
    pipe2_outdelay2 <= 0;
    pipe2_outdelay3 <= 0;
    pipe2_outdelay4 <= 0;
    pipe2_outdelay5 <= 0;
    pipe2_outdelay6 <= 0;
    
    pipe3_outdelay1 <= 0;
    pipe3_outdelay2 <= 0;
    pipe3_outdelay3 <= 0;
    pipe3_outdelay4 <= 0;
    pipe3_outdelay5 <= 0;
    
    pipe4_outdelay1 <= 0;
    pipe4_outdelay2 <= 0;
    pipe4_outdelay3 <= 0;
    pipe4_outdelay4 <= 0;
    
    pipe5_outdelay1 <= 0;
    pipe5_outdelay2 <= 0;
    pipe5_outdelay3 <= 0;
    
    pipe6_outdelay1 <= 0;
    pipe6_outdelay2 <= 0;
    
    pipe7_outdelay1 <= 0;
    
    counter <= 0;
    finish <= 0;
    
    input_ready <= 1;
    
  // This is normal operation. We keep a counter so that we know when we finally have a genuine answer, which is after cycle 8 since there are 8 pipeline stages.
  end else if (ivalid & oready) begin
    counter <= counter + 1;
  

    // Pipelining register assignments.
    pipe2_indelay1 <= idata;
        
    pipe3_indelay1 <= idata;
    pipe3_indelay2 <= pipe3_indelay1;
    
    pipe4_indelay1 <= idata;
    pipe4_indelay2 <= pipe4_indelay1;
    pipe4_indelay3 <= pipe4_indelay2;
    
    pipe5_indelay1 <= idata;
    pipe5_indelay2 <= pipe5_indelay1;
    pipe5_indelay3 <= pipe5_indelay2;
    pipe5_indelay4 <= pipe5_indelay3;
    
    pipe6_indelay1 <= idata;
    pipe6_indelay2 <= pipe6_indelay1;
    pipe6_indelay3 <= pipe6_indelay2;
    pipe6_indelay4 <= pipe6_indelay3;
    pipe6_indelay5 <= pipe6_indelay4;
    
    pipe7_indelay1 <= idata;
    pipe7_indelay2 <= pipe7_indelay1;
    pipe7_indelay3 <= pipe7_indelay2;
    pipe7_indelay4 <= pipe7_indelay3;
    pipe7_indelay5 <= pipe7_indelay4;
    pipe7_indelay6 <= pipe7_indelay5;
    
    pipe8_indelay1 <= idata;
    pipe8_indelay2 <= pipe8_indelay1;
    pipe8_indelay3 <= pipe8_indelay2;
    pipe8_indelay4 <= pipe8_indelay3;
    pipe8_indelay5 <= pipe8_indelay4;
    pipe8_indelay6 <= pipe8_indelay5;
    pipe8_indelay7 <= pipe8_indelay6;
    
    
    // Output pipeline register assignments.
    pipe1_outdelay1 <= bit_out1;
    pipe1_outdelay2 <= pipe1_outdelay1;
    pipe1_outdelay3 <= pipe1_outdelay2;
    pipe1_outdelay4 <= pipe1_outdelay3;
    pipe1_outdelay5 <= pipe1_outdelay4;
    pipe1_outdelay6 <= pipe1_outdelay5;
    pipe1_outdelay7 <= pipe1_outdelay6;
    
    pipe2_outdelay1 <= bit_out2;
    pipe2_outdelay2 <= pipe2_outdelay1;
    pipe2_outdelay3 <= pipe2_outdelay2;
    pipe2_outdelay4 <= pipe2_outdelay3;
    pipe2_outdelay5 <= pipe2_outdelay4;
    pipe2_outdelay6 <= pipe2_outdelay5;
    
    pipe3_outdelay1 <= bit_out3;
    pipe3_outdelay2 <= pipe3_outdelay1;
    pipe3_outdelay3 <= pipe3_outdelay2;
    pipe3_outdelay4 <= pipe3_outdelay3;
    pipe3_outdelay5 <= pipe3_outdelay4;
    
    pipe4_outdelay1 <= bit_out4;
    pipe4_outdelay2 <= pipe4_outdelay1;
    pipe4_outdelay3 <= pipe4_outdelay2;
    pipe4_outdelay4 <= pipe4_outdelay3;
    
    pipe5_outdelay1 <= bit_out5;
    pipe5_outdelay2 <= pipe5_outdelay1;
    pipe5_outdelay3 <= pipe5_outdelay2;
    
    pipe6_outdelay1 <= bit_out6;
    pipe6_outdelay2 <= pipe6_outdelay1;
    
    pipe7_outdelay1 <= bit_out7;
    
    if (counter >= 8) begin
      output_valid <= 1;
    end
    
  // When the testbench doesn't have input valid and output ready as 1, then testbench stops streaming data.
  // We must complete the rest of the stream already given, which should finish in 8 cycles, then we set output valid to 0 to show the testbench that we finished.
  end else begin
    // The testbench should have stopped streaming in data.
    finish <= finish + 1;
    
    if (finish >= 8) begin
      output_valid <= 0;
    end
  end
  
  
  
  /* IF THE ABOVE MESSES UP FROM TESTBENCH INTERFACE, UNCOMMENT THIS AND REMOVE IVALID, OVALID, IREADY, OREADY FROM INPUT/OUTPUT AS WELL AS THE ABOVE LOGIC.
  // Pipelining register assignments.
    pipe2_indelay1 <= idata;
        
    pipe3_indelay1 <= idata;
    pipe3_indelay2 <= pipe3_indelay1;
    
    pipe4_indelay1 <= idata;
    pipe4_indelay2 <= pipe4_indelay1;
    pipe4_indelay3 <= pipe4_indelay2;
    
    pipe5_indelay1 <= idata;
    pipe5_indelay2 <= pipe5_indelay1;
    pipe5_indelay3 <= pipe5_indelay2;
    pipe5_indelay4 <= pipe5_indelay3;
    
    pipe6_indelay1 <= idata;
    pipe6_indelay2 <= pipe6_indelay1;
    pipe6_indelay3 <= pipe6_indelay2;
    pipe6_indelay4 <= pipe6_indelay3;
    pipe6_indelay5 <= pipe6_indelay4;
    
    pipe7_indelay1 <= idata;
    pipe7_indelay2 <= pipe7_indelay1;
    pipe7_indelay3 <= pipe7_indelay2;
    pipe7_indelay4 <= pipe7_indelay3;
    pipe7_indelay5 <= pipe7_indelay4;
    pipe7_indelay6 <= pipe7_indelay5;
    
    pipe8_indelay1 <= idata;
    pipe8_indelay2 <= pipe8_indelay1;
    pipe8_indelay3 <= pipe8_indelay2;
    pipe8_indelay4 <= pipe8_indelay3;
    pipe8_indelay5 <= pipe8_indelay4;
    pipe8_indelay6 <= pipe8_indelay5;
    pipe8_indelay7 <= pipe8_indelay6;
    
    
    // Output pipeline register assignments.
    pipe1_outdelay1 <= bit_out1;
    pipe1_outdelay2 <= pipe1_outdelay1;
    pipe1_outdelay3 <= pipe1_outdelay2;
    pipe1_outdelay4 <= pipe1_outdelay3;
    pipe1_outdelay5 <= pipe1_outdelay4;
    pipe1_outdelay6 <= pipe1_outdelay5;
    pipe1_outdelay7 <= pipe1_outdelay6;
    
    pipe2_outdelay1 <= bit_out2;
    pipe2_outdelay2 <= pipe2_outdelay1;
    pipe2_outdelay3 <= pipe2_outdelay2;
    pipe2_outdelay4 <= pipe2_outdelay3;
    pipe2_outdelay5 <= pipe2_outdelay4;
    pipe2_outdelay6 <= pipe2_outdelay5;
    
    pipe3_outdelay1 <= bit_out3;
    pipe3_outdelay2 <= pipe3_outdelay1;
    pipe3_outdelay3 <= pipe3_outdelay2;
    pipe3_outdelay4 <= pipe3_outdelay3;
    pipe3_outdelay5 <= pipe3_outdelay4;
    
    pipe4_outdelay1 <= bit_out4;
    pipe4_outdelay2 <= pipe4_outdelay1;
    pipe4_outdelay3 <= pipe4_outdelay2;
    pipe4_outdelay4 <= pipe4_outdelay3;
    
    pipe5_outdelay1 <= bit_out5;
    pipe5_outdelay2 <= pipe5_outdelay1;
    pipe5_outdelay3 <= pipe5_outdelay2;
    
    pipe6_outdelay1 <= bit_out6;
    pipe6_outdelay2 <= pipe6_outdelay1;
    
    pipe7_outdelay1 <= bit_out7;
  */
end



endmodule

/*
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
*/
