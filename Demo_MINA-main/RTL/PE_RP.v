/*
 *-----------------------------------------------------------------------------
 * Title         : Processing Element
 * Project       : CGRA_ECG
 *-----------------------------------------------------------------------------
 * File          : PE.v
 * Author        : Pham Hoai Luan
 *                <pham.luan@is.naist.jp>
 * Created       : 2024.10.17
 *-----------------------------------------------------------------------------
 * Last modified : 2024.10.17
 * Copyright (c) 2024 by NAIST This model is the confidential and
 * proprietary property of NAIST and the possession or use of this
 * file requires a written license from NAIST.
 *-----------------------------------------------------------------------------
 * Modification history :
 * 2024.10.17 : created
 *-----------------------------------------------------------------------------
 */
 
`timescale 1ns/1ns
`include "common.vh"

module PE_RP
#(
	parameter                                   	UNIT_NO = 0
)
(
	input  wire                                 	CLK,
	input  wire                                 	RST,
	
	//-----------------------------------------------------//
	//          			Input Signals                  // 
	//-----------------------------------------------------//

	///*** From AXI Bus ***///				
	input  wire [`PE_NUM_BITS+`LDM_NUM_BITS+`LDM_ADDR_BITS-1:0] AXI_LDM_addra_in,
	input  wire signed [`WORD_BITS-1:0]          	AXI_LDM_dina_in,
	input  wire 					              	AXI_LDM_ena_in,
	input  wire 					              	AXI_LDM_wea_in,
												
	output  wire signed [`WORD_BITS-1:0]         	AXI_LDM_douta_out,

	///*** From the Controller ***///	
	input  wire 					              	En_in,
	
	input  wire 					              	layer_done_in,
	input  wire signed [`ALU_CFG_BITS-1:0]			CFG_in,
	
	input  wire 					              	Parity_PE_Selection_in, //0 -> Even PEs, 1 -> Odd PEs
	
	input  wire [`S_LDM_BITS+`LDM_ADDR_BITS-1:0]  	CTRL_LDM_addra_in,
	input  wire 					              	CTRL_LDM_ena_in,
	input  wire 					              	CTRL_LDM_wea_in,
	
	input  wire [`S_LDM_BITS+`LDM_ADDR_BITS-1:0]  	CTRL_LDM_addrb_in,
	input  wire 					              	CTRL_LDM_enb_in,
	input  wire 					              	CTRL_LDM_web_in,

	input  wire [`D_LDM_BITS+`SA_LDM_BITS-1:0]  	CTRL_LDM_Store_in,
	
	input  wire 					              	Stride_in, //0 -> 1, 1 -> 2
	input  wire 					              	Padding_Read_in, //0 -> 1, 1 -> 2
	
	input  wire 					              	CTRL_LDM_addra_Incr_in, //0 -> 1, 1 -> 2
	
	///*** From the Weight RAM ***///	
	input  wire 					            	Weight_valid_in,	
	input  wire signed [`WORD_BITS-1:0]             Weight_in,

	///*** From the Bias RAM ***///	
	input  wire 					            	Bias_valid_in,	
	input  wire signed [`WORD_BITS-1:0]             Bias_in,
	
	///*** From Global Buffer ***///			
	input  wire 					            	Pixel_0_valid_in,	
	input  wire signed [`WORD_BITS-1:0]             Pixel_0_in,
	input  wire 					            	Pixel_1_valid_in,	
	input  wire signed [`WORD_BITS-1:0]             Pixel_1_in,
	input  wire 					            	Pixel_2_valid_in,	
	input  wire signed [`WORD_BITS-1:0]             Pixel_2_in,	
	//-----------------------------------------------------//
	//          			Output Signals                 // 
	//-----------------------------------------------------//  
	
	///*** To Global Buffer ***///
	output wire signed [`WORD_BITS-1:0]           	Pixel_0_out,
	output wire 						           	Pixel_0_valid_out,
	output wire signed [`WORD_BITS-1:0]           	Pixel_1_out,
	output wire 						           	Pixel_1_valid_out
  
);
 
	// *************** Wire signals *************** //
	wire  					           	  			S0_valid_wr;
	wire signed [`WORD_BITS-1:0]           	  		S0_wr;
	wire  					           	  			S1_valid_wr;
	wire signed [`WORD_BITS-1:0]           	  		S1_wr;
	wire  					           	  			S2_valid_wr;
	wire signed [`WORD_BITS-1:0]           	  		S2_wr;

	wire  					           	  			D0_valid_wr;
	wire signed [`WORD_BITS-1:0]           	  		D0_wr;

	wire signed [`WORD_BITS-1:0]           			Pixel_2_out_wr;
	wire 						           			Pixel_2_valid_out_wr;
	
	wire [`LDM_ADDR_BITS-1:0] 						CTRL_LDM_addra_wr;
	wire [`LDM_ADDR_BITS-1:0] 						CTRL_LDM_addrb_wr;
	
	wire 					              			CTRL_LDM_ena_wr, CTRL_LDM_enb_wr;

	
	wire signed [`WORD_BITS-1:0]          			ALU_LDM_dinb_wr;
	wire 					              			ALU_LDM_enb_wr;
	wire 					              			ALU_LDM_web_wr;
	wire [`D_LDM_BITS+`LDM_ADDR_BITS-1:0]  		ALU_LDM_addrb_wr;
	
	// *************** Register signals *************** //		

	reg [`LDM_ADDR_BITS-1:0]  						ALU_LDM_addrb_rg;
	reg												Pixel_0_valid_rg;
								
	/// LDM memory			
				
	wire 					              			AXI_LDM_ena_wr;
					
	assign AXI_LDM_ena_wr 		= (AXI_LDM_addra_in[`PE_NUM_BITS+`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_NUM_BITS+`LDM_ADDR_BITS] == UNIT_NO) ? AXI_LDM_ena_in: 1'b0;
		
	assign CTRL_LDM_ena_wr		= (Stride_in & (UNIT_NO[0] != Parity_PE_Selection_in)) ? 0 : CTRL_LDM_ena_in;
	assign CTRL_LDM_enb_wr		= (Stride_in & (UNIT_NO[0] != Parity_PE_Selection_in)) ? 0 : CTRL_LDM_enb_in;
	
	assign S0_valid_wr 			= (CFG_in[`ALU_CFG_BITS-2:0] == `EXE_MAC) ? Weight_valid_in : Pixel_0_valid_in;
	assign S0_wr 				= (CFG_in[`ALU_CFG_BITS-2:0] == `EXE_MAC) ? Weight_in : Pixel_0_in;
		
	assign S1_valid_wr 			= (CFG_in[`ALU_CFG_BITS-2:0] == `EXE_MP) ? Pixel_1_valid_in : Pixel_0_valid_in;
	assign S1_wr 				= (CFG_in[`ALU_CFG_BITS-2:0] == `EXE_MP) ? Pixel_1_in : Pixel_0_in;
		
	assign S2_valid_wr 			= (CFG_in[`ALU_CFG_BITS-2:0] == `EXE_MP) ? Pixel_2_valid_in : 
								  (CFG_in[`ALU_CFG_BITS-2:0] == `EXE_MAC) ? Bias_valid_in: Pixel_2_valid_out_wr;
								
	assign S2_wr 				= (CFG_in[`ALU_CFG_BITS-2:0] == `EXE_MP) ? Pixel_2_in : 
								  ((CFG_in[`ALU_CFG_BITS-2:0] == `EXE_MAC) & (Bias_valid_in)) ? Bias_in: Pixel_2_out_wr;
	
	assign CTRL_LDM_addra_wr	= CTRL_LDM_addra_Incr_in + CTRL_LDM_addra_in[`LDM_ADDR_BITS-1:0];
	assign CTRL_LDM_addrb_wr	= CTRL_LDM_addra_Incr_in + CTRL_LDM_addrb_in[`LDM_ADDR_BITS-1:0];
	
	LSU_RP lsu(
		.CLK(CLK),
		.RST(RST),
		///*** From AXI Bus ***///
		.AXI_LDM_addra_in(AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:0]),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_wr),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),
		.AXI_LDM_douta_out(AXI_LDM_douta_out),
		///*** From the Controller ***///
		.CTRL_LDM_addra_in({CTRL_LDM_addra_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS],CTRL_LDM_addra_wr}),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_in),
		.CTRL_LDM_addrb_in({CTRL_LDM_addrb_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS],CTRL_LDM_addrb_wr}),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_in),
		.Padding_Read_in(Padding_Read_in),
		.CFG_in(CFG_in[`ALU_CFG_BITS-2:0]),
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_in),
		.Stride_in(Stride_in),
		///*** From the ALU ***///		
		.ALU_LDM_addrb_in(ALU_LDM_addrb_wr),
		.ALU_LDM_dinb_in(ALU_LDM_dinb_wr),
		.ALU_LDM_enb_in(ALU_LDM_enb_wr),
		.ALU_LDM_web_in(ALU_LDM_web_wr),
		
		///*** To Global Buffer ***///
		.Pixel_0_out(Pixel_0_out),
		.Pixel_0_valid_out(Pixel_0_valid_out),
		.Pixel_1_out(Pixel_1_out),
		.Pixel_1_valid_out(Pixel_1_valid_out),		
	

		///*** To ALU ***///
		.Pixel_2_out(Pixel_2_out_wr),
		.Pixel_2_valid_out(Pixel_2_valid_out_wr)	
	);
 
	ALU alu
	(
		.CLK(CLK),
		.RST(RST),
		.En_in(En_in),
		.CFG_in(CFG_in[`ALU_CFG_BITS-2:0]),
		.ReLU_en_in(CFG_in[`ALU_CFG_BITS-1:`ALU_CFG_BITS-1]),
		.S0_valid_in(S0_valid_wr),
		.S0_in(S0_wr),
		.S1_valid_in(S1_valid_wr),
		.S1_in(S1_wr),
		.S2_valid_in(S2_valid_wr),
		.S2_in(S2_wr),
		.D0_out(D0_wr),
		.Valid_out(D0_valid_wr)
	);

	assign ALU_LDM_dinb_wr 	= D0_wr;
	assign ALU_LDM_enb_wr 	= D0_valid_wr&En_in;
	assign ALU_LDM_web_wr 	= D0_valid_wr&En_in;
	assign ALU_LDM_addrb_wr	= {CTRL_LDM_Store_in[`D_LDM_BITS+`SA_LDM_BITS-1:`SA_LDM_BITS],ALU_LDM_addrb_rg+CTRL_LDM_Store_in[`SA_LDM_BITS-1:0]};
	
	always @(posedge CLK or negedge RST) begin
		if (~RST) begin
			ALU_LDM_addrb_rg	<= 6'h3F;
			Pixel_0_valid_rg	<= 0;
		end	
		else begin	
			
			if(layer_done_in) begin
				ALU_LDM_addrb_rg	<= 6'h3F;
				Pixel_0_valid_rg	<= 0;
			end
			else if(En_in) begin
				Pixel_0_valid_rg	<= Pixel_0_valid_in;
				if(CFG_in[`ALU_CFG_BITS-2:0] == `EXE_MAC) begin
					ALU_LDM_addrb_rg	<= ALU_LDM_addrb_rg + Bias_valid_in;
				end
				else begin
					ALU_LDM_addrb_rg	<= ALU_LDM_addrb_rg + Pixel_0_valid_rg;
				end
			end
		end
	 end
  
endmodule

