/*
 *-----------------------------------------------------------------------------
 * Title         : CNN_1D_Core
 * Project       : CGRA_ECG
 *-----------------------------------------------------------------------------
 * File          : CNN_1D_Core.v
 * Author        : Pham Hoai Luan
 *                <pham.luan@is.naist.jp>
 * Created       : 2024.10.25
 *-----------------------------------------------------------------------------
 * Last modified : 2024.10.25
 * Copyright (c) 2024 by NAIST This model is the confidential and
 * proprietary property of NAIST and the possession or use of this
 * file requires a written license from NAIST.
 *-----------------------------------------------------------------------------
 * Modification history :
 * 2024.10.25 : created
 *-----------------------------------------------------------------------------
 */
 
`timescale 1ns/1ns
`include "common.vh"

module CNN_1D_Core
(
	input  wire                                 	CLK,
	input  wire                                 	RST,
	
	//-----------------------------------------------------//
	//          			Input Signals                  // 
	//-----------------------------------------------------//

	///*** From AXI Mapper ***///				
	input  wire [`PE_NUM_BITS+`LDM_NUM_BITS+`LDM_ADDR_BITS-1:0] AXI_LDM_addra_in,
	input  wire signed [`WORD_BITS-1:0]          	AXI_LDM_dina_in,
	input  wire 					              	AXI_LDM_ena_in,
	input  wire 					              	AXI_LDM_wea_in,

	input  wire [`CRAM_ADDR_BITS-1:0] 				AXI_CRAM_addra_in,
	input  wire signed [`CTX_BITS-1:0]          	AXI_CRAM_dina_in,
	input  wire 					              	AXI_CRAM_ena_in,
	input  wire 					              	AXI_CRAM_wea_in,
	
	input  wire [`WRAM_ADDR_BITS-1:0]   			AXI_WRAM_addra_in,
	input  wire [`WORD_BITS-1:0]              		AXI_WRAM_dina_in,
	input  wire 					              	AXI_WRAM_ena_in,
	input  wire 					              	AXI_WRAM_wea_in,

	input  wire [`BRAM_ADDR_BITS-1:0]   			AXI_BRAM_addra_in,
	input  wire [`WORD_BITS-1:0]              		AXI_BRAM_dina_in,
	input  wire 					              	AXI_BRAM_ena_in,
	input  wire 					              	AXI_BRAM_wea_in,
	
	input  wire 					              	start_in,
	
	//-----------------------------------------------------//
	//          			Output Signals                 // 
	//-----------------------------------------------------//  
	
	///*** To  AXI Mapper  ***///
	output  wire signed [`WORD_BITS-1:0]         	AXI_LDM_douta_out,
	output  wire 						         	complete_out  
);
 
	// *************** Wire signals *************** //
	wire [`CTX_BITS-1:0]             				CTX_wr;	
			
	///*** Context RAM ***///			
	wire [`CRAM_ADDR_BITS-1:0] 						CTRL_CRAM_addrb_wr;
	wire 					              			CTRL_CRAM_enb_wr;
	wire 					              			CTRL_CRAM_web_wr;
		
	///*** Weight RAM ***///			
	wire [`WRAM_ADDR_BITS-1:0] 						CTRL_WRAM_addrb_wr;
	wire 					              			CTRL_WRAM_enb_wr;
	wire 					              			CTRL_WRAM_web_wr;
		
	wire signed [`WORD_BITS-1:0]             		Weight_wr;
	
	///*** Bias RAM ***///			
	wire [`BRAM_ADDR_BITS-1:0] 						CTRL_BRAM_addrb_wr;
	wire 					              			CTRL_BRAM_enb_wr;
	wire 					              			CTRL_BRAM_web_wr;

	wire signed [`WORD_BITS-1:0]             		Bias_wr;
	
	///*** SGB ***///		
	wire [`ALU_CFG_BITS-1:0]      					CFG_wr;
	wire [`PE_NUM_BITS-1:0]  						MUX_Selection_wr;
	wire 					              			Stride_wr; //0 -> 1, 1 -> 2
	wire 					              			MP_Padding_wr;
	
	wire											MP_Padding_2_wr;
	wire											MP_Padding_3_wr;		
	///*** All PEs ***///
	wire 					              			En_wr;	
	wire 					              			layer_done_wr;
			
	wire 					              			Parity_PE_Selection_wr; //0 -> Even PEs, 1 -> Odd PEs
	
	wire [`S_LDM_BITS+`LDM_ADDR_BITS-1:0] 			CTRL_LDM_addra_wr;
	wire 					              			CTRL_LDM_ena_wr;
	wire 					              			CTRL_LDM_wea_wr;
		
	wire [`S_LDM_BITS+`LDM_ADDR_BITS-1:0] 			CTRL_LDM_addrb_wr;
	wire 					              			CTRL_LDM_enb_wr;
	wire 					              			CTRL_LDM_web_wr;
	
	wire [`D_LDM_BITS+`SA_LDM_BITS-1:0] 			CTRL_LDM_Store_wr;
	
	wire signed [`WORD_BITS-1:0]         			AXI_LDM_douta_out_wr[`PE_NUM-1:0];
	///***  specific PEs ***///
	wire											Overarray_wr;
	wire	[`PE_NUM-1:0]							Padding_Read_wr;	
	wire	[`PE_NUM-1:0]							CTRL_LDM_addra_Incr_wr;
	
	///***  AXI Mapper ***///
	wire											complete_wr;
	
	///*** Global Buffer ***///			
	wire 					            			Pixel_0_valid_in_wr[`PE_NUM-1:0];	
	wire signed [`WORD_BITS-1:0]            		Pixel_0_in_wr[`PE_NUM-1:0];
	wire 					            			Pixel_1_valid_in_wr[`PE_NUM-1:0];	
	wire signed [`WORD_BITS-1:0]             		Pixel_1_in_wr[`PE_NUM-1:0];
	wire 					            			Pixel_2_valid_in_wr[`PE_NUM-1:0];	
	wire signed [`WORD_BITS-1:0]             		Pixel_2_in_wr[`PE_NUM-1:0];	

	wire signed [`WORD_BITS-1:0]           			Pixel_0_out_wr[`PE_NUM-1:0];
	wire 						           			Pixel_0_valid_out_wr[`PE_NUM-1:0];
	wire signed [`WORD_BITS-1:0]           			Pixel_1_out_wr[`PE_NUM-1:0];
	wire 						           			Pixel_1_valid_out_wr[`PE_NUM-1:0];	
	
	// *************** Register signals *************** //		
	reg 					            			Weight_valid_1_rg;
	reg 					            			Bias_valid_1_rg;
	reg signed [`WORD_BITS-1:0]             		Weight_rg;
	reg signed [`WORD_BITS-1:0]             		Bias_rg;

	reg 					            			Weight_valid_2_rg;
	reg 					            			Bias_valid_2_rg;
	
	reg  [`CRAM_ADDR_BITS-1:0]	          			CTX_maxaddra_rg;

	reg [`PE_NUM_BITS-1:0]  						MUX_Selection_rg;
	
	assign complete_out		= complete_wr;

    // Assign output by bitwise OR-ing all 16-bit vectors in AXI_LDM_douta_out_wr
    assign AXI_LDM_douta_out = AXI_LDM_douta_out_wr[0] | AXI_LDM_douta_out_wr[1] |
                               AXI_LDM_douta_out_wr[2] | AXI_LDM_douta_out_wr[3] |
                               AXI_LDM_douta_out_wr[4] | AXI_LDM_douta_out_wr[5] |
                               AXI_LDM_douta_out_wr[6] | AXI_LDM_douta_out_wr[7] |
                               AXI_LDM_douta_out_wr[8] | AXI_LDM_douta_out_wr[9] |
                               AXI_LDM_douta_out_wr[10] | AXI_LDM_douta_out_wr[11] |
                               AXI_LDM_douta_out_wr[12] | AXI_LDM_douta_out_wr[13] |
                               AXI_LDM_douta_out_wr[14] | AXI_LDM_douta_out_wr[15] |
                               AXI_LDM_douta_out_wr[16] | AXI_LDM_douta_out_wr[17] |
                               AXI_LDM_douta_out_wr[18] | AXI_LDM_douta_out_wr[19];
							   
	always @(posedge CLK or negedge RST) begin
		if (~RST) begin
			CTX_maxaddra_rg		<= `CRAM_ADDR_BITS'h0;
			Weight_valid_1_rg	<= 0;
			Bias_valid_1_rg		<= 0;
			Weight_valid_2_rg	<= 0;
			Bias_valid_2_rg		<= 0;
			
			Weight_rg			<= 0;
			Bias_rg				<= 0;
			
			MUX_Selection_rg	<= 0;
		end
		else begin
			Weight_valid_1_rg	<= CTRL_WRAM_enb_wr;
			Bias_valid_1_rg		<= CTRL_BRAM_enb_wr;
			
			Weight_valid_2_rg	<= Weight_valid_1_rg;
			Bias_valid_2_rg		<= Bias_valid_1_rg;
			
			if(Weight_valid_1_rg) begin
				Weight_rg		<= Weight_wr;
			end                 
			else begin          
				Weight_rg		<= 0;
			end
			
			if(Bias_valid_1_rg) begin
				Bias_rg			<= Bias_wr;
			end                 
			else begin          
				Bias_rg			<= 0;
			end
			
			MUX_Selection_rg	<= MUX_Selection_wr;
			
			if(AXI_CRAM_ena_in&AXI_CRAM_wea_in) begin
				CTX_maxaddra_rg	<= AXI_CRAM_addra_in[`CRAM_ADDR_BITS-1:0];
			end   
			else begin
				CTX_maxaddra_rg	<= CTX_maxaddra_rg;
			end
		end
	end

	Dual_Port_RAM #
	(.DWIDTH(`CTX_BITS), .AWIDTH(`CRAM_ADDR_BITS))
	 CRAM (
	  .clka(CLK), // clock
	  ///*** Port A***///
	  .ena(AXI_CRAM_ena_in), // port A read enable
	  .wea(AXI_CRAM_wea_in), // port A write enable
	  .addra(AXI_CRAM_addra_in), // port A address
	  .dina(AXI_CRAM_dina_in), // port A data
	  .douta(), // port A data output
	  
	  .clkb(CLK), // clock
	  ///*** Port B***///
	  .enb(CTRL_CRAM_enb_wr), // port A read enable
	  .web(CTRL_CRAM_web_wr), // port A write enable
	  .addrb(CTRL_CRAM_addrb_wr), // port A address
	  .dinb(0), // port A data
	  .doutb(CTX_wr) // port A data output
	  );
	  
	Dual_Port_RAM #
	(.DWIDTH(`WORD_BITS), .AWIDTH(`WRAM_ADDR_BITS))
	 WRAM (
	  .clka(CLK), // clock
	  ///*** Port A***///
	  .ena(AXI_WRAM_ena_in), // port A read enable
	  .wea(AXI_WRAM_wea_in), // port A write enable
	  .addra(AXI_WRAM_addra_in), // port A address
	  .dina(AXI_WRAM_dina_in), // port A data
	  .douta(), // port A data output
	  
	  .clkb(CLK), // clock
	  ///*** Port B***///
	  .enb(CTRL_WRAM_enb_wr), // port A read enable
	  .web(CTRL_WRAM_web_wr), // port A write enable
	  .addrb(CTRL_WRAM_addrb_wr), // port A address
	  .dinb(0), // port A data
	  .doutb(Weight_wr) // port A data output
	  );

	Dual_Port_RAM #
	(.DWIDTH(`WORD_BITS), .AWIDTH(`BRAM_ADDR_BITS))
	 BRAM (
	  .clka(CLK), // clock
	  ///*** Port A***///
	  .ena(AXI_BRAM_ena_in), // port A read enable
	  .wea(AXI_BRAM_wea_in), // port A write enable
	  .addra(AXI_BRAM_addra_in), // port A address
	  .dina(AXI_BRAM_dina_in), // port A data
	  .douta(), // port A data output
	  
	  .clkb(CLK), // clock
	  ///*** Port B***///
	  .enb(CTRL_BRAM_enb_wr), // port A read enable
	  .web(CTRL_BRAM_web_wr), // port A write enable
	  .addrb(CTRL_BRAM_addrb_wr), // port A address
	  .dinb(0), // port A data
	  .doutb(Bias_wr) // port A data output
	  );
	  
	Controller controller
	(
		.CLK(CLK),
		.RST(RST),
		.start_in(start_in),
		.CTX_in(CTX_wr),
		.CTX_Max_addr_in(CTX_maxaddra_rg),    
		.CTRL_CRAM_addrb_out(CTRL_CRAM_addrb_wr),
		.CTRL_CRAM_enb_out(CTRL_CRAM_enb_wr),
		.CTRL_CRAM_web_out(CTRL_CRAM_web_wr),
		.CTRL_WRAM_addrb_out(CTRL_WRAM_addrb_wr),
		.CTRL_WRAM_enb_out(CTRL_WRAM_enb_wr),
		.CTRL_WRAM_web_out(CTRL_WRAM_web_wr),
		.CTRL_BRAM_addrb_out(CTRL_BRAM_addrb_wr),
		.CTRL_BRAM_enb_out(CTRL_BRAM_enb_wr),
		.CTRL_BRAM_web_out(CTRL_BRAM_web_wr),
		.CFG_out(CFG_wr),
		.MUX_Selection_out(MUX_Selection_wr),
		.Stride_out(Stride_wr),
		.Overarray_out(Overarray_wr),
		.MP_Padding_out(MP_Padding_wr),
		.MP_Padding_2_out(MP_Padding_2_wr),
		.MP_Padding_3_out(MP_Padding_3_wr),
		.En_out(En_wr),
		.layer_done_out(layer_done_wr),
		.Parity_PE_Selection_out(Parity_PE_Selection_wr),
		.CTRL_LDM_addra_out(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_out(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_out(CTRL_LDM_wea_wr),
		.CTRL_LDM_addrb_out(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_out(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_out(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_out(CTRL_LDM_Store_wr),
		.Padding_Read_out(Padding_Read_wr),
		.CTRL_LDM_addra_Incr_out(CTRL_LDM_addra_Incr_wr),
		.complete_out(complete_wr)
	);

	SGB sgb_inst
	(
		.CLK(CLK),
		.RST(RST),

		// Map PE0 signals
		.PE0_Pixel_0_in(Pixel_0_out_wr[0]),
		.PE0_Pixel_0_valid_in(Pixel_0_valid_out_wr[0]),
		.PE0_Pixel_1_in(Pixel_1_out_wr[0]),
		.PE0_Pixel_1_valid_in(Pixel_1_valid_out_wr[0]),

		// Map PE1 signals
		.PE1_Pixel_0_in(Pixel_0_out_wr[1]),
		.PE1_Pixel_0_valid_in(Pixel_0_valid_out_wr[1]),
		.PE1_Pixel_1_in(Pixel_1_out_wr[1]),
		.PE1_Pixel_1_valid_in(Pixel_1_valid_out_wr[1]),

		// Map PE2 signals
		.PE2_Pixel_0_in(Pixel_0_out_wr[2]),
		.PE2_Pixel_0_valid_in(Pixel_0_valid_out_wr[2]),
		.PE2_Pixel_1_in(Pixel_1_out_wr[2]),
		.PE2_Pixel_1_valid_in(Pixel_1_valid_out_wr[2]),

		// Map PE3 signals
		.PE3_Pixel_0_in(Pixel_0_out_wr[3]),
		.PE3_Pixel_0_valid_in(Pixel_0_valid_out_wr[3]),
		.PE3_Pixel_1_in(Pixel_1_out_wr[3]),
		.PE3_Pixel_1_valid_in(Pixel_1_valid_out_wr[3]),

		// Continue mapping for PEs 4-18
		.PE4_Pixel_0_in(Pixel_0_out_wr[4]),
		.PE4_Pixel_0_valid_in(Pixel_0_valid_out_wr[4]),
		.PE4_Pixel_1_in(Pixel_1_out_wr[4]),
		.PE4_Pixel_1_valid_in(Pixel_1_valid_out_wr[4]),

		.PE5_Pixel_0_in(Pixel_0_out_wr[5]),
		.PE5_Pixel_0_valid_in(Pixel_0_valid_out_wr[5]),
		.PE5_Pixel_1_in(Pixel_1_out_wr[5]),
		.PE5_Pixel_1_valid_in(Pixel_1_valid_out_wr[5]),

		.PE6_Pixel_0_in(Pixel_0_out_wr[6]),
		.PE6_Pixel_0_valid_in(Pixel_0_valid_out_wr[6]),
		.PE6_Pixel_1_in(Pixel_1_out_wr[6]),
		.PE6_Pixel_1_valid_in(Pixel_1_valid_out_wr[6]),

		.PE7_Pixel_0_in(Pixel_0_out_wr[7]),
		.PE7_Pixel_0_valid_in(Pixel_0_valid_out_wr[7]),
		.PE7_Pixel_1_in(Pixel_1_out_wr[7]),
		.PE7_Pixel_1_valid_in(Pixel_1_valid_out_wr[7]),

		.PE8_Pixel_0_in(Pixel_0_out_wr[8]),
		.PE8_Pixel_0_valid_in(Pixel_0_valid_out_wr[8]),
		.PE8_Pixel_1_in(Pixel_1_out_wr[8]),
		.PE8_Pixel_1_valid_in(Pixel_1_valid_out_wr[8]),

		.PE9_Pixel_0_in(Pixel_0_out_wr[9]),
		.PE9_Pixel_0_valid_in(Pixel_0_valid_out_wr[9]),
		.PE9_Pixel_1_in(Pixel_1_out_wr[9]),
		.PE9_Pixel_1_valid_in(Pixel_1_valid_out_wr[9]),

		.PE10_Pixel_0_in(Pixel_0_out_wr[10]),
		.PE10_Pixel_0_valid_in(Pixel_0_valid_out_wr[10]),
		.PE10_Pixel_1_in(Pixel_1_out_wr[10]),
		.PE10_Pixel_1_valid_in(Pixel_1_valid_out_wr[10]),

		.PE11_Pixel_0_in(Pixel_0_out_wr[11]),
		.PE11_Pixel_0_valid_in(Pixel_0_valid_out_wr[11]),
		.PE11_Pixel_1_in(Pixel_1_out_wr[11]),
		.PE11_Pixel_1_valid_in(Pixel_1_valid_out_wr[11]),

		.PE12_Pixel_0_in(Pixel_0_out_wr[12]),
		.PE12_Pixel_0_valid_in(Pixel_0_valid_out_wr[12]),
		.PE12_Pixel_1_in(Pixel_1_out_wr[12]),
		.PE12_Pixel_1_valid_in(Pixel_1_valid_out_wr[12]),

		.PE13_Pixel_0_in(Pixel_0_out_wr[13]),
		.PE13_Pixel_0_valid_in(Pixel_0_valid_out_wr[13]),
		.PE13_Pixel_1_in(Pixel_1_out_wr[13]),
		.PE13_Pixel_1_valid_in(Pixel_1_valid_out_wr[13]),

		.PE14_Pixel_0_in(Pixel_0_out_wr[14]),
		.PE14_Pixel_0_valid_in(Pixel_0_valid_out_wr[14]),
		.PE14_Pixel_1_in(Pixel_1_out_wr[14]),
		.PE14_Pixel_1_valid_in(Pixel_1_valid_out_wr[14]),

		.PE15_Pixel_0_in(Pixel_0_out_wr[15]),
		.PE15_Pixel_0_valid_in(Pixel_0_valid_out_wr[15]),
		.PE15_Pixel_1_in(Pixel_1_out_wr[15]),
		.PE15_Pixel_1_valid_in(Pixel_1_valid_out_wr[15]),

		.PE16_Pixel_0_in(Pixel_0_out_wr[16]),
		.PE16_Pixel_0_valid_in(Pixel_0_valid_out_wr[16]),
		.PE16_Pixel_1_in(Pixel_1_out_wr[16]),
		.PE16_Pixel_1_valid_in(Pixel_1_valid_out_wr[16]),

		.PE17_Pixel_0_in(Pixel_0_out_wr[17]),
		.PE17_Pixel_0_valid_in(Pixel_0_valid_out_wr[17]),
		.PE17_Pixel_1_in(Pixel_1_out_wr[17]),
		.PE17_Pixel_1_valid_in(Pixel_1_valid_out_wr[17]),

		.PE18_Pixel_0_in(Pixel_0_out_wr[18]),
		.PE18_Pixel_0_valid_in(Pixel_0_valid_out_wr[18]),
		.PE18_Pixel_1_in(Pixel_1_out_wr[18]),
		.PE18_Pixel_1_valid_in(Pixel_1_valid_out_wr[18]),

		.PE19_Pixel_0_in(Pixel_0_out_wr[19]),
		.PE19_Pixel_0_valid_in(Pixel_0_valid_out_wr[19]),
		.PE19_Pixel_1_in(Pixel_1_out_wr[19]),
		.PE19_Pixel_1_valid_in(Pixel_1_valid_out_wr[19]),

		// Map control signals from the Controller
		.En_in(En_wr),
		.CFG_in(CFG_wr[`ALU_CFG_BITS-2:0]),
		.MUX_Selection_in(MUX_Selection_rg),
		.Parity_PE_Selection_in(Parity_PE_Selection_wr),
		.Stride_in(Stride_wr),
		.MP_Padding_in(MP_Padding_wr),
		.MP_Padding_2_in(MP_Padding_2_wr),
		.MP_Padding_3_in(MP_Padding_3_wr),
		
		.PE0_Pixel_0_out(Pixel_0_in_wr[0]),
		.PE0_Pixel_0_valid_out(Pixel_0_valid_in_wr[0]),
		.PE0_Pixel_1_out(Pixel_1_in_wr[0]),
		.PE0_Pixel_1_valid_out(Pixel_1_valid_in_wr[0]),
		.PE0_Pixel_2_out(Pixel_2_in_wr[0]),
		.PE0_Pixel_2_valid_out(Pixel_2_valid_in_wr[0]),
		
		.PE1_Pixel_0_out(Pixel_0_in_wr[1]),
		.PE1_Pixel_0_valid_out(Pixel_0_valid_in_wr[1]),
		.PE1_Pixel_1_out(Pixel_1_in_wr[1]),
		.PE1_Pixel_1_valid_out(Pixel_1_valid_in_wr[1]),
		.PE1_Pixel_2_out(Pixel_2_in_wr[1]),
		.PE1_Pixel_2_valid_out(Pixel_2_valid_in_wr[1]),
		
		.PE2_Pixel_0_out(Pixel_0_in_wr[2]),
		.PE2_Pixel_0_valid_out(Pixel_0_valid_in_wr[2]),
		.PE2_Pixel_1_out(Pixel_1_in_wr[2]),
		.PE2_Pixel_1_valid_out(Pixel_1_valid_in_wr[2]),
		.PE2_Pixel_2_out(Pixel_2_in_wr[2]),
		.PE2_Pixel_2_valid_out(Pixel_2_valid_in_wr[2]),

		.PE3_Pixel_0_out(Pixel_0_in_wr[3]),
		.PE3_Pixel_0_valid_out(Pixel_0_valid_in_wr[3]),
		.PE3_Pixel_1_out(Pixel_1_in_wr[3]),
		.PE3_Pixel_1_valid_out(Pixel_1_valid_in_wr[3]),
		.PE3_Pixel_2_out(Pixel_2_in_wr[3]),
		.PE3_Pixel_2_valid_out(Pixel_2_valid_in_wr[3]),

		.PE4_Pixel_0_out(Pixel_0_in_wr[4]),
		.PE4_Pixel_0_valid_out(Pixel_0_valid_in_wr[4]),
		.PE4_Pixel_1_out(Pixel_1_in_wr[4]),
		.PE4_Pixel_1_valid_out(Pixel_1_valid_in_wr[4]),
		.PE4_Pixel_2_out(Pixel_2_in_wr[4]),
		.PE4_Pixel_2_valid_out(Pixel_2_valid_in_wr[4]),

		.PE5_Pixel_0_out(Pixel_0_in_wr[5]),
		.PE5_Pixel_0_valid_out(Pixel_0_valid_in_wr[5]),
		.PE5_Pixel_1_out(Pixel_1_in_wr[5]),
		.PE5_Pixel_1_valid_out(Pixel_1_valid_in_wr[5]),
		.PE5_Pixel_2_out(Pixel_2_in_wr[5]),
		.PE5_Pixel_2_valid_out(Pixel_2_valid_in_wr[5]),

		.PE6_Pixel_0_out(Pixel_0_in_wr[6]),
		.PE6_Pixel_0_valid_out(Pixel_0_valid_in_wr[6]),
		.PE6_Pixel_1_out(Pixel_1_in_wr[6]),
		.PE6_Pixel_1_valid_out(Pixel_1_valid_in_wr[6]),
		.PE6_Pixel_2_out(Pixel_2_in_wr[6]),
		.PE6_Pixel_2_valid_out(Pixel_2_valid_in_wr[6]),

		.PE7_Pixel_0_out(Pixel_0_in_wr[7]),
		.PE7_Pixel_0_valid_out(Pixel_0_valid_in_wr[7]),
		.PE7_Pixel_1_out(Pixel_1_in_wr[7]),
		.PE7_Pixel_1_valid_out(Pixel_1_valid_in_wr[7]),
		.PE7_Pixel_2_out(Pixel_2_in_wr[7]),
		.PE7_Pixel_2_valid_out(Pixel_2_valid_in_wr[7]),

		.PE8_Pixel_0_out(Pixel_0_in_wr[8]),
		.PE8_Pixel_0_valid_out(Pixel_0_valid_in_wr[8]),
		.PE8_Pixel_1_out(Pixel_1_in_wr[8]),
		.PE8_Pixel_1_valid_out(Pixel_1_valid_in_wr[8]),
		.PE8_Pixel_2_out(Pixel_2_in_wr[8]),
		.PE8_Pixel_2_valid_out(Pixel_2_valid_in_wr[8]),

		.PE9_Pixel_0_out(Pixel_0_in_wr[9]),
		.PE9_Pixel_0_valid_out(Pixel_0_valid_in_wr[9]),
		.PE9_Pixel_1_out(Pixel_1_in_wr[9]),
		.PE9_Pixel_1_valid_out(Pixel_1_valid_in_wr[9]),
		.PE9_Pixel_2_out(Pixel_2_in_wr[9]),
		.PE9_Pixel_2_valid_out(Pixel_2_valid_in_wr[9]),

		.PE10_Pixel_0_out(Pixel_0_in_wr[10]),
		.PE10_Pixel_0_valid_out(Pixel_0_valid_in_wr[10]),
		.PE10_Pixel_1_out(Pixel_1_in_wr[10]),
		.PE10_Pixel_1_valid_out(Pixel_1_valid_in_wr[10]),
		.PE10_Pixel_2_out(Pixel_2_in_wr[10]),
		.PE10_Pixel_2_valid_out(Pixel_2_valid_in_wr[10]),

		.PE11_Pixel_0_out(Pixel_0_in_wr[11]),
		.PE11_Pixel_0_valid_out(Pixel_0_valid_in_wr[11]),
		.PE11_Pixel_1_out(Pixel_1_in_wr[11]),
		.PE11_Pixel_1_valid_out(Pixel_1_valid_in_wr[11]),
		.PE11_Pixel_2_out(Pixel_2_in_wr[11]),
		.PE11_Pixel_2_valid_out(Pixel_2_valid_in_wr[11]),

		.PE12_Pixel_0_out(Pixel_0_in_wr[12]),
		.PE12_Pixel_0_valid_out(Pixel_0_valid_in_wr[12]),
		.PE12_Pixel_1_out(Pixel_1_in_wr[12]),
		.PE12_Pixel_1_valid_out(Pixel_1_valid_in_wr[12]),
		.PE12_Pixel_2_out(Pixel_2_in_wr[12]),
		.PE12_Pixel_2_valid_out(Pixel_2_valid_in_wr[12]),

		.PE13_Pixel_0_out(Pixel_0_in_wr[13]),
		.PE13_Pixel_0_valid_out(Pixel_0_valid_in_wr[13]),
		.PE13_Pixel_1_out(Pixel_1_in_wr[13]),
		.PE13_Pixel_1_valid_out(Pixel_1_valid_in_wr[13]),
		.PE13_Pixel_2_out(Pixel_2_in_wr[13]),
		.PE13_Pixel_2_valid_out(Pixel_2_valid_in_wr[13]),

		.PE14_Pixel_0_out(Pixel_0_in_wr[14]),
		.PE14_Pixel_0_valid_out(Pixel_0_valid_in_wr[14]),
		.PE14_Pixel_1_out(Pixel_1_in_wr[14]),
		.PE14_Pixel_1_valid_out(Pixel_1_valid_in_wr[14]),
		.PE14_Pixel_2_out(Pixel_2_in_wr[14]),
		.PE14_Pixel_2_valid_out(Pixel_2_valid_in_wr[14]),

		.PE15_Pixel_0_out(Pixel_0_in_wr[15]),
		.PE15_Pixel_0_valid_out(Pixel_0_valid_in_wr[15]),
		.PE15_Pixel_1_out(Pixel_1_in_wr[15]),
		.PE15_Pixel_1_valid_out(Pixel_1_valid_in_wr[15]),
		.PE15_Pixel_2_out(Pixel_2_in_wr[15]),
		.PE15_Pixel_2_valid_out(Pixel_2_valid_in_wr[15]),

		.PE16_Pixel_0_out(Pixel_0_in_wr[16]),
		.PE16_Pixel_0_valid_out(Pixel_0_valid_in_wr[16]),
		.PE16_Pixel_1_out(Pixel_1_in_wr[16]),
		.PE16_Pixel_1_valid_out(Pixel_1_valid_in_wr[16]),
		.PE16_Pixel_2_out(Pixel_2_in_wr[16]),
		.PE16_Pixel_2_valid_out(Pixel_2_valid_in_wr[16]),

		.PE17_Pixel_0_out(Pixel_0_in_wr[17]),
		.PE17_Pixel_0_valid_out(Pixel_0_valid_in_wr[17]),
		.PE17_Pixel_1_out(Pixel_1_in_wr[17]),
		.PE17_Pixel_1_valid_out(Pixel_1_valid_in_wr[17]),
		.PE17_Pixel_2_out(Pixel_2_in_wr[17]),
		.PE17_Pixel_2_valid_out(Pixel_2_valid_in_wr[17]),

		.PE18_Pixel_0_out(Pixel_0_in_wr[18]),
		.PE18_Pixel_0_valid_out(Pixel_0_valid_in_wr[18]),
		.PE18_Pixel_1_out(Pixel_1_in_wr[18]),
		.PE18_Pixel_1_valid_out(Pixel_1_valid_in_wr[18]),
		.PE18_Pixel_2_out(Pixel_2_in_wr[18]),
		.PE18_Pixel_2_valid_out(Pixel_2_valid_in_wr[18]),

		.PE19_Pixel_0_out(Pixel_0_in_wr[19]),
		.PE19_Pixel_0_valid_out(Pixel_0_valid_in_wr[19]),
		.PE19_Pixel_1_out(Pixel_1_in_wr[19]),
		.PE19_Pixel_1_valid_out(Pixel_1_valid_in_wr[19]),
		.PE19_Pixel_2_out(Pixel_2_in_wr[19]),
		.PE19_Pixel_2_valid_out(Pixel_2_valid_in_wr[19])

	);


	PE_RP 
	#(
		.UNIT_NO(0)
	)
	pe0 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),												
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[0]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),	
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),	
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[0]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[0]), 
		.Weight_valid_in(Weight_valid_2_rg),	
		.Weight_in(Weight_rg),	
		.Bias_valid_in(Bias_valid_2_rg),	
		.Bias_in(Bias_rg),			
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[0]),	
		.Pixel_0_in(Pixel_0_in_wr[0]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[0]),	
		.Pixel_1_in(Pixel_1_in_wr[0]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[0]),	
		.Pixel_2_in(Pixel_2_in_wr[0]),	
		.Pixel_0_out(Pixel_0_out_wr[0]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[0]),
		.Pixel_1_out(Pixel_1_out_wr[0]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[0])
	);

	PE_RP 
	#(
		.UNIT_NO(1)
	)
	pe1 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),												
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[1]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),	
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),	
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[1]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[1]), 
		.Weight_valid_in(Weight_valid_2_rg),	
		.Weight_in(Weight_rg),	
		.Bias_valid_in(Bias_valid_2_rg),	
		.Bias_in(Bias_rg),			
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[1]),	
		.Pixel_0_in(Pixel_0_in_wr[1]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[1]),	
		.Pixel_1_in(Pixel_1_in_wr[1]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[1]),	
		.Pixel_2_in(Pixel_2_in_wr[1]),	
		.Pixel_0_out(Pixel_0_out_wr[1]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[1]),
		.Pixel_1_out(Pixel_1_out_wr[1]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[1])
	);	

	PE_RP 
	#(
		.UNIT_NO(2)
	)
	pe2 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[2]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[2]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[2]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[2]),    
		.Pixel_0_in(Pixel_0_in_wr[2]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[2]),    
		.Pixel_1_in(Pixel_1_in_wr[2]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[2]),    
		.Pixel_2_in(Pixel_2_in_wr[2]),    
		.Pixel_0_out(Pixel_0_out_wr[2]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[2]),
		.Pixel_1_out(Pixel_1_out_wr[2]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[2])
	);

	PE_RP 
	#(
		.UNIT_NO(3)
	)
	pe3 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[3]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[3]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[3]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[3]),    
		.Pixel_0_in(Pixel_0_in_wr[3]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[3]),    
		.Pixel_1_in(Pixel_1_in_wr[3]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[3]),    
		.Pixel_2_in(Pixel_2_in_wr[3]),    
		.Pixel_0_out(Pixel_0_out_wr[3]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[3]),
		.Pixel_1_out(Pixel_1_out_wr[3]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[3])
	);

	PE 
	#(
		.UNIT_NO(4)
	)
	pe4 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[4]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[4]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[4]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[4]),    
		.Pixel_0_in(Pixel_0_in_wr[4]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[4]),    
		.Pixel_1_in(Pixel_1_in_wr[4]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[4]),    
		.Pixel_2_in(Pixel_2_in_wr[4]),    
		.Pixel_0_out(Pixel_0_out_wr[4]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[4]),
		.Pixel_1_out(Pixel_1_out_wr[4]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[4])
	);

	PE 
	#(
		.UNIT_NO(5)
	)
	pe5 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[5]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[5]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[5]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[5]),    
		.Pixel_0_in(Pixel_0_in_wr[5]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[5]),    
		.Pixel_1_in(Pixel_1_in_wr[5]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[5]),    
		.Pixel_2_in(Pixel_2_in_wr[5]),    
		.Pixel_0_out(Pixel_0_out_wr[5]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[5]),
		.Pixel_1_out(Pixel_1_out_wr[5]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[5])
	);

	PE 
	#(
		.UNIT_NO(6)
	)
	pe6 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[6]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[6]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[6]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[6]),    
		.Pixel_0_in(Pixel_0_in_wr[6]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[6]),    
		.Pixel_1_in(Pixel_1_in_wr[6]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[6]),    
		.Pixel_2_in(Pixel_2_in_wr[6]),    
		.Pixel_0_out(Pixel_0_out_wr[6]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[6]),
		.Pixel_1_out(Pixel_1_out_wr[6]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[6])
	);

	PE 
	#(
		.UNIT_NO(7)
	)
	pe7 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[7]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[7]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[7]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[7]),    
		.Pixel_0_in(Pixel_0_in_wr[7]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[7]),    
		.Pixel_1_in(Pixel_1_in_wr[7]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[7]),    
		.Pixel_2_in(Pixel_2_in_wr[7]),    
		.Pixel_0_out(Pixel_0_out_wr[7]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[7]),
		.Pixel_1_out(Pixel_1_out_wr[7]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[7])
	);

	PE 
	#(
		.UNIT_NO(8)
	)
	pe8 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[8]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[8]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[8]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[8]),    
		.Pixel_0_in(Pixel_0_in_wr[8]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[8]),    
		.Pixel_1_in(Pixel_1_in_wr[8]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[8]),    
		.Pixel_2_in(Pixel_2_in_wr[8]),    
		.Pixel_0_out(Pixel_0_out_wr[8]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[8]),
		.Pixel_1_out(Pixel_1_out_wr[8]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[8])
	);


	PE 
	#(
		.UNIT_NO(9)
	)
	pe9 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[9]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[9]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[9]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[9]),    
		.Pixel_0_in(Pixel_0_in_wr[9]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[9]),    
		.Pixel_1_in(Pixel_1_in_wr[9]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[9]),    
		.Pixel_2_in(Pixel_2_in_wr[9]),    
		.Pixel_0_out(Pixel_0_out_wr[9]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[9]),
		.Pixel_1_out(Pixel_1_out_wr[9]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[9])
	);

	PE 
	#(
		.UNIT_NO(10)
	)
	pe10 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[10]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[10]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[10]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[10]),    
		.Pixel_0_in(Pixel_0_in_wr[10]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[10]),    
		.Pixel_1_in(Pixel_1_in_wr[10]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[10]),    
		.Pixel_2_in(Pixel_2_in_wr[10]),    
		.Pixel_0_out(Pixel_0_out_wr[10]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[10]),
		.Pixel_1_out(Pixel_1_out_wr[10]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[10])
	);

	PE
	#(
		.UNIT_NO(11)
	)
	pe11 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[11]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[11]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[11]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[11]),    
		.Pixel_0_in(Pixel_0_in_wr[11]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[11]),    
		.Pixel_1_in(Pixel_1_in_wr[11]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[11]),    
		.Pixel_2_in(Pixel_2_in_wr[11]),    
		.Pixel_0_out(Pixel_0_out_wr[11]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[11]),
		.Pixel_1_out(Pixel_1_out_wr[11]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[11])
	);

	PE 
	#(
		.UNIT_NO(12)
	)
	pe12 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[12]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[12]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[12]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[12]),    
		.Pixel_0_in(Pixel_0_in_wr[12]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[12]),    
		.Pixel_1_in(Pixel_1_in_wr[12]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[12]),    
		.Pixel_2_in(Pixel_2_in_wr[12]),    
		.Pixel_0_out(Pixel_0_out_wr[12]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[12]),
		.Pixel_1_out(Pixel_1_out_wr[12]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[12])
	);

	PE 
	#(
		.UNIT_NO(13)
	)
	pe13 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[13]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[13]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[13]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[13]),    
		.Pixel_0_in(Pixel_0_in_wr[13]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[13]),    
		.Pixel_1_in(Pixel_1_in_wr[13]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[13]),    
		.Pixel_2_in(Pixel_2_in_wr[13]),    
		.Pixel_0_out(Pixel_0_out_wr[13]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[13]),
		.Pixel_1_out(Pixel_1_out_wr[13]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[13])
	);

	PE 
	#(
		.UNIT_NO(14)
	)
	pe14 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[14]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[14]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[14]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[14]),    
		.Pixel_0_in(Pixel_0_in_wr[14]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[14]),    
		.Pixel_1_in(Pixel_1_in_wr[14]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[14]),    
		.Pixel_2_in(Pixel_2_in_wr[14]),    
		.Pixel_0_out(Pixel_0_out_wr[14]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[14]),
		.Pixel_1_out(Pixel_1_out_wr[14]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[14])
	);

	PE 
	#(
		.UNIT_NO(15)
	)
	pe15 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[15]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[15]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[15]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[15]),    
		.Pixel_0_in(Pixel_0_in_wr[15]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[15]),    
		.Pixel_1_in(Pixel_1_in_wr[15]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[15]),    
		.Pixel_2_in(Pixel_2_in_wr[15]),    
		.Pixel_0_out(Pixel_0_out_wr[15]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[15]),
		.Pixel_1_out(Pixel_1_out_wr[15]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[15])
	);

	PE 
	#(
		.UNIT_NO(16)
	)
	pe16 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[16]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[16]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[16]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[16]),    
		.Pixel_0_in(Pixel_0_in_wr[16]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[16]),    
		.Pixel_1_in(Pixel_1_in_wr[16]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[16]),    
		.Pixel_2_in(Pixel_2_in_wr[16]),    
		.Pixel_0_out(Pixel_0_out_wr[16]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[16]),
		.Pixel_1_out(Pixel_1_out_wr[16]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[16])
	);

	PE_LP 
	#(
		.UNIT_NO(17)
	)
	pe17 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[17]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[17]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[17]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[17]),    
		.Pixel_0_in(Pixel_0_in_wr[17]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[17]),    
		.Pixel_1_in(Pixel_1_in_wr[17]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[17]),    
		.Pixel_2_in(Pixel_2_in_wr[17]),    
		.Pixel_0_out(Pixel_0_out_wr[17]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[17]),
		.Pixel_1_out(Pixel_1_out_wr[17]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[17])
	);

	PE_LP 
	#(
		.UNIT_NO(18)
	)
	pe18 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[18]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Padding_Read_in(Padding_Read_wr[18]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[18]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[18]),    
		.Pixel_0_in(Pixel_0_in_wr[18]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[18]),    
		.Pixel_1_in(Pixel_1_in_wr[18]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[18]),    
		.Pixel_2_in(Pixel_2_in_wr[18]),    
		.Pixel_0_out(Pixel_0_out_wr[18]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[18]),
		.Pixel_1_out(Pixel_1_out_wr[18]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[18])
	);

	PE_LP_Last 
	#(
		.UNIT_NO(19)
	)
	pe19 (
		.CLK(CLK),
		.RST(RST),
		.AXI_LDM_addra_in(AXI_LDM_addra_in),
		.AXI_LDM_dina_in(AXI_LDM_dina_in),
		.AXI_LDM_ena_in(AXI_LDM_ena_in),
		.AXI_LDM_wea_in(AXI_LDM_wea_in),                                                
		.AXI_LDM_douta_out(AXI_LDM_douta_out_wr[19]),
		.layer_done_in(layer_done_wr),
		.En_in(En_wr),
		.CFG_in(CFG_wr),    
		.Parity_PE_Selection_in(Parity_PE_Selection_wr), 
		.CTRL_LDM_addra_in(CTRL_LDM_addra_wr),
		.CTRL_LDM_ena_in(CTRL_LDM_ena_wr),
		.CTRL_LDM_wea_in(CTRL_LDM_wea_wr),    
		.CTRL_LDM_addrb_in(CTRL_LDM_addrb_wr),
		.CTRL_LDM_enb_in(CTRL_LDM_enb_wr),
		.CTRL_LDM_web_in(CTRL_LDM_web_wr),
		.CTRL_LDM_Store_in(CTRL_LDM_Store_wr),
		.Stride_in(Stride_wr),
		.Overarray_in(Overarray_wr),
		.Padding_Read_in(Padding_Read_wr[19]), 
		.CTRL_LDM_addra_Incr_in(CTRL_LDM_addra_Incr_wr[19]), 
		.Weight_valid_in(Weight_valid_2_rg),    
		.Weight_in(Weight_rg),    
		.Bias_valid_in(Bias_valid_2_rg),    
		.Bias_in(Bias_rg),            
		.Pixel_0_valid_in(Pixel_0_valid_in_wr[19]),    
		.Pixel_0_in(Pixel_0_in_wr[19]),
		.Pixel_1_valid_in(Pixel_1_valid_in_wr[19]),    
		.Pixel_1_in(Pixel_1_in_wr[19]),
		.Pixel_2_valid_in(Pixel_2_valid_in_wr[19]),    
		.Pixel_2_in(Pixel_2_in_wr[19]),    
		.Pixel_0_out(Pixel_0_out_wr[19]),
		.Pixel_0_valid_out(Pixel_0_valid_out_wr[19]),
		.Pixel_1_out(Pixel_1_out_wr[19]),
		.Pixel_1_valid_out(Pixel_1_valid_out_wr[19])
	);
	
endmodule

