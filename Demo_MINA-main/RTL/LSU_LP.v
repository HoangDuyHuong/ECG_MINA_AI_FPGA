/*
 *-----------------------------------------------------------------------------
 * Title         : LSU
 * Project       : CGRA_ECG
 *-----------------------------------------------------------------------------
 * File          : LSU.v
 * Author        : Pham Hoai Luan
 *                <pham.luan@is.naist.jp>
 * Created       : 2024.10.22
 *-----------------------------------------------------------------------------
 * Last modified : 2024.10.22
 * Copyright (c) 2024 by NAIST This model is the confidential and
 * proprietary property of NAIST and the possession or use of this
 * file requires a written license from NAIST.
 *-----------------------------------------------------------------------------
 * Modification history :
 * 2024.10.22 : created
 *-----------------------------------------------------------------------------
 */
 
`timescale 1ns/1ns
`include "common.vh"

module LSU_LP
(
	input  wire                                 	CLK,
	input  wire                                 	RST,
	
	//-----------------------------------------------------//
	//          			Input Signals                    // 
	//-----------------------------------------------------//
	
	///*** From AXI Bus ***///
	input  wire [`LDM_NUM_BITS+`LDM_ADDR_BITS-1:0] 	AXI_LDM_addra_in,
	input  wire signed [`WORD_BITS-1:0]          	AXI_LDM_dina_in,
	input  wire 					              	AXI_LDM_ena_in,
	input  wire 					              	AXI_LDM_wea_in,
												
	output  wire signed [`WORD_BITS-1:0]         	AXI_LDM_douta_out,
	///*** From the Controller ***///	
	input wire										Padding_Read_in,
	
	input  wire [`S_LDM_BITS+`LDM_ADDR_BITS-1:0]  	CTRL_LDM_addra_in,
	input  wire 					              	CTRL_LDM_ena_in,
	input  wire 					              	CTRL_LDM_wea_in,
	
	input  wire [`S_LDM_BITS+`LDM_ADDR_BITS-1:0]  	CTRL_LDM_addrb_in,
	input  wire 					              	CTRL_LDM_enb_in,
	input  wire 					              	CTRL_LDM_web_in,

	input  wire signed [`ALU_CFG_BITS-2:0]			CFG_in,

	input  wire 					              	layer_done_in,
	input  wire 					              	Stride_in, //0 -> 1, 1 -> 2
	input  wire 					              	CTRL_LDM_addra_Incr_in, //0 -> 1, 1 -> 2
	
	///*** From the ALU ***///
	input  wire [`D_LDM_BITS+`LDM_ADDR_BITS-1:0]  	ALU_LDM_addrb_in,
	input  wire signed [`WORD_BITS-1:0]          	ALU_LDM_dinb_in,
	input  wire 					              	ALU_LDM_enb_in,
	input  wire 					              	ALU_LDM_web_in, 
	
	//-----------------------------------------------------//
	//          			Output Signals                   // 
	//-----------------------------------------------------//  
	
	///*** To Global Buffer ***///
	output wire signed [`WORD_BITS-1:0]           	Pixel_0_out,
	output wire 						           	Pixel_0_valid_out,
	output wire signed [`WORD_BITS-1:0]           	Pixel_1_out,
	output wire 						           	Pixel_1_valid_out,
 	///*** To ALU ***///
	output wire signed [`WORD_BITS-1:0]           	Pixel_2_out,
	output wire 						           	Pixel_2_valid_out,
	output wire										Padding_Read_state_out
);
 
	// *************** Wire signals *************** //
	wire  					     					LDM0_ena_wr, LDM1_ena_wr, LDM2_ena_wr, LDM3_ena_wr, LDM0_enb_wr, LDM1_enb_wr, LDM2_enb_wr, LDM3_enb_wr;
	wire  					     					LDM0_wea_wr, LDM1_wea_wr, LDM2_wea_wr, LDM3_wea_wr, LDM0_web_wr, LDM1_web_wr, LDM2_web_wr, LDM3_web_wr;
	wire [`LDM_ADDR_BITS-1:0]						LDM0_addra_wr, LDM1_addra_wr, LDM2_addra_wr, LDM3_addra_wr, LDM0_addrb_wr, LDM1_addrb_wr, LDM2_addrb_wr, LDM3_addrb_wr;
	wire [`WORD_BITS-1:0]							LDM0_dina_wr, LDM1_dina_wr, LDM2_dina_wr, LDM3_dina_wr, LDM0_dinb_wr, LDM1_dinb_wr, LDM2_dinb_wr, LDM3_dinb_wr;
	wire [`WORD_BITS-1:0]							LDM0_douta_wr, LDM1_douta_wr, LDM2_douta_wr, LDM3_douta_wr, LDM0_doutb_wr, LDM1_doutb_wr, LDM2_doutb_wr, LDM3_doutb_wr;
	wire signed [`WORD_BITS-1:0]           			Pixel_2_wr;
	wire 						           			Pixel_2_valid_wr;
	// *************** Register signals *************** //

	reg  					     					LDM0_ena_rg, LDM1_ena_rg, LDM2_ena_rg, LDM3_ena_rg, LDM0_enb_rg, LDM1_enb_rg, LDM2_enb_rg, LDM3_enb_rg;
	reg  					     					LDM0_wea_rg, LDM1_wea_rg, LDM2_wea_rg, LDM3_wea_rg, LDM0_web_rg, LDM1_web_rg, LDM2_web_rg, LDM3_web_rg;
	reg												AXI_LDM_ena_rg;
	reg [`LDM_NUM_BITS-1:0]  						AXI_LDM_addra_rg;
	reg [`S_LDM_BITS-1:0]  							CTRL_LDM_addra_rg, CTRL_LDM_addrb_rg;
	reg												Padding_Read_rg, Padding_Read_state_rg, CTRL_LDM_addra_Incr_rg;
	reg signed [`WORD_BITS-1:0]           			Pixel_2_rg;
	reg 						           			Pixel_2_valid_rg;
	reg signed [`ALU_CFG_BITS-2:0]					CFG_rg;
	
	assign Padding_Read_state_out	= (Padding_Read_state_rg|Padding_Read_in);
	
	//------- LDM0 -------//
	assign LDM0_ena_wr 		= (AXI_LDM_ena_in & (AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==0)) ? AXI_LDM_ena_in:
							  (CTRL_LDM_ena_in & (CTRL_LDM_addra_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==0)) ? CTRL_LDM_ena_in: 0;
							  
	assign LDM0_wea_wr 		= (AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==0) ? AXI_LDM_wea_in: 0;

	assign LDM0_addra_wr 	= (AXI_LDM_ena_in & (AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==0)) ? AXI_LDM_addra_in[`LDM_ADDR_BITS-1:0]:
							  (CTRL_LDM_ena_in & (CTRL_LDM_addra_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==0)) ? CTRL_LDM_addra_in[`LDM_ADDR_BITS-1:0]: 0;
							  
	assign LDM0_dina_wr 	= (AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==0) ? AXI_LDM_dina_in: 0;

	assign LDM0_enb_wr 		= (ALU_LDM_enb_in & (ALU_LDM_addrb_in[`D_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==0)) ? ALU_LDM_enb_in:
							  (CTRL_LDM_enb_in & (CTRL_LDM_addrb_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==0)) ? CTRL_LDM_enb_in: 0;
							  
	assign LDM0_web_wr 		= (ALU_LDM_enb_in & (ALU_LDM_addrb_in[`D_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==0)) ? ALU_LDM_web_in: 0;

	assign LDM0_addrb_wr 	= (ALU_LDM_enb_in & (ALU_LDM_addrb_in[`D_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==0)) ? ALU_LDM_addrb_in[`LDM_ADDR_BITS-1:0]:
							  (CTRL_LDM_enb_in & (CTRL_LDM_addrb_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==0)) ? CTRL_LDM_addrb_in[`LDM_ADDR_BITS-1:0]: 0;
							  
	assign LDM0_dinb_wr 	= ALU_LDM_dinb_in;
	
	//------- LDM1 -------//
	assign LDM1_ena_wr 		= (AXI_LDM_ena_in & (AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==1)) ? AXI_LDM_ena_in:
							  (CTRL_LDM_ena_in & (CTRL_LDM_addra_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==1)) ? CTRL_LDM_ena_in: 0;
							  
	assign LDM1_wea_wr 		= (AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==1) ? AXI_LDM_wea_in : 0;

	assign LDM1_addra_wr 	= (AXI_LDM_ena_in & (AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==1)) ? AXI_LDM_addra_in[`LDM_ADDR_BITS-1:0]:
							  (CTRL_LDM_ena_in & (CTRL_LDM_addra_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==1)) ? CTRL_LDM_addra_in[`LDM_ADDR_BITS-1:0]: 0;
							  
	assign LDM1_dina_wr 	= (AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS] == 1) ? AXI_LDM_dina_in: 0;

	assign LDM1_enb_wr 		= (ALU_LDM_enb_in & (ALU_LDM_addrb_in[`D_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==1)) ? ALU_LDM_enb_in:
							  (CTRL_LDM_enb_in & (CTRL_LDM_addrb_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==1)) ? CTRL_LDM_enb_in: 0;
							  
	assign LDM1_web_wr 		= (ALU_LDM_enb_in & (ALU_LDM_addrb_in[`D_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==1)) ? ALU_LDM_web_in: 0;

	assign LDM1_addrb_wr 	= (ALU_LDM_enb_in & (ALU_LDM_addrb_in[`D_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==1)) ? ALU_LDM_addrb_in[`LDM_ADDR_BITS-1:0]: 
							  (CTRL_LDM_enb_in & (CTRL_LDM_addrb_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==1)) ? CTRL_LDM_addrb_in[`LDM_ADDR_BITS-1:0]: 0;
							  
	assign LDM1_dinb_wr 	= ALU_LDM_dinb_in;
	
	//------- LDM2 -------//
	assign LDM2_ena_wr 		= (AXI_LDM_ena_in & (AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==2)) ? AXI_LDM_ena_in:
							  (CTRL_LDM_ena_in & (CTRL_LDM_addra_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==2)) ? CTRL_LDM_ena_in: 0;
							  
	assign LDM2_wea_wr 		= 0;

	assign LDM2_addra_wr 	= (AXI_LDM_ena_in & (AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==2)) ? AXI_LDM_addra_in[`LDM_ADDR_BITS-1:0]:
							  (CTRL_LDM_ena_in & (CTRL_LDM_addra_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==2)) ? CTRL_LDM_addra_in[`LDM_ADDR_BITS-1:0]: 0;
							  
	assign LDM2_dina_wr 	= 0;

	assign LDM2_enb_wr 		= (ALU_LDM_enb_in & (ALU_LDM_addrb_in[`D_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==2)) ? ALU_LDM_enb_in:
							  (CTRL_LDM_enb_in & (CTRL_LDM_addrb_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==2)) ? CTRL_LDM_enb_in: 0;
							  
	assign LDM2_web_wr 		= (ALU_LDM_enb_in & (ALU_LDM_addrb_in[`D_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==2)) ? ALU_LDM_web_in: 0;

	assign LDM2_addrb_wr 	= (ALU_LDM_enb_in & (ALU_LDM_addrb_in[`D_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==2)) ? ALU_LDM_addrb_in[`LDM_ADDR_BITS-1:0]: 
							  (CTRL_LDM_enb_in & (CTRL_LDM_addrb_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==2)) ? CTRL_LDM_addrb_in[`LDM_ADDR_BITS-1:0]: 0;
							  
	assign LDM2_dinb_wr 	= ALU_LDM_dinb_in;	
	
	//------- LDM3 -------//
	assign LDM3_ena_wr 		= (CFG_in == `EXE_ADD) ? CTRL_LDM_ena_in: (AXI_LDM_ena_in & (AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==3)) ? AXI_LDM_ena_in:
							 (CTRL_LDM_ena_in & (CTRL_LDM_addra_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==3)) ? CTRL_LDM_ena_in : 0;						  
	assign LDM3_wea_wr 		= 0;
	assign LDM3_addra_wr 	= (CFG_in == `EXE_ADD) ? CTRL_LDM_addra_in: (AXI_LDM_ena_in & (AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==3)) ? AXI_LDM_addra_in[`LDM_ADDR_BITS-1:0]:
						      (CTRL_LDM_ena_in & (CTRL_LDM_addra_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==3)) ? CTRL_LDM_addra_in[`LDM_ADDR_BITS-1:0] : 0;						  
	assign LDM3_dina_wr 	= 0;

	assign LDM3_enb_wr 		= (ALU_LDM_enb_in & (ALU_LDM_addrb_in[`D_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==3)) ? ALU_LDM_enb_in:
							  (CTRL_LDM_enb_in & (CTRL_LDM_addrb_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==3)) ? CTRL_LDM_enb_in: 0;					  
	assign LDM3_web_wr 		= (ALU_LDM_enb_in & (ALU_LDM_addrb_in[`D_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==3)) ? ALU_LDM_web_in: 0;
	assign LDM3_addrb_wr 	= (ALU_LDM_enb_in & (ALU_LDM_addrb_in[`D_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==3)) ? ALU_LDM_addrb_in[`LDM_ADDR_BITS-1:0]: 
							  (CTRL_LDM_enb_in & (CTRL_LDM_addrb_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS]==3)) ? CTRL_LDM_addrb_in[`LDM_ADDR_BITS-1:0]: 0;
							  
	assign LDM3_dinb_wr 	= ALU_LDM_dinb_in;
	
	/// BRAM 16-bit x 64

	Dual_Port_RAM_2 #
	(.DWIDTH(`WORD_BITS), .AWIDTH(`LDM_ADDR_BITS))
	 LDM0 (
	  .clka(CLK), // clock
	  ///*** Port A***///
	  .ena(LDM0_ena_wr), // port A read enable
	  .wea(LDM0_wea_wr), // port A write enable
	  .addra(LDM0_addra_wr), // port A address
	  .dina(LDM0_dina_wr), // port A data
	  .douta(LDM0_douta_wr), // port A data output
	  
	  .clkb(CLK), // clock
	  ///*** Port B***///
	  .enb(LDM0_enb_wr), // port A read enable
	  .web(LDM0_web_wr), // port A write enable
	  .addrb(LDM0_addrb_wr), // port A address
	  .dinb(LDM0_dinb_wr), // port A data
	  .doutb(LDM0_doutb_wr) // port A data output
	  );
	  
	Dual_Port_RAM_2 #
	(.DWIDTH(`WORD_BITS), .AWIDTH(`LDM_ADDR_BITS))
	 LDM1 (
	  .clka(CLK), // clock
	  ///*** Port A***///
	  .ena(LDM1_ena_wr), // port A read enable
	  .wea(LDM1_wea_wr), // port A write enable
	  .addra(LDM1_addra_wr), // port A address
	  .dina(LDM1_dina_wr), // port A data
	  .douta(LDM1_douta_wr), // port A data output
	  
	  .clkb(CLK), // clock
	  ///*** Port B***///
	  .enb(LDM1_enb_wr), // port A read enable
	  .web(LDM1_web_wr), // port A write enable
	  .addrb(LDM1_addrb_wr), // port A address
	  .dinb(LDM1_dinb_wr), // port A data
	  .doutb(LDM1_doutb_wr) // port A data output
	  );

	Dual_Port_RAM_2 #
	(.DWIDTH(`WORD_BITS), .AWIDTH(`LDM_ADDR_BITS))
	 LDM2 (
	  .clka(CLK), // clock
	  ///*** Port A***///
	  .ena(LDM2_ena_wr), // port A read enable
	  .wea(LDM2_wea_wr), // port A write enable
	  .addra(LDM2_addra_wr), // port A address
	  .dina(LDM2_dina_wr), // port A data
	  .douta(LDM2_douta_wr), // port A data output
	  
	  .clkb(CLK), // clock
	  ///*** Port B***///
	  .enb(LDM2_enb_wr), // port A read enable
	  .web(LDM2_web_wr), // port A write enable
	  .addrb(LDM2_addrb_wr), // port A address
	  .dinb(LDM2_dinb_wr), // port A data
	  .doutb(LDM2_doutb_wr) // port A data output
	  );
 
 	Dual_Port_RAM_2 #
	(.DWIDTH(`WORD_BITS), .AWIDTH(`LDM_ADDR_BITS))
	 LDM3 (
	  .clka(CLK), // clock
	  ///*** Port A***///
	  .ena(LDM3_ena_wr), // port A read enable
	  .wea(LDM3_wea_wr), // port A write enable
	  .addra(LDM3_addra_wr), // port A address
	  .dina(LDM3_dina_wr), // port A data
	  .douta(LDM3_douta_wr), // port A data output
	  
	  .clkb(CLK), // clock
	  ///*** Port B***///
	  .enb(LDM3_enb_wr), // port A read enable
	  .web(LDM3_web_wr), // port A write enable
	  .addrb(LDM3_addrb_wr), // port A address
	  .dinb(LDM3_dinb_wr), // port A data
	  .doutb(LDM3_doutb_wr) // port A data output
	  );
	  
	  
	always @(posedge CLK or negedge RST) begin
		if (~RST) begin
			LDM0_ena_rg			<= 0;
			LDM1_ena_rg			<= 0;
			LDM2_ena_rg			<= 0;
			LDM3_ena_rg			<= 0;
			LDM0_enb_rg			<= 0;
			LDM1_enb_rg			<= 0;
			LDM2_enb_rg			<= 0;
			LDM3_enb_rg			<= 0;
			
			LDM0_wea_rg			<= 0;
			LDM1_wea_rg			<= 0;
			LDM2_wea_rg			<= 0;
			LDM3_wea_rg			<= 0;
			LDM0_web_rg			<= 0;
			LDM1_web_rg			<= 0;
			LDM2_web_rg			<= 0;
			LDM3_web_rg			<= 0;
			
			CTRL_LDM_addra_rg	<= 0;
			CTRL_LDM_addrb_rg	<= 0;
			
			Padding_Read_rg		<= 0;
			Padding_Read_state_rg	<= 0;
			
			AXI_LDM_addra_rg	<= 0;
			
			AXI_LDM_ena_rg		<= 0;
			CTRL_LDM_addra_Incr_rg	<= 0;
			
			Pixel_2_rg			<= 0;
			Pixel_2_valid_rg	<= 0;
			
			CFG_rg				<= 0;
		end	
		else begin	
			LDM0_ena_rg			<= LDM0_ena_wr;
			LDM1_ena_rg			<= LDM1_ena_wr;
			LDM2_ena_rg			<= LDM2_ena_wr;
			LDM3_ena_rg			<= LDM3_ena_wr;
			LDM0_enb_rg			<= LDM0_enb_wr;
			LDM1_enb_rg			<= LDM1_enb_wr;
			LDM2_enb_rg			<= LDM2_enb_wr;
			LDM3_enb_rg			<= LDM3_enb_wr;
											
			LDM0_wea_rg			<= LDM0_wea_wr;
			LDM1_wea_rg			<= LDM1_wea_wr;
			LDM2_wea_rg			<= LDM2_wea_wr;
			LDM3_wea_rg			<= LDM3_wea_wr;
			LDM0_web_rg			<= LDM0_web_wr;
			LDM1_web_rg			<= LDM1_web_wr;
			LDM2_web_rg			<= LDM2_web_wr;
			LDM3_web_rg			<= LDM3_web_wr;
			
			CTRL_LDM_addra_rg	<= CTRL_LDM_addra_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS];
			CTRL_LDM_addrb_rg	<= CTRL_LDM_addrb_in[`S_LDM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS];
			if(layer_done_in) begin
				Padding_Read_state_rg	<= 0;
			end
			else if(Padding_Read_in) begin
				Padding_Read_state_rg	<= Padding_Read_in;
			end 
			else begin
				Padding_Read_state_rg	<= Padding_Read_state_rg;
			end
			
			Padding_Read_rg		<= Padding_Read_in;
			
			AXI_LDM_addra_rg	<= AXI_LDM_addra_in[`LDM_NUM_BITS+`LDM_ADDR_BITS-1:`LDM_ADDR_BITS];
			AXI_LDM_ena_rg		<= AXI_LDM_ena_in;
			
			CTRL_LDM_addra_Incr_rg	<= CTRL_LDM_addra_Incr_in;
			
			Pixel_2_rg			<= Pixel_2_wr;
			Pixel_2_valid_rg	<= Pixel_2_valid_wr;
			
			CFG_rg				<= CFG_in;
		end
	 end
  
	assign Pixel_0_out  		= (Padding_Read_rg & ~Stride_in) ? 0 : (Padding_Read_state_rg & ~CTRL_LDM_addra_Incr_rg & Stride_in & (CTRL_LDM_addrb_rg==0)) ? LDM0_doutb_wr : (Padding_Read_state_rg & ~CTRL_LDM_addra_Incr_rg & Stride_in & (CTRL_LDM_addrb_rg==1)) ? LDM1_doutb_wr : (Padding_Read_state_rg & ~CTRL_LDM_addra_Incr_rg & Stride_in & (CTRL_LDM_addrb_rg==2)) ? LDM2_doutb_wr : (Padding_Read_state_rg & ~CTRL_LDM_addra_Incr_rg & Stride_in & (CTRL_LDM_addrb_rg==3)) ? LDM3_doutb_wr : (CTRL_LDM_addra_rg==0) ? LDM0_douta_wr : (CTRL_LDM_addra_rg==1) ? LDM1_douta_wr : (CTRL_LDM_addra_rg==2) ? LDM2_douta_wr : LDM3_douta_wr;							 
	assign Pixel_0_valid_out  	= (CTRL_LDM_addra_rg==0) ? LDM0_ena_rg&~LDM0_wea_rg : (CTRL_LDM_addra_rg==1) ? LDM1_ena_rg&~LDM1_wea_rg : (CTRL_LDM_addra_rg==2) ? LDM2_ena_rg&~LDM2_wea_rg :  LDM3_ena_rg&~LDM3_wea_rg;
								
	assign Pixel_1_out  		= (Padding_Read_rg & Stride_in) ? 0 : (Padding_Read_state_rg & ~CTRL_LDM_addra_Incr_rg & Stride_in & (CTRL_LDM_addra_rg==0)) ? LDM0_douta_wr : (Padding_Read_state_rg & ~CTRL_LDM_addra_Incr_rg & Stride_in & (CTRL_LDM_addrb_rg==1)) ? LDM1_douta_wr : (Padding_Read_state_rg & ~CTRL_LDM_addra_Incr_rg & Stride_in & (CTRL_LDM_addrb_rg==2)) ? LDM2_douta_wr : (Padding_Read_state_rg & ~CTRL_LDM_addra_Incr_rg & Stride_in & (CTRL_LDM_addrb_rg==3)) ? LDM3_douta_wr : (CTRL_LDM_addrb_rg==0) ? LDM0_doutb_wr : (CTRL_LDM_addrb_rg==1) ? LDM1_doutb_wr : (CTRL_LDM_addrb_rg==2) ? LDM2_doutb_wr : LDM3_doutb_wr;
	
	assign Pixel_1_valid_out  	= (CTRL_LDM_addrb_rg==0) ? LDM0_enb_rg&~LDM0_web_rg : (CTRL_LDM_addrb_rg==1) ? LDM1_enb_rg&~LDM1_web_rg : (CTRL_LDM_addrb_rg==2) ? LDM2_enb_rg&~LDM2_web_rg : LDM3_enb_rg&~LDM3_web_rg;
								
	assign Pixel_2_wr	  		= (CFG_rg==`EXE_ADD) ? LDM3_douta_wr : 0;
	assign Pixel_2_valid_wr  	= (CFG_rg==`EXE_ADD) ? LDM3_ena_rg&~LDM3_wea_rg : 0;

	assign Pixel_2_out  		= Pixel_2_rg;
	assign Pixel_2_valid_out  	= Pixel_2_valid_rg;
	
	assign AXI_LDM_douta_out	= ((AXI_LDM_addra_rg==0) & AXI_LDM_ena_rg) ? LDM0_douta_wr : ((AXI_LDM_addra_rg==1) & AXI_LDM_ena_rg) ? LDM1_douta_wr: ((AXI_LDM_addra_rg==2) & AXI_LDM_ena_rg) ? LDM2_douta_wr: ((AXI_LDM_addra_rg==3) & AXI_LDM_ena_rg) ? LDM3_douta_wr: 0;
	
endmodule

