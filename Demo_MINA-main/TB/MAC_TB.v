`timescale 1ns/1ps
`include "common.vh"
module MAC_tb;

    // Testbench signals
    reg CLK;
    reg RST;
    reg S0_valid_in;
    reg S1_valid_in;
    reg S2_valid_in;
    reg [15:0] S0_in;
    reg [15:0] S1_in;
    reg [15:0] S2_in;
    
    wire D0_valid;
    wire [15:0] D0_out;

    // Instantiate the MAC module
    MAC uut (
        .CLK(CLK),
        .RST(RST),
        .S0_valid_in(S0_valid_in),
        .S0_in(S0_in),
        .S1_valid_in(S1_valid_in),
        .S1_in(S1_in),
        .S2_valid_in(S2_valid_in),
        .S2_in(S2_in),
        .D0_valid(D0_valid),
        .D0_out(D0_out)
    );

    // Clock generation
    always begin
        #5 CLK = ~CLK; // 10 ns clock period (100 MHz)
    end

    // Convert floating-point to 16-bit fixed-point format
    function [15:0] to_fixed_point;
        input real value;
        begin
            to_fixed_point = $rtoi(value * (1 << 6)); // Multiply by 2^6 to handle 5 fractional bits
        end
    endfunction

    // Test stimulus
    initial begin
        // Initialize all signals
        CLK <= 0;
        RST <= 1;
        S0_valid_in <= 0;
        S1_valid_in <= 0;
        S2_valid_in <= 0;
        S0_in <= 16'd0;
        S1_in <= 16'd0;
        S2_in <= 16'd0;

        // Release reset after a few clock cycles
        #15 RST <= 0;

        // Test 1: Fixed-point multiplication and accumulation
        #10;
        S0_valid_in <= 1;
        S1_valid_in <= 1;
        S2_valid_in <= 1;
        S0_in <= to_fixed_point(-5.25);   // multiplicand (5.75 in fixed-point)
        S1_in <= to_fixed_point(-2.75);   // multiplier (3.25 in fixed-point)
        S2_in <= to_fixed_point(0);    // accumulation value (2.5 in fixed-point)
        #10;
        S0_in <= to_fixed_point(0);  // multiplicand (-3.75 in fixed-point)
        S1_in <= to_fixed_point(0);    // multiplier (4.5 in fixed-point)
        S2_in <= to_fixed_point(0);   // accumulation value (1.75 in fixed-point)
		#10;
        S0_in <= to_fixed_point(-0.25);  // multiplicand (-3.75 in fixed-point)
        S1_in <= to_fixed_point(-0.25);    // multiplier (4.5 in fixed-point)
        S2_in <= to_fixed_point(-0.25);   // accumulation value (1.75 in fixed-point)
		#10;
        S0_in <= to_fixed_point(1);  // multiplicand (-3.75 in fixed-point)
        S1_in <= to_fixed_point(-0.25);    // multiplier (4.5 in fixed-point)
        S2_in <= to_fixed_point(0.25);   // accumulation value (1.75 in fixed-point)
		#10;
        S0_in <= to_fixed_point(1);  // multiplicand (-3.75 in fixed-point)
        S1_in <= to_fixed_point(1);    // multiplier (4.5 in fixed-point)
        S2_in <= to_fixed_point(-1);   // accumulation value (1.75 in fixed-point)
		#10;
        S0_in <= to_fixed_point(0);  // multiplicand (-3.75 in fixed-point)
        S1_in <= to_fixed_point(1);    // multiplier (4.5 in fixed-point)
        S2_in <= to_fixed_point(-1);   // accumulation value (1.75 in fixed-point)
        #10;
        S0_in <= to_fixed_point(-3.75);  // multiplicand (-3.75 in fixed-point)
        S1_in <= to_fixed_point(4.5);    // multiplier (4.5 in fixed-point)
        S2_in <= to_fixed_point(1.75);   // accumulation value (1.75 in fixed-point)
        #10;
        // Apply some other values after reset
        S0_in <= to_fixed_point(6.25);   // multiplicand (6.25 in fixed-point)
        S1_in <= to_fixed_point(2.75);   // multiplier (2.75 in fixed-point)
        S2_in <= to_fixed_point(0.5);    // accumulation value (0.5 in fixed-point)
        #10;
        S0_in <= to_fixed_point(7.0);    // multiplicand (7.0 in fixed-point)
        S1_in <= to_fixed_point(0.0);    // Zero multiplier (0.0 in fixed-point)
        S2_in <= to_fixed_point(3.125);  // accumulation value (3.125 in fixed-point)
		#10;
        S0_valid_in <= 0;
        S1_valid_in <= 0;
        S2_valid_in <= 0;
       
        // End of simulation
        #100;
        $stop;
    end

