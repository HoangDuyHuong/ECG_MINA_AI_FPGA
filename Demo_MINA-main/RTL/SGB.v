/*
 *-----------------------------------------------------------------------------
 * Title         : Shared Global Buffer
 * Project       : CGRA_ECG
 *-----------------------------------------------------------------------------
 * File          : SGB.v
 * Author        : Pham Hoai Luan
 *                <pham.luan@is.naist.jp>
 * Created       : 2024.10.23
 *-----------------------------------------------------------------------------
 * Last modified : 2024.10.23
 * Copyright (c) 2024 by NAIST This model is the confidential and
 * proprietary property of NAIST and the possession or use of this
 * file requires a written license from NAIST.
 *-----------------------------------------------------------------------------
 * Modification history :
 * 2024.10.23 : created
 *-----------------------------------------------------------------------------
 */
 
`timescale 1ns/1ns
`include "common.vh"

module SGB
(
	input  wire                                 	CLK,
	input  wire                                 	RST,
	
	//-----------------------------------------------------//
	//          			Input Signals                    // 
	//-----------------------------------------------------//
	
	///*** From PEs ***///
	
	input wire signed [`WORD_BITS-1:0]           	PE0_Pixel_0_in,
	input wire 						           		PE0_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE0_Pixel_1_in,
	input wire 						           		PE0_Pixel_1_valid_in,

	input wire signed [`WORD_BITS-1:0]           	PE1_Pixel_0_in,
	input wire 						           		PE1_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE1_Pixel_1_in,
	input wire 						           		PE1_Pixel_1_valid_in,

	input wire signed [`WORD_BITS-1:0]           	PE2_Pixel_0_in,
	input wire 						           		PE2_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE2_Pixel_1_in,
	input wire 						           		PE2_Pixel_1_valid_in,

	input wire signed [`WORD_BITS-1:0]           	PE3_Pixel_0_in,
	input wire 						           		PE3_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE3_Pixel_1_in,
	input wire 						           		PE3_Pixel_1_valid_in,

	input wire signed [`WORD_BITS-1:0]           	PE4_Pixel_0_in,
	input wire 						           		PE4_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE4_Pixel_1_in,
	input wire 						           		PE4_Pixel_1_valid_in,

	input wire signed [`WORD_BITS-1:0]           	PE5_Pixel_0_in,
	input wire 						           		PE5_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE5_Pixel_1_in,
	input wire 						           		PE5_Pixel_1_valid_in,	
	
	input wire signed [`WORD_BITS-1:0]           	PE6_Pixel_0_in,
	input wire 						           		PE6_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE6_Pixel_1_in,
	input wire 						           		PE6_Pixel_1_valid_in,	

	input wire signed [`WORD_BITS-1:0]           	PE7_Pixel_0_in,
	input wire 						           		PE7_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE7_Pixel_1_in,
	input wire 						           		PE7_Pixel_1_valid_in,	

	input wire signed [`WORD_BITS-1:0]           	PE8_Pixel_0_in,
	input wire 						           		PE8_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE8_Pixel_1_in,
	input wire 						           		PE8_Pixel_1_valid_in,	

	input wire signed [`WORD_BITS-1:0]           	PE9_Pixel_0_in,
	input wire 						           		PE9_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE9_Pixel_1_in,
	input wire 						           		PE9_Pixel_1_valid_in,

	input wire signed [`WORD_BITS-1:0]           	PE10_Pixel_0_in,
	input wire 						           		PE10_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE10_Pixel_1_in,
	input wire 						           		PE10_Pixel_1_valid_in,
													 
	input wire signed [`WORD_BITS-1:0]           	PE11_Pixel_0_in,
	input wire 						           		PE11_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE11_Pixel_1_in,
	input wire 						           		PE11_Pixel_1_valid_in,
													 
	input wire signed [`WORD_BITS-1:0]           	PE12_Pixel_0_in,
	input wire 						           		PE12_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE12_Pixel_1_in,
	input wire 						           		PE12_Pixel_1_valid_in,
													 
	input wire signed [`WORD_BITS-1:0]           	PE13_Pixel_0_in,
	input wire 						           		PE13_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE13_Pixel_1_in,
	input wire 						           		PE13_Pixel_1_valid_in,
													 
	input wire signed [`WORD_BITS-1:0]           	PE14_Pixel_0_in,
	input wire 						           		PE14_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE14_Pixel_1_in,
	input wire 						           		PE14_Pixel_1_valid_in,
													 
	input wire signed [`WORD_BITS-1:0]           	PE15_Pixel_0_in,
	input wire 						           		PE15_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE15_Pixel_1_in,
	input wire 						           		PE15_Pixel_1_valid_in,	
													
	input wire signed [`WORD_BITS-1:0]           	PE16_Pixel_0_in,
	input wire 						           		PE16_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE16_Pixel_1_in,
	input wire 						           		PE16_Pixel_1_valid_in,	
													  
	input wire signed [`WORD_BITS-1:0]           	PE17_Pixel_0_in,
	input wire 						           		PE17_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE17_Pixel_1_in,
	input wire 						           		PE17_Pixel_1_valid_in,	
													 
	input wire signed [`WORD_BITS-1:0]           	PE18_Pixel_0_in,
	input wire 						           		PE18_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE18_Pixel_1_in,
	input wire 						           		PE18_Pixel_1_valid_in,	
													 
	input wire signed [`WORD_BITS-1:0]           	PE19_Pixel_0_in,
	input wire 						           		PE19_Pixel_0_valid_in,
	input wire signed [`WORD_BITS-1:0]           	PE19_Pixel_1_in,
	input wire 						           		PE19_Pixel_1_valid_in,	
	///*** From the Controller ***///
	input  wire 					      			En_in,
	input  wire [`ALU_CFG_BITS-2:0]      			CFG_in,
	input  wire [`PE_NUM_BITS-1:0]  				MUX_Selection_in, //5
	input  wire 					              	Parity_PE_Selection_in, //0 -> Even PEs, 1 -> Odd PEs
	input  wire 					              	Stride_in, //0 -> 1, 1 -> 2
	input  wire 					              	MP_Padding_in, 
	input  wire										MP_Padding_2_in,
	input  wire										MP_Padding_3_in,
	//-----------------------------------------------------//
	//          			Output Signals                   // 
	//-----------------------------------------------------//  
	
	output reg signed [`WORD_BITS-1:0]           	PE0_Pixel_0_out,
	output reg 						           		PE0_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE0_Pixel_1_out,
	output reg 						           		PE0_Pixel_1_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE0_Pixel_2_out,
	output reg 						           		PE0_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE1_Pixel_0_out,
	output reg 						           		PE1_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE1_Pixel_1_out,
	output reg 						           		PE1_Pixel_1_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE1_Pixel_2_out,
	output reg 						           		PE1_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE2_Pixel_0_out,
	output reg 						           		PE2_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE2_Pixel_1_out,
	output reg 						           		PE2_Pixel_1_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE2_Pixel_2_out,
	output reg 						           		PE2_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE3_Pixel_0_out,
	output reg 						           		PE3_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE3_Pixel_1_out,
	output reg 						           		PE3_Pixel_1_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE3_Pixel_2_out,
	output reg 						           		PE3_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE4_Pixel_0_out,
	output reg 						           		PE4_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE4_Pixel_1_out,
	output reg 						           		PE4_Pixel_1_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE4_Pixel_2_out,
	output reg 						           		PE4_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE5_Pixel_0_out,
	output reg 						           		PE5_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE5_Pixel_1_out,
	output reg 						           		PE5_Pixel_1_valid_out,	
	output reg signed [`WORD_BITS-1:0]           	PE5_Pixel_2_out,
	output reg 						           		PE5_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE6_Pixel_0_out,
	output reg 						           		PE6_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE6_Pixel_1_out,
	output reg 						           		PE6_Pixel_1_valid_out,	
	output reg signed [`WORD_BITS-1:0]           	PE6_Pixel_2_out,
	output reg 						           		PE6_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE7_Pixel_0_out,
	output reg 						           		PE7_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE7_Pixel_1_out,
	output reg 						           		PE7_Pixel_1_valid_out,	
	output reg signed [`WORD_BITS-1:0]           	PE7_Pixel_2_out,
	output reg 						           		PE7_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE8_Pixel_0_out,
	output reg 						           		PE8_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE8_Pixel_1_out,
	output reg 						           		PE8_Pixel_1_valid_out,	
	output reg signed [`WORD_BITS-1:0]           	PE8_Pixel_2_out,
	output reg 						           		PE8_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE9_Pixel_0_out,
	output reg 						           		PE9_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE9_Pixel_1_out,
	output reg 						           		PE9_Pixel_1_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE9_Pixel_2_out,
	output reg 						           		PE9_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE10_Pixel_0_out,
	output reg 						           		PE10_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE10_Pixel_1_out,
	output reg 						           		PE10_Pixel_1_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE10_Pixel_2_out,
	output reg 						           		PE10_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE11_Pixel_0_out,
	output reg 						           		PE11_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE11_Pixel_1_out,
	output reg 						           		PE11_Pixel_1_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE11_Pixel_2_out,
	output reg 						           		PE11_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE12_Pixel_0_out,
	output reg 						           		PE12_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE12_Pixel_1_out,
	output reg 						           		PE12_Pixel_1_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE12_Pixel_2_out,
	output reg 						           		PE12_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE13_Pixel_0_out,
	output reg 						           		PE13_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE13_Pixel_1_out,
	output reg 						           		PE13_Pixel_1_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE13_Pixel_2_out,
	output reg 						           		PE13_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE14_Pixel_0_out,
	output reg 						           		PE14_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE14_Pixel_1_out,
	output reg 						           		PE14_Pixel_1_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE14_Pixel_2_out,
	output reg 						           		PE14_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE15_Pixel_0_out,
	output reg 						           		PE15_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE15_Pixel_1_out,
	output reg 						           		PE15_Pixel_1_valid_out,	
	output reg signed [`WORD_BITS-1:0]           	PE15_Pixel_2_out,
	output reg 						           		PE15_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE16_Pixel_0_out,
	output reg 						           		PE16_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE16_Pixel_1_out,
	output reg 						           		PE16_Pixel_1_valid_out,	
	output reg signed [`WORD_BITS-1:0]           	PE16_Pixel_2_out,
	output reg 						           		PE16_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE17_Pixel_0_out,
	output reg 						           		PE17_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE17_Pixel_1_out,
	output reg 						           		PE17_Pixel_1_valid_out,	
	output reg signed [`WORD_BITS-1:0]           	PE17_Pixel_2_out,
	output reg 						           		PE17_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE18_Pixel_0_out,
	output reg 						           		PE18_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE18_Pixel_1_out,
	output reg 						           		PE18_Pixel_1_valid_out,	
	output reg signed [`WORD_BITS-1:0]           	PE18_Pixel_2_out,
	output reg 						           		PE18_Pixel_2_valid_out,
	
	output reg signed [`WORD_BITS-1:0]           	PE19_Pixel_0_out,
	output reg 						           		PE19_Pixel_0_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE19_Pixel_1_out,
	output reg 						           		PE19_Pixel_1_valid_out,
	output reg signed [`WORD_BITS-1:0]           	PE19_Pixel_2_out,
	output reg 						           		PE19_Pixel_2_valid_out
);
 
	// *************** Wire signals *************** //
	wire signed [`WORD_BITS-1:0]	           		PE0_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE1_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE2_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE3_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE4_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE5_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE6_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE7_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE8_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE9_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE10_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE11_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE12_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE13_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE14_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE15_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE16_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE17_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE18_Pixel_to_MUX_wr;
	wire signed [`WORD_BITS-1:0]	           		PE19_Pixel_to_MUX_wr;
	
	wire signed [`WORD_BITS-1:0]	           		PE0_Pixel_0_out_wr;
	wire 						           			PE0_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE0_Pixel_1_out_wr;
	wire 						           			PE0_Pixel_1_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE0_Pixel_2_out_wr;
	wire 						           			PE0_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE1_Pixel_0_out_wr;
	wire 						           			PE1_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE1_Pixel_1_out_wr;
	wire 						           			PE1_Pixel_1_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE1_Pixel_2_out_wr;
	wire 						           			PE1_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE2_Pixel_0_out_wr;
	wire 						           			PE2_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE2_Pixel_1_out_wr;
	wire 						           			PE2_Pixel_1_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE2_Pixel_2_out_wr;
	wire 						           			PE2_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE3_Pixel_0_out_wr;
	wire 						           			PE3_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE3_Pixel_1_out_wr;
	wire 						           			PE3_Pixel_1_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE3_Pixel_2_out_wr;
	wire 						           			PE3_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE4_Pixel_0_out_wr;
	wire 						           			PE4_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE4_Pixel_1_out_wr;
	wire 						           			PE4_Pixel_1_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE4_Pixel_2_out_wr;
	wire 						           			PE4_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE5_Pixel_0_out_wr;
	wire 						           			PE5_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE5_Pixel_1_out_wr;
	wire 						           			PE5_Pixel_1_valid_out_wr;	
	wire signed [`WORD_BITS-1:0]	           		PE5_Pixel_2_out_wr;
	wire 						           			PE5_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE6_Pixel_0_out_wr;
	wire 						           			PE6_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE6_Pixel_1_out_wr;
	wire 						           			PE6_Pixel_1_valid_out_wr;	
	wire signed [`WORD_BITS-1:0]	           		PE6_Pixel_2_out_wr;
	wire 						           			PE6_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE7_Pixel_0_out_wr;
	wire 						           			PE7_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE7_Pixel_1_out_wr;
	wire 						           			PE7_Pixel_1_valid_out_wr;	
	wire signed [`WORD_BITS-1:0]	           		PE7_Pixel_2_out_wr;
	wire 						           			PE7_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE8_Pixel_0_out_wr;
	wire 						           			PE8_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE8_Pixel_1_out_wr;
	wire 						           			PE8_Pixel_1_valid_out_wr;	
	wire signed [`WORD_BITS-1:0]	           		PE8_Pixel_2_out_wr;
	wire 						           			PE8_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE9_Pixel_0_out_wr;
	wire 						           			PE9_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE9_Pixel_1_out_wr;
	wire 						           			PE9_Pixel_1_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE9_Pixel_2_out_wr;
	wire 						           			PE9_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE10_Pixel_0_out_wr;
	wire 						           			PE10_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE10_Pixel_1_out_wr;
	wire 						           			PE10_Pixel_1_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE10_Pixel_2_out_wr;
	wire 						           			PE10_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE11_Pixel_0_out_wr;
	wire 						           			PE11_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE11_Pixel_1_out_wr;
	wire 						           			PE11_Pixel_1_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE11_Pixel_2_out_wr;
	wire 						           			PE11_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE12_Pixel_0_out_wr;
	wire 						           			PE12_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE12_Pixel_1_out_wr;
	wire 						           			PE12_Pixel_1_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE12_Pixel_2_out_wr;
	wire 						           			PE12_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE13_Pixel_0_out_wr;
	wire 						           			PE13_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE13_Pixel_1_out_wr;
	wire 						           			PE13_Pixel_1_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE13_Pixel_2_out_wr;
	wire 						           			PE13_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE14_Pixel_0_out_wr;
	wire 						           			PE14_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE14_Pixel_1_out_wr;
	wire 						           			PE14_Pixel_1_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE14_Pixel_2_out_wr;
	wire 						           			PE14_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE15_Pixel_0_out_wr;
	wire 						           			PE15_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE15_Pixel_1_out_wr;
	wire 						           			PE15_Pixel_1_valid_out_wr;	
	wire signed [`WORD_BITS-1:0]	           		PE15_Pixel_2_out_wr;
	wire 						           			PE15_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE16_Pixel_0_out_wr;
	wire 						           			PE16_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE16_Pixel_1_out_wr;
	wire 						           			PE16_Pixel_1_valid_out_wr;	
	wire signed [`WORD_BITS-1:0]	           		PE16_Pixel_2_out_wr;
	wire 						           			PE16_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE17_Pixel_0_out_wr;
	wire 						           			PE17_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE17_Pixel_1_out_wr;
	wire 						           			PE17_Pixel_1_valid_out_wr;	
	wire signed [`WORD_BITS-1:0]	           		PE17_Pixel_2_out_wr;
	wire 						           			PE17_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE18_Pixel_0_out_wr;
	wire 						           			PE18_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE18_Pixel_1_out_wr;
	wire 						           			PE18_Pixel_1_valid_out_wr;	
	wire signed [`WORD_BITS-1:0]	           		PE18_Pixel_2_out_wr;
	wire 						           			PE18_Pixel_2_valid_out_wr;
		
	wire signed [`WORD_BITS-1:0]	           		PE19_Pixel_0_out_wr;
	wire 						           			PE19_Pixel_0_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE19_Pixel_1_out_wr;
	wire 						           			PE19_Pixel_1_valid_out_wr;
	wire signed [`WORD_BITS-1:0]	           		PE19_Pixel_2_out_wr;
	wire 						           			PE19_Pixel_2_valid_out_wr;
	
	// *************** Register signals *************** //
	reg												Parity_PE_Selection_rg;

	
	assign PE0_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE0_Pixel_0_in: 
								 ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE1_Pixel_0_in: PE0_Pixel_0_in;
								 
	assign PE1_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE2_Pixel_0_in: 
								 ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE3_Pixel_0_in: PE1_Pixel_0_in;	
								 
	assign PE2_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE4_Pixel_0_in: 
								 ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE5_Pixel_0_in: PE2_Pixel_0_in;
								 
	assign PE3_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE6_Pixel_0_in: 
								 ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE7_Pixel_0_in: PE3_Pixel_0_in;

	assign PE4_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE8_Pixel_0_in: 
								 ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE9_Pixel_0_in: PE4_Pixel_0_in;
								 
	assign PE5_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE10_Pixel_0_in: 
								 ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE11_Pixel_0_in: PE5_Pixel_0_in;

	assign PE6_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE12_Pixel_0_in: 
								 ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE13_Pixel_0_in: PE6_Pixel_0_in;
								 
	assign PE7_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE14_Pixel_0_in: 
								 ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE15_Pixel_0_in: PE7_Pixel_0_in;

	assign PE8_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE16_Pixel_0_in: 
								 ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE17_Pixel_0_in: PE8_Pixel_0_in;
								 
	assign PE9_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE18_Pixel_0_in: 
								 ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE19_Pixel_0_in: PE9_Pixel_0_in;

	assign PE10_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE0_Pixel_1_in: 
								  ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE1_Pixel_1_in: PE10_Pixel_0_in;
																														  
	assign PE11_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE2_Pixel_1_in: 
								  ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE3_Pixel_1_in: PE11_Pixel_0_in;	
																														   
	assign PE12_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE4_Pixel_1_in: 
								  ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE5_Pixel_1_in: PE12_Pixel_0_in;
																														   
	assign PE13_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE6_Pixel_1_in: 
								  ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE7_Pixel_1_in: PE13_Pixel_0_in;
																														   
	assign PE14_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE8_Pixel_1_in: 
								  ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE9_Pixel_1_in: PE14_Pixel_0_in;
								 
	assign PE15_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE10_Pixel_1_in: 
								  ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE11_Pixel_1_in: PE15_Pixel_0_in;
																															
	assign PE16_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE12_Pixel_1_in: 
								  ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE13_Pixel_1_in: PE16_Pixel_0_in;
																															
	assign PE17_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE14_Pixel_1_in: 
								  ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE15_Pixel_1_in: PE17_Pixel_0_in;
																															
	assign PE18_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE16_Pixel_1_in: 
								  ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE17_Pixel_1_in: PE18_Pixel_0_in;
																															
	assign PE19_Pixel_to_MUX_wr = ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 0)) ? PE18_Pixel_1_in: 
								  ((Stride_in == 1) &  (CFG_in == `EXE_MAC) && (Parity_PE_Selection_rg == 1)) ? PE19_Pixel_1_in: PE19_Pixel_0_in;		
								  
	MUX_20_1 PE0_Pixel_0(
		.data0_in(PE0_Pixel_to_MUX_wr),
		.data1_in(PE1_Pixel_to_MUX_wr),
		.data2_in(PE2_Pixel_to_MUX_wr),
		.data3_in(PE3_Pixel_to_MUX_wr),
		.data4_in(PE4_Pixel_to_MUX_wr),
		.data5_in(PE5_Pixel_to_MUX_wr),
		.data6_in(PE6_Pixel_to_MUX_wr),
		.data7_in(PE7_Pixel_to_MUX_wr),
		.data8_in(PE8_Pixel_to_MUX_wr),
		.data9_in(PE9_Pixel_to_MUX_wr),
		.data10_in(PE10_Pixel_to_MUX_wr),
		.data11_in(PE11_Pixel_to_MUX_wr),
		.data12_in(PE12_Pixel_to_MUX_wr),
		.data13_in(PE13_Pixel_to_MUX_wr),
		.data14_in(PE14_Pixel_to_MUX_wr),
		.data15_in(PE15_Pixel_to_MUX_wr),
		.data16_in(PE16_Pixel_to_MUX_wr),
		.data17_in(PE17_Pixel_to_MUX_wr),
		.data18_in(PE18_Pixel_to_MUX_wr),
		.data19_in(PE19_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE0_Pixel_0_out_wr)
	);	

	MUX_20_1 PE1_Pixel_0(
		.data0_in(PE1_Pixel_to_MUX_wr),
		.data1_in(PE2_Pixel_to_MUX_wr),
		.data2_in(PE3_Pixel_to_MUX_wr),
		.data3_in(PE4_Pixel_to_MUX_wr),
		.data4_in(PE5_Pixel_to_MUX_wr),
		.data5_in(PE6_Pixel_to_MUX_wr),
		.data6_in(PE7_Pixel_to_MUX_wr),
		.data7_in(PE8_Pixel_to_MUX_wr),
		.data8_in(PE9_Pixel_to_MUX_wr),
		.data9_in(PE10_Pixel_to_MUX_wr),
		.data10_in(PE11_Pixel_to_MUX_wr),
		.data11_in(PE12_Pixel_to_MUX_wr),
		.data12_in(PE13_Pixel_to_MUX_wr),
		.data13_in(PE14_Pixel_to_MUX_wr),
		.data14_in(PE15_Pixel_to_MUX_wr),
		.data15_in(PE16_Pixel_to_MUX_wr),
		.data16_in(PE17_Pixel_to_MUX_wr),
		.data17_in(PE18_Pixel_to_MUX_wr),
		.data18_in(PE19_Pixel_to_MUX_wr),
		.data19_in(PE0_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE1_Pixel_0_out_wr)
	);

	MUX_20_1 PE2_Pixel_0(
		.data0_in(PE2_Pixel_to_MUX_wr),
		.data1_in(PE3_Pixel_to_MUX_wr),
		.data2_in(PE4_Pixel_to_MUX_wr),
		.data3_in(PE5_Pixel_to_MUX_wr),
		.data4_in(PE6_Pixel_to_MUX_wr),
		.data5_in(PE7_Pixel_to_MUX_wr),
		.data6_in(PE8_Pixel_to_MUX_wr),
		.data7_in(PE9_Pixel_to_MUX_wr),
		.data8_in(PE10_Pixel_to_MUX_wr),
		.data9_in(PE11_Pixel_to_MUX_wr),
		.data10_in(PE12_Pixel_to_MUX_wr),
		.data11_in(PE13_Pixel_to_MUX_wr),
		.data12_in(PE14_Pixel_to_MUX_wr),
		.data13_in(PE15_Pixel_to_MUX_wr),
		.data14_in(PE16_Pixel_to_MUX_wr),
		.data15_in(PE17_Pixel_to_MUX_wr),
		.data16_in(PE18_Pixel_to_MUX_wr),
		.data17_in(PE19_Pixel_to_MUX_wr),
		.data18_in(PE0_Pixel_to_MUX_wr),
		.data19_in(PE1_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE2_Pixel_0_out_wr)
	);

	MUX_20_1 PE3_Pixel_0(
		.data0_in(PE3_Pixel_to_MUX_wr),
		.data1_in(PE4_Pixel_to_MUX_wr),
		.data2_in(PE5_Pixel_to_MUX_wr),
		.data3_in(PE6_Pixel_to_MUX_wr),
		.data4_in(PE7_Pixel_to_MUX_wr),
		.data5_in(PE8_Pixel_to_MUX_wr),
		.data6_in(PE9_Pixel_to_MUX_wr),
		.data7_in(PE10_Pixel_to_MUX_wr),
		.data8_in(PE11_Pixel_to_MUX_wr),
		.data9_in(PE12_Pixel_to_MUX_wr),
		.data10_in(PE13_Pixel_to_MUX_wr),
		.data11_in(PE14_Pixel_to_MUX_wr),
		.data12_in(PE15_Pixel_to_MUX_wr),
		.data13_in(PE16_Pixel_to_MUX_wr),
		.data14_in(PE17_Pixel_to_MUX_wr),
		.data15_in(PE18_Pixel_to_MUX_wr),
		.data16_in(PE19_Pixel_to_MUX_wr),
		.data17_in(PE0_Pixel_to_MUX_wr),
		.data18_in(PE1_Pixel_to_MUX_wr),
		.data19_in(PE2_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE3_Pixel_0_out_wr)
	);

	MUX_20_1 PE4_Pixel_0(
		.data0_in(PE4_Pixel_to_MUX_wr),
		.data1_in(PE5_Pixel_to_MUX_wr),
		.data2_in(PE6_Pixel_to_MUX_wr),
		.data3_in(PE7_Pixel_to_MUX_wr),
		.data4_in(PE8_Pixel_to_MUX_wr),
		.data5_in(PE9_Pixel_to_MUX_wr),
		.data6_in(PE10_Pixel_to_MUX_wr),
		.data7_in(PE11_Pixel_to_MUX_wr),
		.data8_in(PE12_Pixel_to_MUX_wr),
		.data9_in(PE13_Pixel_to_MUX_wr),
		.data10_in(PE14_Pixel_to_MUX_wr),
		.data11_in(PE15_Pixel_to_MUX_wr),
		.data12_in(PE16_Pixel_to_MUX_wr),
		.data13_in(PE17_Pixel_to_MUX_wr),
		.data14_in(PE18_Pixel_to_MUX_wr),
		.data15_in(PE19_Pixel_to_MUX_wr),
		.data16_in(PE0_Pixel_to_MUX_wr),
		.data17_in(PE1_Pixel_to_MUX_wr),
		.data18_in(PE2_Pixel_to_MUX_wr),
		.data19_in(PE3_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE4_Pixel_0_out_wr)
	);

	MUX_20_1 PE5_Pixel_0(
		.data0_in(PE5_Pixel_to_MUX_wr),
		.data1_in(PE6_Pixel_to_MUX_wr),
		.data2_in(PE7_Pixel_to_MUX_wr),
		.data3_in(PE8_Pixel_to_MUX_wr),
		.data4_in(PE9_Pixel_to_MUX_wr),
		.data5_in(PE10_Pixel_to_MUX_wr),
		.data6_in(PE11_Pixel_to_MUX_wr),
		.data7_in(PE12_Pixel_to_MUX_wr),
		.data8_in(PE13_Pixel_to_MUX_wr),
		.data9_in(PE14_Pixel_to_MUX_wr),
		.data10_in(PE15_Pixel_to_MUX_wr),
		.data11_in(PE16_Pixel_to_MUX_wr),
		.data12_in(PE17_Pixel_to_MUX_wr),
		.data13_in(PE18_Pixel_to_MUX_wr),
		.data14_in(PE19_Pixel_to_MUX_wr),
		.data15_in(PE0_Pixel_to_MUX_wr),
		.data16_in(PE1_Pixel_to_MUX_wr),
		.data17_in(PE2_Pixel_to_MUX_wr),
		.data18_in(PE3_Pixel_to_MUX_wr),
		.data19_in(PE4_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE5_Pixel_0_out_wr)
	);

	MUX_20_1 PE6_Pixel_0(
		.data0_in(PE6_Pixel_to_MUX_wr),
		.data1_in(PE7_Pixel_to_MUX_wr),
		.data2_in(PE8_Pixel_to_MUX_wr),
		.data3_in(PE9_Pixel_to_MUX_wr),
		.data4_in(PE10_Pixel_to_MUX_wr),
		.data5_in(PE11_Pixel_to_MUX_wr),
		.data6_in(PE12_Pixel_to_MUX_wr),
		.data7_in(PE13_Pixel_to_MUX_wr),
		.data8_in(PE14_Pixel_to_MUX_wr),
		.data9_in(PE15_Pixel_to_MUX_wr),
		.data10_in(PE16_Pixel_to_MUX_wr),
		.data11_in(PE17_Pixel_to_MUX_wr),
		.data12_in(PE18_Pixel_to_MUX_wr),
		.data13_in(PE19_Pixel_to_MUX_wr),
		.data14_in(PE0_Pixel_to_MUX_wr),
		.data15_in(PE1_Pixel_to_MUX_wr),
		.data16_in(PE2_Pixel_to_MUX_wr),
		.data17_in(PE3_Pixel_to_MUX_wr),
		.data18_in(PE4_Pixel_to_MUX_wr),
		.data19_in(PE5_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE6_Pixel_0_out_wr)
	);

	MUX_20_1 PE7_Pixel_0(
		.data0_in(PE7_Pixel_to_MUX_wr),
		.data1_in(PE8_Pixel_to_MUX_wr),
		.data2_in(PE9_Pixel_to_MUX_wr),
		.data3_in(PE10_Pixel_to_MUX_wr),
		.data4_in(PE11_Pixel_to_MUX_wr),
		.data5_in(PE12_Pixel_to_MUX_wr),
		.data6_in(PE13_Pixel_to_MUX_wr),
		.data7_in(PE14_Pixel_to_MUX_wr),
		.data8_in(PE15_Pixel_to_MUX_wr),
		.data9_in(PE16_Pixel_to_MUX_wr),
		.data10_in(PE17_Pixel_to_MUX_wr),
		.data11_in(PE18_Pixel_to_MUX_wr),
		.data12_in(PE19_Pixel_to_MUX_wr),
		.data13_in(PE0_Pixel_to_MUX_wr),
		.data14_in(PE1_Pixel_to_MUX_wr),
		.data15_in(PE2_Pixel_to_MUX_wr),
		.data16_in(PE3_Pixel_to_MUX_wr),
		.data17_in(PE4_Pixel_to_MUX_wr),
		.data18_in(PE5_Pixel_to_MUX_wr),
		.data19_in(PE6_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE7_Pixel_0_out_wr)
	);

	MUX_20_1 PE8_Pixel_0(
		.data0_in(PE8_Pixel_to_MUX_wr),
		.data1_in(PE9_Pixel_to_MUX_wr),
		.data2_in(PE10_Pixel_to_MUX_wr),
		.data3_in(PE11_Pixel_to_MUX_wr),
		.data4_in(PE12_Pixel_to_MUX_wr),
		.data5_in(PE13_Pixel_to_MUX_wr),
		.data6_in(PE14_Pixel_to_MUX_wr),
		.data7_in(PE15_Pixel_to_MUX_wr),
		.data8_in(PE16_Pixel_to_MUX_wr),
		.data9_in(PE17_Pixel_to_MUX_wr),
		.data10_in(PE18_Pixel_to_MUX_wr),
		.data11_in(PE19_Pixel_to_MUX_wr),
		.data12_in(PE0_Pixel_to_MUX_wr),
		.data13_in(PE1_Pixel_to_MUX_wr),
		.data14_in(PE2_Pixel_to_MUX_wr),
		.data15_in(PE3_Pixel_to_MUX_wr),
		.data16_in(PE4_Pixel_to_MUX_wr),
		.data17_in(PE5_Pixel_to_MUX_wr),
		.data18_in(PE6_Pixel_to_MUX_wr),
		.data19_in(PE7_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE8_Pixel_0_out_wr)
	);

	MUX_20_1 PE9_Pixel_0(
		.data0_in(PE9_Pixel_to_MUX_wr),
		.data1_in(PE10_Pixel_to_MUX_wr),
		.data2_in(PE11_Pixel_to_MUX_wr),
		.data3_in(PE12_Pixel_to_MUX_wr),
		.data4_in(PE13_Pixel_to_MUX_wr),
		.data5_in(PE14_Pixel_to_MUX_wr),
		.data6_in(PE15_Pixel_to_MUX_wr),
		.data7_in(PE16_Pixel_to_MUX_wr),
		.data8_in(PE17_Pixel_to_MUX_wr),
		.data9_in(PE18_Pixel_to_MUX_wr),
		.data10_in(PE19_Pixel_to_MUX_wr),
		.data11_in(PE0_Pixel_to_MUX_wr),
		.data12_in(PE1_Pixel_to_MUX_wr),
		.data13_in(PE2_Pixel_to_MUX_wr),
		.data14_in(PE3_Pixel_to_MUX_wr),
		.data15_in(PE4_Pixel_to_MUX_wr),
		.data16_in(PE5_Pixel_to_MUX_wr),
		.data17_in(PE6_Pixel_to_MUX_wr),
		.data18_in(PE7_Pixel_to_MUX_wr),
		.data19_in(PE8_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE9_Pixel_0_out_wr)
	);

	MUX_20_1 PE10_Pixel_0(
		.data0_in(PE10_Pixel_to_MUX_wr),
		.data1_in(PE11_Pixel_to_MUX_wr),
		.data2_in(PE12_Pixel_to_MUX_wr),
		.data3_in(PE13_Pixel_to_MUX_wr),
		.data4_in(PE14_Pixel_to_MUX_wr),
		.data5_in(PE15_Pixel_to_MUX_wr),
		.data6_in(PE16_Pixel_to_MUX_wr),
		.data7_in(PE17_Pixel_to_MUX_wr),
		.data8_in(PE18_Pixel_to_MUX_wr),
		.data9_in(PE19_Pixel_to_MUX_wr),
		.data10_in(PE0_Pixel_to_MUX_wr),
		.data11_in(PE1_Pixel_to_MUX_wr),
		.data12_in(PE2_Pixel_to_MUX_wr),
		.data13_in(PE3_Pixel_to_MUX_wr),
		.data14_in(PE4_Pixel_to_MUX_wr),
		.data15_in(PE5_Pixel_to_MUX_wr),
		.data16_in(PE6_Pixel_to_MUX_wr),
		.data17_in(PE7_Pixel_to_MUX_wr),
		.data18_in(PE8_Pixel_to_MUX_wr),
		.data19_in(PE9_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE10_Pixel_0_out_wr)
	);

	MUX_20_1 PE11_Pixel_0(
		.data0_in(PE11_Pixel_to_MUX_wr),
		.data1_in(PE12_Pixel_to_MUX_wr),
		.data2_in(PE13_Pixel_to_MUX_wr),
		.data3_in(PE14_Pixel_to_MUX_wr),
		.data4_in(PE15_Pixel_to_MUX_wr),
		.data5_in(PE16_Pixel_to_MUX_wr),
		.data6_in(PE17_Pixel_to_MUX_wr),
		.data7_in(PE18_Pixel_to_MUX_wr),
		.data8_in(PE19_Pixel_to_MUX_wr),
		.data9_in(PE0_Pixel_to_MUX_wr),
		.data10_in(PE1_Pixel_to_MUX_wr),
		.data11_in(PE2_Pixel_to_MUX_wr),
		.data12_in(PE3_Pixel_to_MUX_wr),
		.data13_in(PE4_Pixel_to_MUX_wr),
		.data14_in(PE5_Pixel_to_MUX_wr),
		.data15_in(PE6_Pixel_to_MUX_wr),
		.data16_in(PE7_Pixel_to_MUX_wr),
		.data17_in(PE8_Pixel_to_MUX_wr),
		.data18_in(PE9_Pixel_to_MUX_wr),
		.data19_in(PE10_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE11_Pixel_0_out_wr)
	);

	MUX_20_1 PE12_Pixel_0(
		.data0_in(PE12_Pixel_to_MUX_wr),
		.data1_in(PE13_Pixel_to_MUX_wr),
		.data2_in(PE14_Pixel_to_MUX_wr),
		.data3_in(PE15_Pixel_to_MUX_wr),
		.data4_in(PE16_Pixel_to_MUX_wr),
		.data5_in(PE17_Pixel_to_MUX_wr),
		.data6_in(PE18_Pixel_to_MUX_wr),
		.data7_in(PE19_Pixel_to_MUX_wr),
		.data8_in(PE0_Pixel_to_MUX_wr),
		.data9_in(PE1_Pixel_to_MUX_wr),
		.data10_in(PE2_Pixel_to_MUX_wr),
		.data11_in(PE3_Pixel_to_MUX_wr),
		.data12_in(PE4_Pixel_to_MUX_wr),
		.data13_in(PE5_Pixel_to_MUX_wr),
		.data14_in(PE6_Pixel_to_MUX_wr),
		.data15_in(PE7_Pixel_to_MUX_wr),
		.data16_in(PE8_Pixel_to_MUX_wr),
		.data17_in(PE9_Pixel_to_MUX_wr),
		.data18_in(PE10_Pixel_to_MUX_wr),
		.data19_in(PE11_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE12_Pixel_0_out_wr)
	);

	MUX_20_1 PE13_Pixel_0(
		.data0_in(PE13_Pixel_to_MUX_wr),
		.data1_in(PE14_Pixel_to_MUX_wr),
		.data2_in(PE15_Pixel_to_MUX_wr),
		.data3_in(PE16_Pixel_to_MUX_wr),
		.data4_in(PE17_Pixel_to_MUX_wr),
		.data5_in(PE18_Pixel_to_MUX_wr),
		.data6_in(PE19_Pixel_to_MUX_wr),
		.data7_in(PE0_Pixel_to_MUX_wr),
		.data8_in(PE1_Pixel_to_MUX_wr),
		.data9_in(PE2_Pixel_to_MUX_wr),
		.data10_in(PE3_Pixel_to_MUX_wr),
		.data11_in(PE4_Pixel_to_MUX_wr),
		.data12_in(PE5_Pixel_to_MUX_wr),
		.data13_in(PE6_Pixel_to_MUX_wr),
		.data14_in(PE7_Pixel_to_MUX_wr),
		.data15_in(PE8_Pixel_to_MUX_wr),
		.data16_in(PE9_Pixel_to_MUX_wr),
		.data17_in(PE10_Pixel_to_MUX_wr),
		.data18_in(PE11_Pixel_to_MUX_wr),
		.data19_in(PE12_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE13_Pixel_0_out_wr)
	);

	MUX_20_1 PE14_Pixel_0(
		.data0_in(PE14_Pixel_to_MUX_wr),
		.data1_in(PE15_Pixel_to_MUX_wr),
		.data2_in(PE16_Pixel_to_MUX_wr),
		.data3_in(PE17_Pixel_to_MUX_wr),
		.data4_in(PE18_Pixel_to_MUX_wr),
		.data5_in(PE19_Pixel_to_MUX_wr),
		.data6_in(PE0_Pixel_to_MUX_wr),
		.data7_in(PE1_Pixel_to_MUX_wr),
		.data8_in(PE2_Pixel_to_MUX_wr),
		.data9_in(PE3_Pixel_to_MUX_wr),
		.data10_in(PE4_Pixel_to_MUX_wr),
		.data11_in(PE5_Pixel_to_MUX_wr),
		.data12_in(PE6_Pixel_to_MUX_wr),
		.data13_in(PE7_Pixel_to_MUX_wr),
		.data14_in(PE8_Pixel_to_MUX_wr),
		.data15_in(PE9_Pixel_to_MUX_wr),
		.data16_in(PE10_Pixel_to_MUX_wr),
		.data17_in(PE11_Pixel_to_MUX_wr),
		.data18_in(PE12_Pixel_to_MUX_wr),
		.data19_in(PE13_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE14_Pixel_0_out_wr)
	);

	MUX_20_1 PE15_Pixel_0(
		.data0_in(PE15_Pixel_to_MUX_wr),
		.data1_in(PE16_Pixel_to_MUX_wr),
		.data2_in(PE17_Pixel_to_MUX_wr),
		.data3_in(PE18_Pixel_to_MUX_wr),
		.data4_in(PE19_Pixel_to_MUX_wr),
		.data5_in(PE0_Pixel_to_MUX_wr),
		.data6_in(PE1_Pixel_to_MUX_wr),
		.data7_in(PE2_Pixel_to_MUX_wr),
		.data8_in(PE3_Pixel_to_MUX_wr),
		.data9_in(PE4_Pixel_to_MUX_wr),
		.data10_in(PE5_Pixel_to_MUX_wr),
		.data11_in(PE6_Pixel_to_MUX_wr),
		.data12_in(PE7_Pixel_to_MUX_wr),
		.data13_in(PE8_Pixel_to_MUX_wr),
		.data14_in(PE9_Pixel_to_MUX_wr),
		.data15_in(PE10_Pixel_to_MUX_wr),
		.data16_in(PE11_Pixel_to_MUX_wr),
		.data17_in(PE12_Pixel_to_MUX_wr),
		.data18_in(PE13_Pixel_to_MUX_wr),
		.data19_in(PE14_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE15_Pixel_0_out_wr)
	);

	MUX_20_1 PE16_Pixel_0(
		.data0_in(PE16_Pixel_to_MUX_wr),
		.data1_in(PE17_Pixel_to_MUX_wr),
		.data2_in(PE18_Pixel_to_MUX_wr),
		.data3_in(PE19_Pixel_to_MUX_wr),
		.data4_in(PE0_Pixel_to_MUX_wr),
		.data5_in(PE1_Pixel_to_MUX_wr),
		.data6_in(PE2_Pixel_to_MUX_wr),
		.data7_in(PE3_Pixel_to_MUX_wr),
		.data8_in(PE4_Pixel_to_MUX_wr),
		.data9_in(PE5_Pixel_to_MUX_wr),
		.data10_in(PE6_Pixel_to_MUX_wr),
		.data11_in(PE7_Pixel_to_MUX_wr),
		.data12_in(PE8_Pixel_to_MUX_wr),
		.data13_in(PE9_Pixel_to_MUX_wr),
		.data14_in(PE10_Pixel_to_MUX_wr),
		.data15_in(PE11_Pixel_to_MUX_wr),
		.data16_in(PE12_Pixel_to_MUX_wr),
		.data17_in(PE13_Pixel_to_MUX_wr),
		.data18_in(PE14_Pixel_to_MUX_wr),
		.data19_in(PE15_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE16_Pixel_0_out_wr)
	);

	MUX_20_1 PE17_Pixel_0(
		.data0_in(PE17_Pixel_to_MUX_wr),
		.data1_in(PE18_Pixel_to_MUX_wr),
		.data2_in(PE19_Pixel_to_MUX_wr),
		.data3_in(PE0_Pixel_to_MUX_wr),
		.data4_in(PE1_Pixel_to_MUX_wr),
		.data5_in(PE2_Pixel_to_MUX_wr),
		.data6_in(PE3_Pixel_to_MUX_wr),
		.data7_in(PE4_Pixel_to_MUX_wr),
		.data8_in(PE5_Pixel_to_MUX_wr),
		.data9_in(PE6_Pixel_to_MUX_wr),
		.data10_in(PE7_Pixel_to_MUX_wr),
		.data11_in(PE8_Pixel_to_MUX_wr),
		.data12_in(PE9_Pixel_to_MUX_wr),
		.data13_in(PE10_Pixel_to_MUX_wr),
		.data14_in(PE11_Pixel_to_MUX_wr),
		.data15_in(PE12_Pixel_to_MUX_wr),
		.data16_in(PE13_Pixel_to_MUX_wr),
		.data17_in(PE14_Pixel_to_MUX_wr),
		.data18_in(PE15_Pixel_to_MUX_wr),
		.data19_in(PE16_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE17_Pixel_0_out_wr)
	);

	MUX_20_1 PE18_Pixel_0(
		.data0_in(PE18_Pixel_to_MUX_wr),
		.data1_in(PE19_Pixel_to_MUX_wr),
		.data2_in(PE0_Pixel_to_MUX_wr),
		.data3_in(PE1_Pixel_to_MUX_wr),
		.data4_in(PE2_Pixel_to_MUX_wr),
		.data5_in(PE3_Pixel_to_MUX_wr),
		.data6_in(PE4_Pixel_to_MUX_wr),
		.data7_in(PE5_Pixel_to_MUX_wr),
		.data8_in(PE6_Pixel_to_MUX_wr),
		.data9_in(PE7_Pixel_to_MUX_wr),
		.data10_in(PE8_Pixel_to_MUX_wr),
		.data11_in(PE9_Pixel_to_MUX_wr),
		.data12_in(PE10_Pixel_to_MUX_wr),
		.data13_in(PE11_Pixel_to_MUX_wr),
		.data14_in(PE12_Pixel_to_MUX_wr),
		.data15_in(PE13_Pixel_to_MUX_wr),
		.data16_in(PE14_Pixel_to_MUX_wr),
		.data17_in(PE15_Pixel_to_MUX_wr),
		.data18_in(PE16_Pixel_to_MUX_wr),
		.data19_in(PE17_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE18_Pixel_0_out_wr)
	);

	MUX_20_1 PE19_Pixel_0(
		.data0_in(PE19_Pixel_to_MUX_wr),
		.data1_in(PE0_Pixel_to_MUX_wr),
		.data2_in(PE1_Pixel_to_MUX_wr),
		.data3_in(PE2_Pixel_to_MUX_wr),
		.data4_in(PE3_Pixel_to_MUX_wr),
		.data5_in(PE4_Pixel_to_MUX_wr),
		.data6_in(PE5_Pixel_to_MUX_wr),
		.data7_in(PE6_Pixel_to_MUX_wr),
		.data8_in(PE7_Pixel_to_MUX_wr),
		.data9_in(PE8_Pixel_to_MUX_wr),
		.data10_in(PE9_Pixel_to_MUX_wr),
		.data11_in(PE10_Pixel_to_MUX_wr),
		.data12_in(PE11_Pixel_to_MUX_wr),
		.data13_in(PE12_Pixel_to_MUX_wr),
		.data14_in(PE13_Pixel_to_MUX_wr),
		.data15_in(PE14_Pixel_to_MUX_wr),
		.data16_in(PE15_Pixel_to_MUX_wr),
		.data17_in(PE16_Pixel_to_MUX_wr),
		.data18_in(PE17_Pixel_to_MUX_wr),
		.data19_in(PE18_Pixel_to_MUX_wr),
		.sel_in(MUX_Selection_in),
		.mux_20_1_out(PE19_Pixel_0_out_wr)
	);

	assign PE0_Pixel_1_out_wr			= (MP_Padding_in) ? PE0_Pixel_0_in : PE1_Pixel_0_in;	
	assign PE0_Pixel_2_out_wr			= (MP_Padding_in) ? PE1_Pixel_0_in : PE2_Pixel_0_in;

	assign PE1_Pixel_1_out_wr			= (MP_Padding_in) ? PE1_Pixel_0_in : PE2_Pixel_0_in;	
	assign PE1_Pixel_2_out_wr			= (MP_Padding_in) ? PE2_Pixel_0_in : PE3_Pixel_0_in;

	assign PE2_Pixel_1_out_wr			= (MP_Padding_in) ? PE2_Pixel_0_in : PE3_Pixel_0_in;	
	assign PE2_Pixel_2_out_wr			= (MP_Padding_in) ? PE3_Pixel_0_in : PE4_Pixel_0_in;

	assign PE3_Pixel_1_out_wr			= (MP_Padding_in) ? PE3_Pixel_0_in : PE4_Pixel_0_in;	
	assign PE3_Pixel_2_out_wr			= (MP_Padding_in) ? PE4_Pixel_0_in : PE5_Pixel_0_in;

	assign PE4_Pixel_1_out_wr           = (MP_Padding_in) ? PE4_Pixel_0_in : PE5_Pixel_0_in;   
	assign PE4_Pixel_2_out_wr           = (MP_Padding_in) ? PE5_Pixel_0_in : PE6_Pixel_0_in;

	assign PE5_Pixel_1_out_wr           = (MP_Padding_in) ? PE5_Pixel_0_in : PE6_Pixel_0_in;   
	assign PE5_Pixel_2_out_wr           = (MP_Padding_in) ? PE6_Pixel_0_in : PE7_Pixel_0_in;

	assign PE6_Pixel_1_out_wr           = (MP_Padding_in) ? PE6_Pixel_0_in : PE7_Pixel_0_in;   
	assign PE6_Pixel_2_out_wr           = (MP_Padding_in) ? PE7_Pixel_0_in : PE8_Pixel_0_in;

	assign PE7_Pixel_1_out_wr           = (MP_Padding_in) ? PE7_Pixel_0_in : PE8_Pixel_0_in;   
	assign PE7_Pixel_2_out_wr           = (MP_Padding_in) ? PE8_Pixel_0_in : PE9_Pixel_0_in;

	assign PE8_Pixel_1_out_wr           = (MP_Padding_in) ? PE8_Pixel_0_in : PE9_Pixel_0_in;   
	assign PE8_Pixel_2_out_wr           = (MP_Padding_in) ? PE9_Pixel_0_in : PE10_Pixel_0_in;

	assign PE9_Pixel_1_out_wr           = (MP_Padding_in) ? PE9_Pixel_0_in : PE10_Pixel_0_in;  
	assign PE9_Pixel_2_out_wr           = (MP_Padding_in) ? PE10_Pixel_0_in : PE11_Pixel_0_in;

	assign PE10_Pixel_1_out_wr          = (MP_Padding_in) ? PE10_Pixel_0_in : PE11_Pixel_0_in; 
	assign PE10_Pixel_2_out_wr          = (MP_Padding_in) ? PE11_Pixel_0_in : PE12_Pixel_0_in;

	assign PE11_Pixel_1_out_wr          = (MP_Padding_in) ? PE11_Pixel_0_in : PE12_Pixel_0_in; 
	assign PE11_Pixel_2_out_wr          = (MP_Padding_in) ? PE12_Pixel_0_in : PE13_Pixel_0_in;

	assign PE12_Pixel_1_out_wr          = (MP_Padding_in) ? PE12_Pixel_0_in : PE13_Pixel_0_in; 
	assign PE12_Pixel_2_out_wr          = (MP_Padding_in) ? PE13_Pixel_0_in : PE14_Pixel_0_in;

	assign PE13_Pixel_1_out_wr          = (MP_Padding_in) ? PE13_Pixel_0_in : PE14_Pixel_0_in; 
	assign PE13_Pixel_2_out_wr          = (MP_Padding_in) ? PE14_Pixel_0_in : PE15_Pixel_0_in;

	assign PE14_Pixel_1_out_wr          = (MP_Padding_in) ? PE14_Pixel_0_in : PE15_Pixel_0_in; 
	assign PE14_Pixel_2_out_wr          = (MP_Padding_in) ? PE15_Pixel_0_in : PE16_Pixel_0_in;

	assign PE15_Pixel_1_out_wr          = (MP_Padding_in) ? PE15_Pixel_0_in : PE16_Pixel_0_in; 
	assign PE15_Pixel_2_out_wr          = (MP_Padding_in) ? PE16_Pixel_0_in : PE17_Pixel_0_in;

	assign PE16_Pixel_1_out_wr          = (MP_Padding_in) ? PE16_Pixel_0_in : PE17_Pixel_0_in; 
	assign PE16_Pixel_2_out_wr          = (MP_Padding_in) ? PE17_Pixel_0_in : PE18_Pixel_0_in;

	assign PE17_Pixel_1_out_wr          = (MP_Padding_in) ? PE17_Pixel_0_in : PE18_Pixel_0_in; 
	assign PE17_Pixel_2_out_wr          = (MP_Padding_in) ? PE18_Pixel_0_in : PE19_Pixel_0_in;

	assign PE18_Pixel_1_out_wr          = (MP_Padding_in) ? PE18_Pixel_0_in : PE19_Pixel_0_in; 
	assign PE18_Pixel_2_out_wr          = (MP_Padding_3_in) ? 0: (MP_Padding_in) ? PE19_Pixel_1_in : PE0_Pixel_1_in;

	assign PE19_Pixel_1_out_wr          = (MP_Padding_3_in) ? 0: (MP_Padding_in) ? PE19_Pixel_1_in : PE0_Pixel_1_in;  
	assign PE19_Pixel_2_out_wr          = (MP_Padding_3_in) ? 0: (MP_Padding_2_in) ? 0: (MP_Padding_in) ? PE0_Pixel_1_in : PE1_Pixel_1_in;


	assign PE0_Pixel_0_valid_out_wr		= PE0_Pixel_0_valid_in | PE1_Pixel_0_valid_in;
	assign PE0_Pixel_1_valid_out_wr		= PE0_Pixel_0_valid_in | PE1_Pixel_0_valid_in;
	assign PE0_Pixel_2_valid_out_wr		= PE0_Pixel_0_valid_in | PE1_Pixel_0_valid_in;

	assign PE1_Pixel_0_valid_out_wr		= PE1_Pixel_0_valid_in | PE0_Pixel_0_valid_in;
	assign PE1_Pixel_1_valid_out_wr		= PE1_Pixel_0_valid_in | PE0_Pixel_0_valid_in;
	assign PE1_Pixel_2_valid_out_wr		= PE1_Pixel_0_valid_in | PE0_Pixel_0_valid_in;

	assign PE2_Pixel_0_valid_out_wr     = PE2_Pixel_0_valid_in | PE3_Pixel_0_valid_in;
	assign PE2_Pixel_1_valid_out_wr     = PE2_Pixel_0_valid_in | PE3_Pixel_0_valid_in;
	assign PE2_Pixel_2_valid_out_wr     = PE2_Pixel_0_valid_in | PE3_Pixel_0_valid_in;

	assign PE3_Pixel_0_valid_out_wr     = PE3_Pixel_0_valid_in | PE2_Pixel_0_valid_in;
	assign PE3_Pixel_1_valid_out_wr     = PE3_Pixel_0_valid_in | PE2_Pixel_0_valid_in;
	assign PE3_Pixel_2_valid_out_wr     = PE3_Pixel_0_valid_in | PE2_Pixel_0_valid_in;

	assign PE4_Pixel_0_valid_out_wr     = PE4_Pixel_0_valid_in | PE5_Pixel_0_valid_in;
	assign PE4_Pixel_1_valid_out_wr     = PE4_Pixel_0_valid_in | PE5_Pixel_0_valid_in;
	assign PE4_Pixel_2_valid_out_wr     = PE4_Pixel_0_valid_in | PE5_Pixel_0_valid_in;

	assign PE5_Pixel_0_valid_out_wr     = PE5_Pixel_0_valid_in | PE4_Pixel_0_valid_in;
	assign PE5_Pixel_1_valid_out_wr     = PE5_Pixel_0_valid_in | PE4_Pixel_0_valid_in;
	assign PE5_Pixel_2_valid_out_wr     = PE5_Pixel_0_valid_in | PE4_Pixel_0_valid_in;

	assign PE6_Pixel_0_valid_out_wr     = PE6_Pixel_0_valid_in | PE7_Pixel_0_valid_in;
	assign PE6_Pixel_1_valid_out_wr     = PE6_Pixel_0_valid_in | PE7_Pixel_0_valid_in;
	assign PE6_Pixel_2_valid_out_wr     = PE6_Pixel_0_valid_in | PE7_Pixel_0_valid_in;

	assign PE7_Pixel_0_valid_out_wr     = PE7_Pixel_0_valid_in | PE6_Pixel_0_valid_in;
	assign PE7_Pixel_1_valid_out_wr     = PE7_Pixel_0_valid_in | PE6_Pixel_0_valid_in;
	assign PE7_Pixel_2_valid_out_wr     = PE7_Pixel_0_valid_in | PE6_Pixel_0_valid_in;

	assign PE8_Pixel_0_valid_out_wr     = PE8_Pixel_0_valid_in | PE9_Pixel_0_valid_in;
	assign PE8_Pixel_1_valid_out_wr     = PE8_Pixel_0_valid_in | PE9_Pixel_0_valid_in;
	assign PE8_Pixel_2_valid_out_wr     = PE8_Pixel_0_valid_in | PE9_Pixel_0_valid_in;

	assign PE9_Pixel_0_valid_out_wr     = PE9_Pixel_0_valid_in | PE8_Pixel_0_valid_in;
	assign PE9_Pixel_1_valid_out_wr     = PE9_Pixel_0_valid_in | PE8_Pixel_0_valid_in;
	assign PE9_Pixel_2_valid_out_wr     = PE9_Pixel_0_valid_in | PE8_Pixel_0_valid_in;

	assign PE10_Pixel_0_valid_out_wr    = PE10_Pixel_0_valid_in | PE11_Pixel_0_valid_in;
	assign PE10_Pixel_1_valid_out_wr    = PE10_Pixel_0_valid_in | PE11_Pixel_0_valid_in;
	assign PE10_Pixel_2_valid_out_wr    = PE10_Pixel_0_valid_in | PE11_Pixel_0_valid_in;

	assign PE11_Pixel_0_valid_out_wr    = PE11_Pixel_0_valid_in | PE10_Pixel_0_valid_in;
	assign PE11_Pixel_1_valid_out_wr    = PE11_Pixel_0_valid_in | PE10_Pixel_0_valid_in;
	assign PE11_Pixel_2_valid_out_wr    = PE11_Pixel_0_valid_in | PE10_Pixel_0_valid_in;

	assign PE12_Pixel_0_valid_out_wr    = PE12_Pixel_0_valid_in | PE13_Pixel_0_valid_in;
	assign PE12_Pixel_1_valid_out_wr    = PE12_Pixel_0_valid_in | PE13_Pixel_0_valid_in;
	assign PE12_Pixel_2_valid_out_wr    = PE12_Pixel_0_valid_in | PE13_Pixel_0_valid_in;

	assign PE13_Pixel_0_valid_out_wr    = PE13_Pixel_0_valid_in | PE12_Pixel_0_valid_in;
	assign PE13_Pixel_1_valid_out_wr    = PE13_Pixel_0_valid_in | PE12_Pixel_0_valid_in;
	assign PE13_Pixel_2_valid_out_wr    = PE13_Pixel_0_valid_in | PE12_Pixel_0_valid_in;

	assign PE14_Pixel_0_valid_out_wr    = PE14_Pixel_0_valid_in | PE15_Pixel_0_valid_in;
	assign PE14_Pixel_1_valid_out_wr    = PE14_Pixel_0_valid_in | PE15_Pixel_0_valid_in;
	assign PE14_Pixel_2_valid_out_wr    = PE14_Pixel_0_valid_in | PE15_Pixel_0_valid_in;

	assign PE15_Pixel_0_valid_out_wr    = PE15_Pixel_0_valid_in | PE14_Pixel_0_valid_in;
	assign PE15_Pixel_1_valid_out_wr    = PE15_Pixel_0_valid_in | PE14_Pixel_0_valid_in;
	assign PE15_Pixel_2_valid_out_wr    = PE15_Pixel_0_valid_in | PE14_Pixel_0_valid_in;

	assign PE16_Pixel_0_valid_out_wr    = PE16_Pixel_0_valid_in | PE17_Pixel_0_valid_in;
	assign PE16_Pixel_1_valid_out_wr    = PE16_Pixel_0_valid_in | PE17_Pixel_0_valid_in;
	assign PE16_Pixel_2_valid_out_wr    = PE16_Pixel_0_valid_in | PE17_Pixel_0_valid_in;

	assign PE17_Pixel_0_valid_out_wr    = PE17_Pixel_0_valid_in | PE16_Pixel_0_valid_in;
	assign PE17_Pixel_1_valid_out_wr    = PE17_Pixel_0_valid_in | PE16_Pixel_0_valid_in;
	assign PE17_Pixel_2_valid_out_wr    = PE17_Pixel_0_valid_in | PE16_Pixel_0_valid_in;

	assign PE18_Pixel_0_valid_out_wr    = PE18_Pixel_0_valid_in | PE19_Pixel_0_valid_in;
	assign PE18_Pixel_1_valid_out_wr    = PE18_Pixel_0_valid_in | PE19_Pixel_0_valid_in;
	assign PE18_Pixel_2_valid_out_wr    = PE18_Pixel_0_valid_in | PE19_Pixel_0_valid_in;

	assign PE19_Pixel_0_valid_out_wr    = PE19_Pixel_0_valid_in | PE18_Pixel_0_valid_in;
	assign PE19_Pixel_1_valid_out_wr    = PE19_Pixel_0_valid_in | PE18_Pixel_0_valid_in;
	assign PE19_Pixel_2_valid_out_wr    = PE19_Pixel_0_valid_in | PE18_Pixel_0_valid_in;

	always @(posedge CLK or negedge RST) begin
		if (~RST) begin
			PE0_Pixel_0_out				<= 0;
			PE0_Pixel_0_valid_out		<= 0;
			PE0_Pixel_1_out				<= 0;
			PE0_Pixel_1_valid_out		<= 0;
			PE0_Pixel_2_out				<= 0;
			PE0_Pixel_2_valid_out		<= 0;
              
			PE1_Pixel_0_out				<= 0;
			PE1_Pixel_0_valid_out		<= 0;
			PE1_Pixel_1_out				<= 0;
			PE1_Pixel_1_valid_out		<= 0;
			PE1_Pixel_2_out				<= 0;
			PE1_Pixel_2_valid_out		<= 0;
              
			PE2_Pixel_0_out				<= 0;
			PE2_Pixel_0_valid_out		<= 0;
			PE2_Pixel_1_out				<= 0;
			PE2_Pixel_1_valid_out		<= 0;
			PE2_Pixel_2_out				<= 0;
			PE2_Pixel_2_valid_out		<= 0;
			  
			PE3_Pixel_0_out				<= 0;
			PE3_Pixel_0_valid_out		<= 0;
			PE3_Pixel_1_out				<= 0;
			PE3_Pixel_1_valid_out		<= 0;
			PE3_Pixel_2_out				<= 0;
			PE3_Pixel_2_valid_out		<= 0;
			  
			PE4_Pixel_0_out				<= 0;
			PE4_Pixel_0_valid_out		<= 0;
			PE4_Pixel_1_out				<= 0;
			PE4_Pixel_1_valid_out		<= 0;
			PE4_Pixel_2_out				<= 0;
			PE4_Pixel_2_valid_out		<= 0;
			  
			PE5_Pixel_0_out				<= 0;
			PE5_Pixel_0_valid_out		<= 0;
			PE5_Pixel_1_out				<= 0;
			PE5_Pixel_1_valid_out		<= 0;
			PE5_Pixel_2_out				<= 0;
			PE5_Pixel_2_valid_out		<= 0;
			  
			PE6_Pixel_0_out				<= 0;
			PE6_Pixel_0_valid_out		<= 0;
			PE6_Pixel_1_out				<= 0;
			PE6_Pixel_1_valid_out		<= 0;
			PE6_Pixel_2_out				<= 0;
			PE6_Pixel_2_valid_out		<= 0;
			  
			PE7_Pixel_0_out				<= 0;
			PE7_Pixel_0_valid_out		<= 0;
			PE7_Pixel_1_out				<= 0;
			PE7_Pixel_1_valid_out		<= 0;
			PE7_Pixel_2_out				<= 0;
			PE7_Pixel_2_valid_out		<= 0;
			  
			PE8_Pixel_0_out				<= 0;
			PE8_Pixel_0_valid_out		<= 0;
			PE8_Pixel_1_out				<= 0;
			PE8_Pixel_1_valid_out		<= 0;
			PE8_Pixel_2_out				<= 0;
			PE8_Pixel_2_valid_out		<= 0;
			  
			PE9_Pixel_0_out				<= 0;
			PE9_Pixel_0_valid_out		<= 0;
			PE9_Pixel_1_out				<= 0;
			PE9_Pixel_1_valid_out		<= 0;
			PE9_Pixel_2_out				<= 0;
			PE9_Pixel_2_valid_out		<= 0;
			
			PE10_Pixel_0_out			<= 0;
			PE10_Pixel_0_valid_out		<= 0;
			PE10_Pixel_1_out			<= 0;
			PE10_Pixel_1_valid_out		<= 0;
			PE10_Pixel_2_out			<= 0;
			PE10_Pixel_2_valid_out		<= 0;
              
			PE11_Pixel_0_out			<= 0;
			PE11_Pixel_0_valid_out		<= 0;
			PE11_Pixel_1_out			<= 0;
			PE11_Pixel_1_valid_out		<= 0;
			PE11_Pixel_2_out			<= 0;
			PE11_Pixel_2_valid_out		<= 0;
              
			PE12_Pixel_0_out			<= 0;
			PE12_Pixel_0_valid_out		<= 0;
			PE12_Pixel_1_out			<= 0;
			PE12_Pixel_1_valid_out		<= 0;
			PE12_Pixel_2_out			<= 0;
			PE12_Pixel_2_valid_out		<= 0;
			  
			PE13_Pixel_0_out			<= 0;
			PE13_Pixel_0_valid_out		<= 0;
			PE13_Pixel_1_out			<= 0;
			PE13_Pixel_1_valid_out		<= 0;
			PE13_Pixel_2_out			<= 0;
			PE13_Pixel_2_valid_out		<= 0;
			  
			PE14_Pixel_0_out			<= 0;
			PE14_Pixel_0_valid_out		<= 0;
			PE14_Pixel_1_out			<= 0;
			PE14_Pixel_1_valid_out		<= 0;
			PE14_Pixel_2_out			<= 0;
			PE14_Pixel_2_valid_out		<= 0;
			  
			PE15_Pixel_0_out			<= 0;
			PE15_Pixel_0_valid_out		<= 0;
			PE15_Pixel_1_out			<= 0;
			PE15_Pixel_1_valid_out		<= 0;
			PE15_Pixel_2_out			<= 0;
			PE15_Pixel_2_valid_out		<= 0;
			  
			PE16_Pixel_0_out			<= 0;
			PE16_Pixel_0_valid_out		<= 0;
			PE16_Pixel_1_out			<= 0;
			PE16_Pixel_1_valid_out		<= 0;
			PE16_Pixel_2_out			<= 0;
			PE16_Pixel_2_valid_out		<= 0;
			  
			PE17_Pixel_0_out			<= 0;
			PE17_Pixel_0_valid_out		<= 0;
			PE17_Pixel_1_out			<= 0;
			PE17_Pixel_1_valid_out		<= 0;
			PE17_Pixel_2_out			<= 0;
			PE17_Pixel_2_valid_out		<= 0;
			  
			PE18_Pixel_0_out			<= 0;
			PE18_Pixel_0_valid_out		<= 0;
			PE18_Pixel_1_out			<= 0;
			PE18_Pixel_1_valid_out		<= 0;
			PE18_Pixel_2_out			<= 0;
			PE18_Pixel_2_valid_out		<= 0;
			  
			PE19_Pixel_0_out			<= 0;
			PE19_Pixel_0_valid_out		<= 0;
			PE19_Pixel_1_out			<= 0;
			PE19_Pixel_1_valid_out		<= 0;
			PE19_Pixel_2_out			<= 0;
			PE19_Pixel_2_valid_out		<= 0;
			
			Parity_PE_Selection_rg		<= 0;
		end	
		else begin	
			if(En_in) begin
				PE0_Pixel_0_out				<= PE0_Pixel_0_out_wr;
				PE0_Pixel_0_valid_out		<= PE0_Pixel_0_valid_out_wr;
				PE0_Pixel_1_out				<= PE0_Pixel_1_out_wr;
				PE0_Pixel_1_valid_out		<= PE0_Pixel_1_valid_out_wr;
				PE0_Pixel_2_out				<= PE0_Pixel_2_out_wr;
				PE0_Pixel_2_valid_out		<= PE0_Pixel_2_valid_out_wr;
											
				PE1_Pixel_0_out				<= PE1_Pixel_0_out_wr;
				PE1_Pixel_0_valid_out		<= PE1_Pixel_0_valid_out_wr;
				PE1_Pixel_1_out				<= PE1_Pixel_1_out_wr;
				PE1_Pixel_1_valid_out		<= PE1_Pixel_1_valid_out_wr;
				PE1_Pixel_2_out				<= PE1_Pixel_2_out_wr;
				PE1_Pixel_2_valid_out		<= PE1_Pixel_2_valid_out_wr;
											
				PE2_Pixel_0_out				<= PE2_Pixel_0_out_wr;
				PE2_Pixel_0_valid_out		<= PE2_Pixel_0_valid_out_wr;
				PE2_Pixel_1_out				<= PE2_Pixel_1_out_wr;
				PE2_Pixel_1_valid_out		<= PE2_Pixel_1_valid_out_wr;
				PE2_Pixel_2_out				<= PE2_Pixel_2_out_wr;
				PE2_Pixel_2_valid_out		<= PE2_Pixel_2_valid_out_wr;
											
				PE3_Pixel_0_out				<= PE3_Pixel_0_out_wr;
				PE3_Pixel_0_valid_out		<= PE3_Pixel_0_valid_out_wr;
				PE3_Pixel_1_out				<= PE3_Pixel_1_out_wr;
				PE3_Pixel_1_valid_out		<= PE3_Pixel_1_valid_out_wr;
				PE3_Pixel_2_out				<= PE3_Pixel_2_out_wr;
				PE3_Pixel_2_valid_out		<= PE3_Pixel_2_valid_out_wr;
											
				PE4_Pixel_0_out				<= PE4_Pixel_0_out_wr;
				PE4_Pixel_0_valid_out		<= PE4_Pixel_0_valid_out_wr;
				PE4_Pixel_1_out				<= PE4_Pixel_1_out_wr;
				PE4_Pixel_1_valid_out		<= PE4_Pixel_1_valid_out_wr;
				PE4_Pixel_2_out				<= PE4_Pixel_2_out_wr;
				PE4_Pixel_2_valid_out		<= PE4_Pixel_2_valid_out_wr;
											
				PE5_Pixel_0_out				<= PE5_Pixel_0_out_wr;
				PE5_Pixel_0_valid_out		<= PE5_Pixel_0_valid_out_wr;
				PE5_Pixel_1_out				<= PE5_Pixel_1_out_wr;
				PE5_Pixel_1_valid_out		<= PE5_Pixel_1_valid_out_wr;
				PE5_Pixel_2_out				<= PE5_Pixel_2_out_wr;
				PE5_Pixel_2_valid_out		<= PE5_Pixel_2_valid_out_wr;
											
				PE6_Pixel_0_out				<= PE6_Pixel_0_out_wr;
				PE6_Pixel_0_valid_out		<= PE6_Pixel_0_valid_out_wr;
				PE6_Pixel_1_out				<= PE6_Pixel_1_out_wr;
				PE6_Pixel_1_valid_out		<= PE6_Pixel_1_valid_out_wr;
				PE6_Pixel_2_out				<= PE6_Pixel_2_out_wr;
				PE6_Pixel_2_valid_out		<= PE6_Pixel_2_valid_out_wr;
											
				PE7_Pixel_0_out				<= PE7_Pixel_0_out_wr;
				PE7_Pixel_0_valid_out		<= PE7_Pixel_0_valid_out_wr;
				PE7_Pixel_1_out				<= PE7_Pixel_1_out_wr;
				PE7_Pixel_1_valid_out		<= PE7_Pixel_1_valid_out_wr;
				PE7_Pixel_2_out				<= PE7_Pixel_2_out_wr;
				PE7_Pixel_2_valid_out		<= PE7_Pixel_2_valid_out_wr;
											
				PE8_Pixel_0_out				<= PE8_Pixel_0_out_wr;
				PE8_Pixel_0_valid_out		<= PE8_Pixel_0_valid_out_wr;
				PE8_Pixel_1_out				<= PE8_Pixel_1_out_wr;
				PE8_Pixel_1_valid_out		<= PE8_Pixel_1_valid_out_wr;
				PE8_Pixel_2_out				<= PE8_Pixel_2_out_wr;
				PE8_Pixel_2_valid_out		<= PE8_Pixel_2_valid_out_wr;
											
				PE9_Pixel_0_out				<= PE9_Pixel_0_out_wr;
				PE9_Pixel_0_valid_out		<= PE9_Pixel_0_valid_out_wr;
				PE9_Pixel_1_out				<= PE9_Pixel_1_out_wr;
				PE9_Pixel_1_valid_out		<= PE9_Pixel_1_valid_out_wr;
				PE9_Pixel_2_out				<= PE9_Pixel_2_out_wr;
				PE9_Pixel_2_valid_out		<= PE9_Pixel_2_valid_out_wr;
											
				PE10_Pixel_0_out			<= PE10_Pixel_0_out_wr;
				PE10_Pixel_0_valid_out		<= PE10_Pixel_0_valid_out_wr;
				PE10_Pixel_1_out			<= PE10_Pixel_1_out_wr;
				PE10_Pixel_1_valid_out		<= PE10_Pixel_1_valid_out_wr;
				PE10_Pixel_2_out			<= PE10_Pixel_2_out_wr;
				PE10_Pixel_2_valid_out		<= PE10_Pixel_2_valid_out_wr;
											
				PE11_Pixel_0_out			<= PE11_Pixel_0_out_wr;
				PE11_Pixel_0_valid_out		<= PE11_Pixel_0_valid_out_wr;
				PE11_Pixel_1_out			<= PE11_Pixel_1_out_wr;
				PE11_Pixel_1_valid_out		<= PE11_Pixel_1_valid_out_wr;
				PE11_Pixel_2_out			<= PE11_Pixel_2_out_wr;
				PE11_Pixel_2_valid_out		<= PE11_Pixel_2_valid_out_wr;
											
				PE12_Pixel_0_out			<= PE12_Pixel_0_out_wr;
				PE12_Pixel_0_valid_out		<= PE12_Pixel_0_valid_out_wr;
				PE12_Pixel_1_out			<= PE12_Pixel_1_out_wr;
				PE12_Pixel_1_valid_out		<= PE12_Pixel_1_valid_out_wr;
				PE12_Pixel_2_out			<= PE12_Pixel_2_out_wr;
				PE12_Pixel_2_valid_out		<= PE12_Pixel_2_valid_out_wr;
											
				PE13_Pixel_0_out			<= PE13_Pixel_0_out_wr;
				PE13_Pixel_0_valid_out		<= PE13_Pixel_0_valid_out_wr;
				PE13_Pixel_1_out			<= PE13_Pixel_1_out_wr;
				PE13_Pixel_1_valid_out		<= PE13_Pixel_1_valid_out_wr;
				PE13_Pixel_2_out			<= PE13_Pixel_2_out_wr;
				PE13_Pixel_2_valid_out		<= PE13_Pixel_2_valid_out_wr;
											
				PE14_Pixel_0_out			<= PE14_Pixel_0_out_wr;
				PE14_Pixel_0_valid_out		<= PE14_Pixel_0_valid_out_wr;
				PE14_Pixel_1_out			<= PE14_Pixel_1_out_wr;
				PE14_Pixel_1_valid_out		<= PE14_Pixel_1_valid_out_wr;
				PE14_Pixel_2_out			<= PE14_Pixel_2_out_wr;
				PE14_Pixel_2_valid_out		<= PE14_Pixel_2_valid_out_wr;
											
				PE15_Pixel_0_out			<= PE15_Pixel_0_out_wr;
				PE15_Pixel_0_valid_out		<= PE15_Pixel_0_valid_out_wr;
				PE15_Pixel_1_out			<= PE15_Pixel_1_out_wr;
				PE15_Pixel_1_valid_out		<= PE15_Pixel_1_valid_out_wr;
				PE15_Pixel_2_out			<= PE15_Pixel_2_out_wr;
				PE15_Pixel_2_valid_out		<= PE15_Pixel_2_valid_out_wr;
											
				PE16_Pixel_0_out			<= PE16_Pixel_0_out_wr;
				PE16_Pixel_0_valid_out		<= PE16_Pixel_0_valid_out_wr;
				PE16_Pixel_1_out			<= PE16_Pixel_1_out_wr;
				PE16_Pixel_1_valid_out		<= PE16_Pixel_1_valid_out_wr;
				PE16_Pixel_2_out			<= PE16_Pixel_2_out_wr;
				PE16_Pixel_2_valid_out		<= PE16_Pixel_2_valid_out_wr;
											
				PE17_Pixel_0_out			<= PE17_Pixel_0_out_wr;
				PE17_Pixel_0_valid_out		<= PE17_Pixel_0_valid_out_wr;
				PE17_Pixel_1_out			<= PE17_Pixel_1_out_wr;
				PE17_Pixel_1_valid_out		<= PE17_Pixel_1_valid_out_wr;
				PE17_Pixel_2_out			<= PE17_Pixel_2_out_wr;
				PE17_Pixel_2_valid_out		<= PE17_Pixel_2_valid_out_wr;
											
				PE18_Pixel_0_out			<= PE18_Pixel_0_out_wr;
				PE18_Pixel_0_valid_out		<= PE18_Pixel_0_valid_out_wr;
				PE18_Pixel_1_out			<= PE18_Pixel_1_out_wr;
				PE18_Pixel_1_valid_out		<= PE18_Pixel_1_valid_out_wr;
				PE18_Pixel_2_out			<= PE18_Pixel_2_out_wr;
				PE18_Pixel_2_valid_out		<= PE18_Pixel_2_valid_out_wr;
											
				PE19_Pixel_0_out			<= PE19_Pixel_0_out_wr;
				PE19_Pixel_0_valid_out		<= PE19_Pixel_0_valid_out_wr;
				PE19_Pixel_1_out			<= PE19_Pixel_1_out_wr;
				PE19_Pixel_1_valid_out		<= PE19_Pixel_1_valid_out_wr;
				PE19_Pixel_2_out			<= PE19_Pixel_2_out_wr;
				PE19_Pixel_2_valid_out		<= PE19_Pixel_2_valid_out_wr;
			end
			else begin
				PE0_Pixel_0_out				<= 0;
				PE0_Pixel_0_valid_out		<= 0;
				PE0_Pixel_1_out				<= 0;
				PE0_Pixel_1_valid_out		<= 0;
				PE0_Pixel_2_out				<= 0;
				PE0_Pixel_2_valid_out		<= 0;
				  
				PE1_Pixel_0_out				<= 0;
				PE1_Pixel_0_valid_out		<= 0;
				PE1_Pixel_1_out				<= 0;
				PE1_Pixel_1_valid_out		<= 0;
				PE1_Pixel_2_out				<= 0;
				PE1_Pixel_2_valid_out		<= 0;
				  
				PE2_Pixel_0_out				<= 0;
				PE2_Pixel_0_valid_out		<= 0;
				PE2_Pixel_1_out				<= 0;
				PE2_Pixel_1_valid_out		<= 0;
				PE2_Pixel_2_out				<= 0;
				PE2_Pixel_2_valid_out		<= 0;
				  
				PE3_Pixel_0_out				<= 0;
				PE3_Pixel_0_valid_out		<= 0;
				PE3_Pixel_1_out				<= 0;
				PE3_Pixel_1_valid_out		<= 0;
				PE3_Pixel_2_out				<= 0;
				PE3_Pixel_2_valid_out		<= 0;
				  
				PE4_Pixel_0_out				<= 0;
				PE4_Pixel_0_valid_out		<= 0;
				PE4_Pixel_1_out				<= 0;
				PE4_Pixel_1_valid_out		<= 0;
				PE4_Pixel_2_out				<= 0;
				PE4_Pixel_2_valid_out		<= 0;
				  
				PE5_Pixel_0_out				<= 0;
				PE5_Pixel_0_valid_out		<= 0;
				PE5_Pixel_1_out				<= 0;
				PE5_Pixel_1_valid_out		<= 0;
				PE5_Pixel_2_out				<= 0;
				PE5_Pixel_2_valid_out		<= 0;
				  
				PE6_Pixel_0_out				<= 0;
				PE6_Pixel_0_valid_out		<= 0;
				PE6_Pixel_1_out				<= 0;
				PE6_Pixel_1_valid_out		<= 0;
				PE6_Pixel_2_out				<= 0;
				PE6_Pixel_2_valid_out		<= 0;
				  
				PE7_Pixel_0_out				<= 0;
				PE7_Pixel_0_valid_out		<= 0;
				PE7_Pixel_1_out				<= 0;
				PE7_Pixel_1_valid_out		<= 0;
				PE7_Pixel_2_out				<= 0;
				PE7_Pixel_2_valid_out		<= 0;
				  
				PE8_Pixel_0_out				<= 0;
				PE8_Pixel_0_valid_out		<= 0;
				PE8_Pixel_1_out				<= 0;
				PE8_Pixel_1_valid_out		<= 0;
				PE8_Pixel_2_out				<= 0;
				PE8_Pixel_2_valid_out		<= 0;
				  
				PE9_Pixel_0_out				<= 0;
				PE9_Pixel_0_valid_out		<= 0;
				PE9_Pixel_1_out				<= 0;
				PE9_Pixel_1_valid_out		<= 0;
				PE9_Pixel_2_out				<= 0;
				PE9_Pixel_2_valid_out		<= 0;
				
				PE10_Pixel_0_out			<= 0;
				PE10_Pixel_0_valid_out		<= 0;
				PE10_Pixel_1_out			<= 0;
				PE10_Pixel_1_valid_out		<= 0;
				PE10_Pixel_2_out			<= 0;
				PE10_Pixel_2_valid_out		<= 0;
				  
				PE11_Pixel_0_out			<= 0;
				PE11_Pixel_0_valid_out		<= 0;
				PE11_Pixel_1_out			<= 0;
				PE11_Pixel_1_valid_out		<= 0;
				PE11_Pixel_2_out			<= 0;
				PE11_Pixel_2_valid_out		<= 0;
				  
				PE12_Pixel_0_out			<= 0;
				PE12_Pixel_0_valid_out		<= 0;
				PE12_Pixel_1_out			<= 0;
				PE12_Pixel_1_valid_out		<= 0;
				PE12_Pixel_2_out			<= 0;
				PE12_Pixel_2_valid_out		<= 0;
				  
				PE13_Pixel_0_out			<= 0;
				PE13_Pixel_0_valid_out		<= 0;
				PE13_Pixel_1_out			<= 0;
				PE13_Pixel_1_valid_out		<= 0;
				PE13_Pixel_2_out			<= 0;
				PE13_Pixel_2_valid_out		<= 0;
				  
				PE14_Pixel_0_out			<= 0;
				PE14_Pixel_0_valid_out		<= 0;
				PE14_Pixel_1_out			<= 0;
				PE14_Pixel_1_valid_out		<= 0;
				PE14_Pixel_2_out			<= 0;
				PE14_Pixel_2_valid_out		<= 0;
				  
				PE15_Pixel_0_out			<= 0;
				PE15_Pixel_0_valid_out		<= 0;
				PE15_Pixel_1_out			<= 0;
				PE15_Pixel_1_valid_out		<= 0;
				PE15_Pixel_2_out			<= 0;
				PE15_Pixel_2_valid_out		<= 0;
				  
				PE16_Pixel_0_out			<= 0;
				PE16_Pixel_0_valid_out		<= 0;
				PE16_Pixel_1_out			<= 0;
				PE16_Pixel_1_valid_out		<= 0;
				PE16_Pixel_2_out			<= 0;
				PE16_Pixel_2_valid_out		<= 0;
				  
				PE17_Pixel_0_out			<= 0;
				PE17_Pixel_0_valid_out		<= 0;
				PE17_Pixel_1_out			<= 0;
				PE17_Pixel_1_valid_out		<= 0;
				PE17_Pixel_2_out			<= 0;
				PE17_Pixel_2_valid_out		<= 0;
				  
				PE18_Pixel_0_out			<= 0;
				PE18_Pixel_0_valid_out		<= 0;
				PE18_Pixel_1_out			<= 0;
				PE18_Pixel_1_valid_out		<= 0;
				PE18_Pixel_2_out			<= 0;
				PE18_Pixel_2_valid_out		<= 0;
				  
				PE19_Pixel_0_out			<= 0;
				PE19_Pixel_0_valid_out		<= 0;
				PE19_Pixel_1_out			<= 0;
				PE19_Pixel_1_valid_out		<= 0;
				PE19_Pixel_2_out			<= 0;
				PE19_Pixel_2_valid_out		<= 0;			
			end
			Parity_PE_Selection_rg		<= Parity_PE_Selection_in;
		end
	  end
  
