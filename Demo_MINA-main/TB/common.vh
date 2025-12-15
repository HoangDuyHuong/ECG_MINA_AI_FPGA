/*
 *-----------------------------------------------------------------------------
 * Title         : U2CA
 * Project       : CGRA_ECG
 *-----------------------------------------------------------------------------
 * File          : common.vh
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
`define START_BASE_PHYS	 40'h0400000000
`define FINISH_BASE_PHYS 40'h0400000020
`define CTX_PE_BASE_IP	 16'h0401
`define CTX_RC_BASE_IP	 16'h0402
`define CTX_IM_BASE_IP	 16'h0403
`define LMM_BASE_PHYS	 12'h048

`define PE0_BASE_PHYS	 32'h00100000
`define PE1_BASE_PHYS	 32'h00104000
`define PE2_BASE_PHYS	 32'h00108000
`define PE3_BASE_PHYS	 32'h0010C000
`define PE4_BASE_PHYS	 32'h00110000
`define PE5_BASE_PHYS	 32'h00114000
`define PE6_BASE_PHYS	 32'h00118000
`define PE7_BASE_PHYS	 32'h0011C000
`define PE8_BASE_PHYS	 32'h00120000
`define PE9_BASE_PHYS	 32'h00124000
`define PE10_BASE_PHYS	 32'h00120000
`define PE11_BASE_PHYS	 32'h0012C000
`define PE12_BASE_PHYS	 32'h00130000
`define PE13_BASE_PHYS	 32'h00134000
`define PE14_BASE_PHYS	 32'h00138000
`define PE15_BASE_PHYS	 32'h0013C000



///////////////////////////////////////////////
/// 				Controller 	   		   ////
///////////////////////////////////////////////

`define WRAM_ADDR_BITS      13
`define BRAM_ADDR_BITS      8
`define CRAM_ADDR_BITS      6

`define CTX_BITS      		32 // Padding: 2, n: 5, y: 9, k: 5, j: 3, ALU_CFG_BITS: 3, stride: 1, , stride: 1, Residual Connection: 1
`define PAD_BITS      		2
`define N_BITS      		5
`define Y_BITS      		3
`define K_BITS      		5
`define J_BITS      		3
`define STRIDE_BITS      	1
`define S_LDM_BITS     		2
`define D_LDM_BITS     		2
`define SA_LDM_BITS     	6

///////////////////////////////////////////////
/// 	Processing Element Array (PEA) 	   ////
///////////////////////////////////////////////
	
`define PE_NUM		       20
`define PE_NUM_BITS	       5

///***---- Processing Element (PE)----***////
	`define WORD_BITS		   16
///--------- Load Store Unit (LSU) ---------////
	`define LDM_ADDR_BITS      6
	`define LDM_NUM_BITS       2
	`define LSU_CFG_BITS       (1+`LDM_ADDR_BITS)
	`define LSU_LDW            1'd0
	`define LSU_STW            1'd1

///------ Arithmetic Logic Unit (ALU)------///
	`define ALU_CFG_BITS   	   3	
	`define EXE_NOP            2'd0
	`define EXE_MAC	           2'd1
	`define EXE_ADD            2'd2
	`define EXE_MP	           2'd3