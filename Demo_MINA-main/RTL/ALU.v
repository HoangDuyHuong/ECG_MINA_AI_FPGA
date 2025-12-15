/*
 *-----------------------------------------------------------------------------
 * Title         : ALU
 * Project       : CGRA_ECG
 *-----------------------------------------------------------------------------
 * File          : ALU.v
 * Author        : Pham Hoai Luan
 *                <pham.luan@is.naist.jp>
 * Created       : 2024.10.15
 *-----------------------------------------------------------------------------
 * Last modified : 2024.10.15
 * Copyright (c) 2024 by NAIST This model is the confidential and
 * proprietary property of NAIST and the possession or use of this
 * file requires a written license from NAIST.
 *-----------------------------------------------------------------------------
 * Modification history :
 * 2024.10.15 : created
 *-----------------------------------------------------------------------------
 */
 
`timescale 1ns/1ns
`include "common.vh"

module ALU
(
	input  wire                                 CLK,
	input  wire                                 RST,
	
	//-----------------------------------------------------//
	//          			Input Signals                  // 
	//-----------------------------------------------------//
	input  wire 					            En_in,
	input  wire signed [`ALU_CFG_BITS-2:0]      CFG_in,
	input  wire 					            ReLU_en_in,
	input  wire 					            S0_valid_in,
	input  wire signed [`WORD_BITS-1:0]         S0_in,
	input  wire 					            S1_valid_in,
	input  wire signed [`WORD_BITS-1:0]         S1_in,
	input  wire 					            S2_valid_in,
	input  wire signed [`WORD_BITS-1:0]         S2_in,
	//-----------------------------------------------------//
	//          			Output Signals                 // 
	//-----------------------------------------------------//
	output wire signed [`WORD_BITS-1:0]         D0_out,
	output wire  					           	Valid_out
);

	// *************** Wire signals *************** //
	wire signed [`WORD_BITS-1:0]      			MAC_wr;
	wire 				      					MAC_valid_wr;
	wire signed [`WORD_BITS-1:0]      			Max_wr;
	wire 				      					Max_valid_wr;
	
	wire signed [`WORD_BITS-1:0]				S1_wr;
	
	// *************** Register signals *************** //
	reg signed [`WORD_BITS-1:0]      			D0_rg;
	reg 				      					D0_valid_rg;
	reg [`ALU_CFG_BITS-2:0]             		CFG_1_rg, CFG_2_rg;
	reg											En_1_rg, En_2_rg; 

	assign S1_wr			= (CFG_in[`ALU_CFG_BITS-2:0] == `EXE_ADD) ? 16'h0040 : S1_in;
	
	MAC mac
	(
    .CLK(CLK),                      
    .RST(RST),
	.ReLU_en_in(ReLU_en_in),
    .S0_valid_in(S0_valid_in),        
    .S0_in(S0_in),  
    .S1_valid_in(S1_valid_in),        
    .S1_in(S1_wr),  
    .S2_valid_in(S2_valid_in),        
    .S2_in(S2_in), 
    .D0_valid(MAC_valid_wr),  
    .D0_out(MAC_wr)  
	);

	MaxValue max (
		.CLK(CLK),                    
		.RST(RST),   
		.S0_valid_in(S0_valid_in),	
		.S0_in(S0_in),
		.S1_valid_in(S1_valid_in),	
		.S1_in(S1_in),    
		.S2_valid_in(S2_valid_in),	
		.S2_in(S2_in), 
		.Max_valid_out(Max_valid_wr),
		.Max_out(Max_wr)
	);
 
    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            CFG_1_rg 		<= 0; 
			CFG_2_rg		<= 0;
			
            CFG_1_rg 		<= 0; 
			CFG_2_rg		<= 0;
        end
        else begin
			CFG_1_rg 		<= CFG_in; 
			CFG_2_rg		<= CFG_1_rg;
			
			En_1_rg 		<= En_in; 
			En_2_rg			<= En_1_rg;
        end
    end
	
	always @(*) begin
		case (CFG_2_rg)
			`EXE_NOP: begin   ///*** No Operation ***///
				D0_rg 		= 0;
				D0_valid_rg	= 0;
			end
			`EXE_MAC: begin   ///*** Mutiply-Adder Operation ***///
				D0_rg 		= MAC_wr; 
				D0_valid_rg	= MAC_valid_wr;
			end
			`EXE_ADD: begin   ///*** Adder Operation ***///
				D0_rg 		= MAC_wr; 
				D0_valid_rg	= MAC_valid_wr;
			end
			`EXE_MP: begin   ///*** Max Pooling Operation ***///
				D0_rg 		= Max_wr; 
				D0_valid_rg	= Max_valid_wr;
			end
			default: begin
				D0_rg 		= 0;
				D0_valid_rg	= 0;
			end
		endcase
	end

	assign D0_out 			= (En_2_rg == 1) ? D0_rg : 0;
	assign Valid_out		= (En_2_rg == 1) ? D0_valid_rg : 0;
	
endmodule

module MaxValue (
    input wire 								CLK,                    
    input wire 								RST,   
	input wire 								S0_valid_in,	
    input wire signed [`WORD_BITS-1:0]  	S0_in,    // Fixed-point input: 1 sign bit, 9 integer bits, 6 fractional bits
	input wire 								S1_valid_in,	
    input wire signed [`WORD_BITS-1:0]  	S1_in,    // Fixed-point input: 1 sign bit, 9 integer bits, 6 fractional bits
	input wire 								S2_valid_in,	
    input wire signed [`WORD_BITS-1:0]  	S2_in,    // Fixed-point input: 1 sign bit, 9 integer bits, 6 fractional bits
	output reg  					        Max_valid_out,
    output reg signed [`WORD_BITS-1:0]  	Max_out   // Fixed-point output: 1 sign bit, 9 integer bits, 6 fractional bits
);

    // Define the fixed-point representation of -10 (16-bit fixed-point: 1 sign, 9 integer, 6 fractional)
    localparam signed [`WORD_BITS-1:0]		NEG_TEN = -10 << 6; // Shift by 6 to represent -10 in 6 fractional bits

    // *************** Wire signals *************** //    
    wire signed [`WORD_BITS-1:0] 			max_S0_S1_S2_wr;
	wire signed [`WORD_BITS-1:0] 			max_final_wr;
	
	// *************** Register signals *************** //
	reg signed [`WORD_BITS-1:0] 			max_S0_S1_rg;
	reg signed [`WORD_BITS-1:0] 			S2_rg;
	reg										S0_valid_rg, S1_valid_rg, S2_valid_rg;
	
    // Find the maximum value between max_S0_S1 and S2
    assign max_S0_S1_S2_wr = (max_S0_S1_rg > S2_rg) ? max_S0_S1_rg : S2_rg;
	assign max_final_wr = (max_S0_S1_S2_wr < NEG_TEN) ? NEG_TEN : max_S0_S1_S2_wr;
	
    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            max_S0_S1_rg		<= 16'sd0;
			S2_rg				<= 16'sd0;
			S0_valid_rg			<= 0;
			S1_valid_rg			<= 0;
			S2_valid_rg			<= 0;
			Max_valid_out		<= 0;
			Max_out				<= 0;
        end
        else begin
			S2_rg 				<= S2_in;
			
			S0_valid_rg			<= S0_valid_in;
			S1_valid_rg			<= S1_valid_in;
			S2_valid_rg			<= S2_valid_in;
			
			if(S0_in > S1_in)
				max_S0_S1_rg 	<= S0_in;
			else 
				max_S0_S1_rg 	<= S1_in;
				
			Max_valid_out 		<= S0_valid_rg & S1_valid_rg & S2_valid_rg;
			Max_out 			<= max_final_wr;
        end
    end 

endmodule

module MAC (
    input wire                          CLK,                      
    input wire                          RST,
	input wire							ReLU_en_in,
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
	wire signed [`WORD_BITS-1:0]		sum_final_wr;
    wire signed [`WORD_BITS-1:0]        multiplier_wr;       
	wire signed [`WORD_BITS-1:0]      	bias_wr;
	wire 								both_negative_wr;
	wire signed [`WORD_BITS-1:0]  		D0_wr, D0_ReLU_wr;

    // *************** Register signals *************** //
	reg signed [`WORD_BITS-1:0]      	accumulation_rg;
	reg signed [`WORD_BITS-1:0]      	bias_rg;
    reg signed [`WORD_BITS*2-1:0]       sum_stage1_rg;
    reg signed [`WORD_BITS*2-1:0]       multiplicand_rg;
    reg signed [`WORD_BITS-1:0]         multiplier_rg; 
    reg                                 S0_valid_rg, S1_valid_rg, S2_valid_rg;
	reg 								both_negative_rg;
	reg 								ReLU_en_rg;

    // Check if both S0 and S1 are negative
    wire signed [`WORD_BITS-1:0] abs_S0_in = (S0_in < 0) ? -S0_in : S0_in;
    wire signed [`WORD_BITS-1:0] abs_S1_in = (S1_in < 0) ? -S1_in : S1_in;
	
    assign both_negative_wr	 			= ((S0_in < 0) && (S1_in < 0))|((S0_in > 0) && (S1_in > 0));

    // Sign-extend inputs to 32 bits using the absolute values if both are negative
    assign multiplicand_wr   			= {{16{abs_S0_in[`WORD_BITS-1]}}, abs_S0_in};  // Sign-extend absolute S0_in to 32 bits
    assign multiplier_wr     			= abs_S1_in;  // No need to extend, keeping 16 bits

    // Generate partial sums (Shift-and-add, signed)
    // assign partial_sum_0_wr  			= multiplier_wr[0]  ? $signed(multiplicand_wr) : 32'sd0;
	assign partial_sum_0_wr  			= multiplier_wr[0]  ? multiplicand_wr : 32'sd0;
    assign partial_sum_1_wr  			= multiplier_wr[1]  ? ($signed(multiplicand_wr) << 1)  : 32'sd0;
    assign partial_sum_2_wr  			= multiplier_wr[2]  ? ($signed(multiplicand_wr) << 2)  : 32'sd0;
    assign partial_sum_3_wr  			= multiplier_wr[3]  ? ($signed(multiplicand_wr) << 3)  : 32'sd0;
    assign partial_sum_4_wr  			= multiplier_wr[4]  ? ($signed(multiplicand_wr) << 4)  : 32'sd0;
    assign partial_sum_5_wr  			= multiplier_wr[5]  ? ($signed(multiplicand_wr) << 5)  : 32'sd0;
    assign partial_sum_6_wr  			= multiplier_wr[6]  ? ($signed(multiplicand_wr) << 6)  : 32'sd0;
    assign partial_sum_7_wr  			= multiplier_wr[7]  ? ($signed(multiplicand_wr) << 7)  : 32'sd0;
	assign partial_sum_8_wr  			= multiplier_wr[8]  ? ($signed(multiplicand_wr) << 8)  : 32'sd0;
	assign partial_sum_9_wr   			= multiplier_wr[9]  ? ($signed(multiplicand_wr) << 9)  : 32'sd0;
    // Summing up the partial products and adding the accumulation value
    assign sum_stage1_wr = partial_sum_0_wr + partial_sum_1_wr + partial_sum_2_wr + partial_sum_3_wr + partial_sum_4_wr 
							+ partial_sum_5_wr + partial_sum_6_wr + partial_sum_7_wr + partial_sum_8_wr + partial_sum_9_wr;

    // Continue partial sums for the remaining bits of the multiplier (Shift-and-add, signed)
    
    assign partial_sum_10_wr  			= multiplier_rg[10] ? ($signed(multiplicand_rg) << 10) : 32'sd0;
    assign partial_sum_11_wr  			= multiplier_rg[11] ? ($signed(multiplicand_rg) << 11) : 32'sd0;
    assign partial_sum_12_wr  			= multiplier_rg[12] ? ($signed(multiplicand_rg) << 12) : 32'sd0;
    assign partial_sum_13_wr  			= multiplier_rg[13] ? ($signed(multiplicand_rg) << 13) : 32'sd0;
    assign partial_sum_14_wr  			= multiplier_rg[14] ? ($signed(multiplicand_rg) << 14) : 32'sd0;
    assign partial_sum_15_wr  			= multiplier_rg[15] ? ($signed(multiplicand_rg) << 15) : 32'sd0;

    // Final summation stage (signed)
    assign sum_stage2_wr 				= partial_sum_10_wr + partial_sum_11_wr + partial_sum_12_wr + partial_sum_13_wr 
										+ partial_sum_14_wr + partial_sum_15_wr + sum_stage1_rg;
	// assign sum_final_wr					= (both_negative_rg) ? $signed(sum_stage2_wr[21:6]+(sum_stage2_wr[5:5]&(sum_stage2_wr[4:4]^sum_stage2_wr[3:3]))) : -$signed(sum_stage2_wr[21:6]+(sum_stage2_wr[5:5]&(sum_stage2_wr[4:4]^sum_stage2_wr[3:3])));
	// assign sum_final_wr					= (both_negative_rg) ? $signed(sum_stage2_wr[21:6]+sum_stage2_wr[5:5]) : -$signed(sum_stage2_wr[21:6]+sum_stage2_wr[5:5]);
	
	assign sum_final_wr					= (both_negative_rg) ? $signed(sum_stage2_wr[21:6]+sum_stage2_wr[5:5]) : -$signed(sum_stage2_wr[21:6]+sum_stage2_wr[5:5]);
		
	assign bias_wr						= (S2_valid_rg) ? bias_rg : 0;
	
	assign D0_wr						= sum_final_wr + accumulation_rg + bias_wr;
	
	assign D0_ReLU_wr					= (ReLU_en_rg & D0_wr[`WORD_BITS-1:`WORD_BITS-1]) ? 0 : D0_wr;
    // Clocked process
    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            sum_stage1_rg       		<= 0;
            multiplicand_rg     		<= 0;
            multiplier_rg       		<= 0;
            S0_valid_rg         		<= 0;
            S1_valid_rg         		<= 0;
            S2_valid_rg         		<= 0;
            D0_out              		<= 0;
			both_negative_rg			<= 0;
			accumulation_rg				<= 0;
			bias_rg						<= 0;
			D0_valid            		<= 0;
			ReLU_en_rg					<= 0;
        end 		
        else begin		
            sum_stage1_rg       		<= sum_stage1_wr;
            multiplicand_rg     		<= multiplicand_wr;
            multiplier_rg       		<= abs_S1_in;
            S0_valid_rg         		<= S0_valid_in;
            S1_valid_rg         		<= S1_valid_in;
            S2_valid_rg         		<= S2_valid_in;
			bias_rg						<= S2_in;
			both_negative_rg			<= both_negative_wr;
			if(S2_valid_rg) begin
				accumulation_rg			<= 0;  
			end                         
			else if(S0_valid_rg|S1_valid_rg)  begin                  
				accumulation_rg			<= D0_wr;  
			end
			else begin
				accumulation_rg			<= 0;
			end
			ReLU_en_rg					<= ReLU_en_in;

            // Adjust the output scaling to maintain the fixed-point format: 1 sign, 9 integer, 6 fractional bits
			D0_out              		<= D0_ReLU_wr;
            D0_valid            		<= S2_valid_rg;
        end
    end
    
endmodule