endmodule

module MUX_4_1 (
	input [`WORD_BITS-1:0] data0_in,
	input [`WORD_BITS-1:0] data1_in,
	input [`WORD_BITS-1:0] data2_in,
	input [`WORD_BITS-1:0] data3_in,
	input [1:0] sel_in,
	output reg [`WORD_BITS-1:0] mux_4_1_out
);

	always @*
    case(sel_in)
		2'b00: mux_4_1_out = data0_in;
		2'b01: mux_4_1_out = data1_in;
		2'b10: mux_4_1_out = data2_in;
		2'b11: mux_4_1_out = data3_in;
		default: mux_4_1_out = data0_in;
    endcase

endmodule

module MUX_8_1 (
	input [`WORD_BITS-1:0] data0_in,
	input [`WORD_BITS-1:0] data1_in,
	input [`WORD_BITS-1:0] data2_in,
	input [`WORD_BITS-1:0] data3_in,
	input [`WORD_BITS-1:0] data4_in,
	input [`WORD_BITS-1:0] data5_in,
	input [`WORD_BITS-1:0] data6_in,
	input [`WORD_BITS-1:0] data7_in,
	input [2:0] sel_in,
	output reg [`WORD_BITS-1:0] mux_8_1_out
);

	wire [`WORD_BITS-1:0] mux_0, mux_1;

	MUX_4_1 mux0(
		.data0_in(data0_in),
		.data1_in(data1_in),
		.data2_in(data2_in),
		.data3_in(data3_in),
		.sel_in(sel_in[1:0]),
		.mux_4_1_out(mux_0)
	);

	MUX_4_1 mux1(
		.data0_in(data4_in),
		.data1_in(data5_in),
		.data2_in(data6_in),
		.data3_in(data7_in),
		.sel_in(sel_in[1:0]),
		.mux_4_1_out(mux_1)
	);

	always @*
    case(sel_in[2:2])
		1'b0: mux_8_1_out = mux_0;
		1'b1: mux_8_1_out = mux_1;
		default: mux_8_1_out = mux_0;
    endcase

endmodule

module MUX_20_1 (
	input [`WORD_BITS-1:0] data0_in,
	input [`WORD_BITS-1:0] data1_in,
	input [`WORD_BITS-1:0] data2_in,
	input [`WORD_BITS-1:0] data3_in,
	input [`WORD_BITS-1:0] data4_in,
	input [`WORD_BITS-1:0] data5_in,
	input [`WORD_BITS-1:0] data6_in,
	input [`WORD_BITS-1:0] data7_in,
	input [`WORD_BITS-1:0] data8_in,
	input [`WORD_BITS-1:0] data9_in,
	input [`WORD_BITS-1:0] data10_in,
	input [`WORD_BITS-1:0] data11_in,
	input [`WORD_BITS-1:0] data12_in,
	input [`WORD_BITS-1:0] data13_in,
	input [`WORD_BITS-1:0] data14_in,
	input [`WORD_BITS-1:0] data15_in,
	input [`WORD_BITS-1:0] data16_in,
	input [`WORD_BITS-1:0] data17_in,
	input [`WORD_BITS-1:0] data18_in,
	input [`WORD_BITS-1:0] data19_in,
	input [4:0] sel_in,
	output reg [`WORD_BITS-1:0] mux_20_1_out
);

	wire [`WORD_BITS-1:0] mux_0, mux_1, mux_2;

	MUX_8_1 mux0(
		.data0_in(data0_in),
		.data1_in(data1_in),
		.data2_in(data2_in),
		.data3_in(data3_in),
		.data4_in(data4_in),
		.data5_in(data5_in),
		.data6_in(data6_in),
		.data7_in(data7_in),
		.sel_in(sel_in[2:0]),
		.mux_8_1_out(mux_0)
	);

	MUX_8_1 mux1(
		.data0_in(data8_in),
		.data1_in(data9_in),
		.data2_in(data10_in),
		.data3_in(data11_in),
		.data4_in(data12_in),
		.data5_in(data13_in),
		.data6_in(data14_in),
		.data7_in(data15_in),
		.sel_in(sel_in[2:0]),
		.mux_8_1_out(mux_1)
	);

	MUX_4_1 mux2(
		.data0_in(data16_in),
		.data1_in(data17_in),
		.data2_in(data18_in),
		.data3_in(data19_in),
		.sel_in(sel_in[1:0]),
		.mux_4_1_out(mux_2)
	);
	
	always @*
    case(sel_in[4:3])
		2'b00: mux_20_1_out = mux_0;
		2'b01: mux_20_1_out = mux_1;
		2'b10: mux_20_1_out = mux_2;
		default: mux_20_1_out = mux_0;
    endcase

endmodule