endmodule

module MAC (
    input wire                          CLK,                      
    input wire                          RST,
    input wire                          S0_valid_in,        
    input wire signed [`WORD_BITS-1:0]  S0_in,   // Fixed-point input: 1 sign bit, 9 integer bits, 6 fractional bits
    input wire                          S1_valid_in,        
    input wire signed [`WORD_BITS-1:0]  S1_in,   // Fixed-point input: 1 sign bit, 9 integer bits, 6 fractional bits
    input wire                          S2_valid_in,        
    input wire signed [`WORD_BITS-1:0]  S2_in,   // Fixed-point input: 1 sign bit, 9 integer bits, 6 fractional bits
    output reg                          D0_valid,  
    output reg signed [`WORD_BITS-1:0]  D0_out  // Fixed-point output: 1 sign bit, 9 integer bits, 6 fractional bits
);

    // *************** Wire signals *************** //
    wire signed [`WORD_BITS*2-1:0]      partial_sum_0_wr, partial_sum_1_wr, partial_sum_2_wr, partial_sum_3_wr;
    wire signed [`WORD_BITS*2-1:0]      partial_sum_4_wr, partial_sum_5_wr, partial_sum_6_wr, partial_sum_7_wr;
    wire signed [`WORD_BITS*2-1:0]      partial_sum_8_wr, partial_sum_9_wr, partial_sum_10_wr, partial_sum_11_wr;
    wire signed [`WORD_BITS*2-1:0]      partial_sum_12_wr, partial_sum_13_wr, partial_sum_14_wr, partial_sum_15_wr;
    wire signed [`WORD_BITS*2-1:0]      multiplicand_wr;
    wire signed [`WORD_BITS*2-1:0]      sum_stage1_wr, sum_stage2_wr;
    wire signed [`WORD_BITS-1:0]        multiplier_wr;       
	wire 								both_negative_wr;
	wire signed [`WORD_BITS-1:0]  		D0_wr;

    // *************** Register signals *************** //
	reg signed [`WORD_BITS-1:0]      	accumulation_rg;
    reg signed [`WORD_BITS*2-1:0]       sum_stage1_rg;
    reg signed [`WORD_BITS*2-1:0]       multiplicand_rg;
    reg signed [`WORD_BITS-1:0]         multiplier_rg; 
    reg                                 S0_valid_rg, S1_valid_rg, S2_valid_rg;
	reg 								both_negative_rg;
	

    // Check if both S0 and S1 are negative
    wire signed [`WORD_BITS-1:0] abs_S0_in = (S0_in < 0) ? -S0_in : S0_in;
    wire signed [`WORD_BITS-1:0] abs_S1_in = (S1_in < 0) ? -S1_in : S1_in;
	
    assign both_negative_wr	 			= ((S0_in < 0) && (S1_in < 0))|((S0_in > 0) && (S1_in > 0));

    // Sign-extend inputs to 32 bits using the absolute values if both are negative
    assign multiplicand_wr   			= {{16{abs_S0_in[`WORD_BITS-1]}}, abs_S0_in};  // Sign-extend absolute S0_in to 32 bits
    assign multiplier_wr     			= abs_S1_in;  // No need to extend, keeping 16 bits

    // Generate partial sums (Shift-and-add, signed)
    assign partial_sum_0_wr  			= multiplier_wr[0]  ? multiplicand_wr : 32'sd0;
    assign partial_sum_1_wr  			= multiplier_wr[1]  ? ($signed(multiplicand_wr) << 1)  : 32'sd0;
    assign partial_sum_2_wr  			= multiplier_wr[2]  ? ($signed(multiplicand_wr) << 2)  : 32'sd0;
    assign partial_sum_3_wr  			= multiplier_wr[3]  ? ($signed(multiplicand_wr) << 3)  : 32'sd0;
    assign partial_sum_4_wr  			= multiplier_wr[4]  ? ($signed(multiplicand_wr) << 4)  : 32'sd0;
    assign partial_sum_5_wr  			= multiplier_wr[5]  ? ($signed(multiplicand_wr) << 5)  : 32'sd0;
    assign partial_sum_6_wr  			= multiplier_wr[6]  ? ($signed(multiplicand_wr) << 6)  : 32'sd0;
    assign partial_sum_7_wr  			= multiplier_wr[7]  ? ($signed(multiplicand_wr) << 7)  : 32'sd0;
	assign partial_sum_8_wr  			= multiplier_wr[8]  ? ($signed(multiplicand_wr) << 8)  : 32'sd0;

    // Summing up the partial products and adding the accumulation value
    assign sum_stage1_wr = partial_sum_0_wr + partial_sum_1_wr + partial_sum_2_wr + partial_sum_3_wr +
                           partial_sum_4_wr + partial_sum_5_wr + partial_sum_6_wr + partial_sum_7_wr + partial_sum_8_wr;

    // Continue partial sums for the remaining bits of the multiplier (Shift-and-add, signed)
    assign partial_sum_9_wr   			= multiplier_rg[9]  ? ($signed(multiplicand_rg) << 9)  : 32'sd0;
    assign partial_sum_10_wr  			= multiplier_rg[10] ? ($signed(multiplicand_rg) << 10) : 32'sd0;
    assign partial_sum_11_wr  			= multiplier_rg[11] ? ($signed(multiplicand_rg) << 11) : 32'sd0;
    assign partial_sum_12_wr  			= multiplier_rg[12] ? ($signed(multiplicand_rg) << 12) : 32'sd0;
    assign partial_sum_13_wr  			= multiplier_rg[13] ? ($signed(multiplicand_rg) << 13) : 32'sd0;
    assign partial_sum_14_wr  			= multiplier_rg[14] ? ($signed(multiplicand_rg) << 14) : 32'sd0;
    assign partial_sum_15_wr  			= multiplier_rg[15] ? ($signed(multiplicand_rg) << 15) : 32'sd0;

    // Final summation stage (signed)
    assign sum_stage2_wr 				= partial_sum_9_wr + partial_sum_10_wr + partial_sum_11_wr +
										partial_sum_12_wr + partial_sum_13_wr + partial_sum_14_wr + partial_sum_15_wr + sum_stage1_rg;
	assign D0_wr						= (both_negative_rg) ? $signed(sum_stage2_wr[21:6]) : -$signed(sum_stage2_wr[21:6]);
    // Clocked process
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            sum_stage1_rg       <= 0;
            multiplicand_rg     <= 0;
            multiplier_rg       <= 0;
            S0_valid_rg         <= 0;
            S1_valid_rg         <= 0;
            S2_valid_rg         <= 0;
            D0_out              <= 0;
			both_negative_rg	<= 0;
			accumulation_rg		<= 0;
        end 
        else begin
            sum_stage1_rg       <= sum_stage1_wr;
            multiplicand_rg     <= multiplicand_wr;
            multiplier_rg       <= abs_S1_in;
            S0_valid_rg         <= S0_valid_in;
            S1_valid_rg         <= S1_valid_in;
            S2_valid_rg         <= S2_valid_in;
			both_negative_rg	<= both_negative_wr;
			accumulation_rg		<= S2_in;  // Sign-extend S2_in to 32 bits

            // Adjust the output scaling to maintain the fixed-point format: 1 sign, 9 integer, 6 fractional bits
			D0_out              <= D0_wr + accumulation_rg;
            D0_valid            <= S0_valid_rg & S1_valid_rg & S2_valid_rg;
        end
    end
    
endmodule
