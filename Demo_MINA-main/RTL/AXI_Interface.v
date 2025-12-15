
`timescale 1 ns / 1 ps
/*-----------------------------------------------------------------------------*/
/*  Common header for U2CP.v                                                  */
/*-----------------------------------------------------------------------------*/

//Write control
`define START_BASE_PHYS	 40'h0400000000

//Read control
`define DONE_BASE_PHYS	 40'h0400000000

//Write Data
//`define LDM_INPUT_BASE_PHYS  	40'h040001xxxx
`define LDM_INPUT_BASE_PHYS  	24'h040001
//`define CRAM_INPUT_BASE_PHYS  40'h040002xxxx
`define CRAM_INPUT_BASE_PHYS  	24'h040002
//`define WRAM_INPUT_BASE_PHYS  40'h040003xxxx
`define WRAM_INPUT_BASE_PHYS  	24'h040003
//`define BRAM_INPUT_BASE_PHYS  40'h040004xxxx
`define BRAM_INPUT_BASE_PHYS  	24'h040004

//Read Data
//`define LDM_OUTPUT_BASE_PHYS  40'h040001xxxx
`define LDM_OUTPUT_BASE_PHYS  	24'h040001

// 0x04_0000_0000 0x04_7fff_ffff: normal transfer *(address) = data
// 0x04_8000_0000 0x04_ffff_ffff: dma_write() dma_read(), 128 cycles -> setup time


	module AXI_Interface #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of ID for for write address, write data, read address and read data
		parameter integer C_S_AXI_ID_WIDTH	= 1,
		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 40,
		// Width of optional user defined signal in write address channel
		parameter integer C_S_AXI_AWUSER_WIDTH	= 0,
		// Width of optional user defined signal in read address channel
		parameter integer C_S_AXI_ARUSER_WIDTH	= 0,
		// Width of optional user defined signal in write data channel
		parameter integer C_S_AXI_WUSER_WIDTH	= 0,
		// Width of optional user defined signal in read data channel
		parameter integer C_S_AXI_RUSER_WIDTH	= 0,
		// Width of optional user defined signal in write response channel
		parameter integer C_S_AXI_BUSER_WIDTH	= 0
	)
	(
 // Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write Address ID
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_AWID,
		// Write address
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		input wire [7 : 0] S_AXI_AWLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		input wire [2 : 0] S_AXI_AWSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		input wire [1 : 0] S_AXI_AWBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		input wire  S_AXI_AWLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		input wire [3 : 0] S_AXI_AWCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Quality of Service, QoS identifier sent for each
    // write transaction.
		input wire [3 : 0] S_AXI_AWQOS,
		// Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
		input wire [3 : 0] S_AXI_AWREGION,
		// Optional User-defined signal in the write address channel.
		input wire [C_S_AXI_AWUSER_WIDTH-1 : 0] S_AXI_AWUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid write address and
    // control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
		output wire  S_AXI_AWREADY,
		// Write Data
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write last. This signal indicates the last transfer
    // in a write burst.
		input wire  S_AXI_WLAST,
		// Optional User-defined signal in the write data channel.
		input wire [C_S_AXI_WUSER_WIDTH-1 : 0] S_AXI_WUSER,
		// Write valid. This signal indicates that valid write
    // data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    // can accept the write data.
		output wire  S_AXI_WREADY,
		// Response ID tag. This signal is the ID tag of the
    // write response.
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_BID,
		// Write response. This signal indicates the status
    // of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Optional User-defined signal in the write response channel.
		output wire [C_S_AXI_BUSER_WIDTH-1 : 0] S_AXI_BUSER,
		// Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    // can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address ID. This signal is the identification
    // tag for the read address group of signals.
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_ARID,
		// Read address. This signal indicates the initial
    // address of a read burst transaction.
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		input wire [7 : 0] S_AXI_ARLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		input wire [2 : 0] S_AXI_ARSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		input wire [1 : 0] S_AXI_ARBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		input wire  S_AXI_ARLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		input wire [3 : 0] S_AXI_ARCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Quality of Service, QoS identifier sent for each
    // read transaction.
		input wire [3 : 0] S_AXI_ARQOS,
		// Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
		input wire [3 : 0] S_AXI_ARREGION,
		// Optional User-defined signal in the read address channel.
		input wire [C_S_AXI_ARUSER_WIDTH-1 : 0] S_AXI_ARUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid read address and
    // control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
		output reg  S_AXI_ARREADY,
		// Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_RID,
		// Read Data
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of
    // the read transfer.
		output reg [1 : 0] S_AXI_RRESP,
		// Read last. This signal indicates the last transfer
    // in a read burst.
		output reg  S_AXI_RLAST,
		// Optional User-defined signal in the read address channel.
		output wire [C_S_AXI_RUSER_WIDTH-1 : 0] S_AXI_RUSER,
		// Read valid. This signal indicates that the channel
    // is signaling the required read data.
		output reg  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    // accept the read data and response information.
		input wire  S_AXI_RREADY
	);
	
	// Input signals
    reg [`PE_NUM_BITS+`LDM_NUM_BITS+`LDM_ADDR_BITS-1:0] AXI_LDM_addra_rg;
    reg signed [`WORD_BITS-1:0] AXI_LDM_dina_rg;
    reg AXI_LDM_ena_rg;
    reg AXI_LDM_wea_rg;
	
    reg [`CRAM_ADDR_BITS-1:0] AXI_CRAM_addra_rg;
    reg signed [`CTX_BITS-1:0] AXI_CRAM_dina_rg;
    reg AXI_CRAM_ena_rg;
    reg AXI_CRAM_wea_rg;

    reg [`WRAM_ADDR_BITS-1:0] AXI_WRAM_addra_rg;
    reg [`WORD_BITS-1:0] AXI_WRAM_dina_rg;
    reg AXI_WRAM_ena_rg;
    reg AXI_WRAM_wea_rg;

    reg [`BRAM_ADDR_BITS-1:0] AXI_BRAM_addra_rg;
    reg [`WORD_BITS-1:0] AXI_BRAM_dina_rg;
    reg AXI_BRAM_ena_rg;
    reg AXI_BRAM_wea_rg;

    reg start_rg;
	reg complete_rg;

	reg [C_S_AXI_ADDR_WIDTH-1 : 0]  S_AXI_ARADDR_rg;
    // Output signals
    wire signed [`WORD_BITS-1:0] AXI_LDM_douta_wr;
    wire complete_wr;
	
	//////////////////////////////////////////////
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;/**/
	reg  	axi_awready;/**/
	reg  	axi_wready;/**/
	reg [1 : 0] 	axi_bresp;
	reg [C_S_AXI_BUSER_WIDTH-1 : 0] 	axi_buser;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	    axi_araddr;/**/
	// wire [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata_w;
	reg  	axi_arready;/**/
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;/**/
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rlast;/**/
	reg [C_S_AXI_RUSER_WIDTH-1 : 0] 	axi_ruser;
	reg  	axi_rvalid;/**/
	// aw_wrap_en determines wrap boundary and enables wrapping
	wire aw_wrap_en;
	// ar_wrap_en determines wrap boundary and enables wrapping
	wire ar_wrap_en;
	// aw_wrap_size is the size of the write transfer, the
	// write address wraps to a lower address if upper address
	// limit is reached
	wire [31:0]  aw_wrap_size ; 
	// ar_wrap_size is the size of the read transfer, the
	// read address wraps to a lower address if upper address
	// limit is reached
	wire [31:0]  ar_wrap_size ; 
	// The axi_awv_awr_flag flag marks the presence of write address valid
	reg axi_awv_awr_flag;/**/
	//The axi_arv_arr_flag flag marks the presence of read address valid
	reg axi_arv_arr_flag; /**/
	// The axi_awlen_cntr internal write address counter to keep track of beats in a burst transaction
	reg [7:0] axi_awlen_cntr;
	//The axi_arlen_cntr internal read address counter to keep track of beats in a burst transaction
	reg [7:0] axi_arlen_cntr;
	reg [1:0] axi_arburst;
	reg [1:0] axi_awburst;
	reg [7:0] axi_arlen;
	reg [7:0] axi_awlen;
	//local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	//ADDR_LSB is used for addressing 32/64 bit registers/memories
	//ADDR_LSB = 2 for 32 bits (n downto 2) 
	//ADDR_LSB = 3 for 42 bits (n downto 3)

//	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32)+ 1;
    //localparam integer ADDR_LSB = C_S_AXI_DATA_WIDTH/32;
    localparam integer ADDR_LSB = 2;
	localparam integer OPT_MEM_ADDR_BITS = 12;
	localparam integer USER_NUM_MEM = 256;
	//----------------------------------------------
	//-- Signals for user logic memory space example
	//------------------------------------------------
	wire [OPT_MEM_ADDR_BITS:0] mem_address;
	wire [USER_NUM_MEM-1:0] mem_select;
	reg [C_S_AXI_DATA_WIDTH-1:0] mem_data_out[0 : USER_NUM_MEM-1];

	genvar i;
	genvar j;
	genvar mem_byte_index;

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BUSER	= axi_buser;
	assign S_AXI_BVALID	= axi_bvalid;
	// assign S_AXI_ARREADY	= axi_arready;
	// assign S_AXI_RDATA	= axi_rdata;
	// assign S_AXI_RDATA	= (S_AXI_ARADDR_rg == `FINISH_PK_BASE_PHYS) ? pk_complete_rg : PK_douta_wr;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA_TEMP;
	assign S_AXI_RDATA	= S_AXI_RDATA_TEMP;

	always @(*) begin
		if(S_AXI_ARADDR_rg[39:16] == `LDM_OUTPUT_BASE_PHYS)
			S_AXI_RDATA_TEMP = {16'h0,AXI_LDM_douta_wr};
		else
			S_AXI_RDATA_TEMP = complete_rg;        		      
	end

	
	//assign S_AXI_RRESP	= axi_rresp;
	//assign S_AXI_RLAST	= axi_rlast;
	assign S_AXI_RUSER	= axi_ruser;
	//assign S_AXI_RVALID	= axi_rvalid;
	assign S_AXI_BID = S_AXI_AWID;
	assign S_AXI_RID = S_AXI_ARID;
	assign  aw_wrap_size = (C_S_AXI_DATA_WIDTH/8 * (axi_awlen)); 
	assign  ar_wrap_size = (C_S_AXI_DATA_WIDTH/8 * (axi_arlen)); 
	assign  aw_wrap_en = ((axi_awaddr & aw_wrap_size) == aw_wrap_size)? 1'b1: 1'b0;
	assign  ar_wrap_en = ((axi_araddr & ar_wrap_size) == ar_wrap_size)? 1'b1: 1'b0;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      S_AXI_ARREADY <= 1'b0;
		  S_AXI_RVALID	<= 1'b0;
		  S_AXI_RLAST	<= 1'b0;
	      S_AXI_RRESP	<= 2'b0;
	    end 
		else begin
		  S_AXI_ARREADY <= axi_arready;
		  S_AXI_RVALID	<= axi_rvalid;
		  S_AXI_RLAST	<= axi_rlast;
	      S_AXI_RRESP	<= axi_rresp;
		end
	end
	  
	// Implement axi_awready generation

	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      axi_awv_awr_flag <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag)
	        begin
	          // slave is ready to accept an address and
	          // associated control signals
	          axi_awready <= 1'b1;
	          axi_awv_awr_flag  <= 1'b1; 
	          // used for generation of bresp() and bvalid
	        end
	      else if (S_AXI_WLAST && axi_wready)          
	      // preparing to accept next address after current write burst tx completion
	        begin
	          axi_awv_awr_flag  <= 1'b0;
	        end
	      else        
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       
	// Implement axi_awaddr latching

	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	      axi_awlen_cntr <= 0;
	      axi_awburst <= 0;
	      axi_awlen <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && ~axi_awv_awr_flag)
	        begin
	          // address latching 
	          axi_awaddr <= S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH - 1:0];  
	           axi_awburst <= S_AXI_AWBURST; 
	           axi_awlen <= S_AXI_AWLEN;     
	          // start address of transfer
	          axi_awlen_cntr <= 0;
	        end   
	      else if((axi_awlen_cntr <= axi_awlen) && axi_wready && S_AXI_WVALID)        
	        begin

	          axi_awlen_cntr <= axi_awlen_cntr + 1;

	          case (axi_awburst)
	            2'b00: // fixed burst
	            // The write address for all the beats in the transaction are fixed
	              begin
	                axi_awaddr <= axi_awaddr;          
	                //for awsize = 4 bytes (010)
	              end   
	            2'b01: //incremental burst
	            // The write address for all the beats in the transaction are increments by awsize
	              begin
	                axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                //awaddr aligned to 4 byte boundary
	                axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                //for awsize = 4 bytes (010)
	              end   
	            2'b10: //Wrapping burst
	            // The write address wraps when the address reaches wrap boundary 
	              if (aw_wrap_en)
	                begin
	                  axi_awaddr <= (axi_awaddr - aw_wrap_size); 
	                end
	              else 
	                begin
	                  axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                  axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}}; 
	                end                      
	            default: //reserved (incremental burst for example)
	              begin
	                axi_awaddr <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                //for awsize = 4 bytes (010)
	              end
	          endcase              
	        end
	    end 
	end       
	// Implement axi_wready generation

	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if ( ~axi_wready && S_AXI_WVALID && axi_awv_awr_flag)
	        begin
	          // slave can accept the write data
	          axi_wready <= 1'b1;
	        end
	      //else if (~axi_awv_awr_flag)
	      else if (S_AXI_WLAST && axi_wready)
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       
	// Implement write response logic generation

	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid <= 0;
	      axi_bresp <= 2'b0;
	      axi_buser <= 0;
	    end 
	  else
	    begin    
	      if (axi_awv_awr_flag && axi_wready && S_AXI_WVALID && ~axi_bvalid && S_AXI_WLAST )
	        begin
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; 
	          // 'OKAY' response 
	        end                   
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	          //check if bready is asserted while bvalid is high) 
	          //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	 end   
	// Implement axi_arready generation

	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_arv_arr_flag <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag)
	        begin
	          axi_arready <= 1'b1;
	          axi_arv_arr_flag <= 1'b1;
	        end
	      else if (axi_rvalid && S_AXI_RREADY && axi_arlen_cntr == axi_arlen)
	      // preparing to accept next address after current read completion
	        begin
	          axi_arv_arr_flag  <= 1'b0;
	        end
	      else        
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       
	// Implement axi_araddr latching

	//This process is used to latch the address when both 
	//S_AXI_ARVALID and S_AXI_RVALID are valid. 
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_araddr <= 0;
	      axi_arlen_cntr <= 0;
	      axi_arburst <= 0;
	      axi_arlen <= 0;
	      axi_rlast <= 1'b0;
	      axi_ruser <= 0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID && ~axi_arv_arr_flag)
	        begin
	          // address latching 
	          axi_araddr <= S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH - 1:0]; 
	          axi_arburst <= S_AXI_ARBURST; 
	          axi_arlen <= S_AXI_ARLEN;     
	          // start address of transfer
	          axi_arlen_cntr <= 0;
	          axi_rlast <= 1'b0;
	        end   
	      else if((axi_arlen_cntr <= axi_arlen) && axi_rvalid && S_AXI_RREADY)        
	        begin
	         
	          axi_arlen_cntr <= axi_arlen_cntr + 1;
	          axi_rlast <= 1'b0;
	        
	          case (axi_arburst)
	            2'b00: // fixed burst
	             // The read address for all the beats in the transaction are fixed
	              begin
	                axi_araddr       <= axi_araddr;        
	                //for arsize = 4 bytes (010)
	              end   
	            2'b01: //incremental burst
	            // The read address for all the beats in the transaction are increments by awsize
	              begin
	                axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
	                //araddr aligned to 4 byte boundary
	                axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                //for awsize = 4 bytes (010)
	              end   
	            2'b10: //Wrapping burst
	            // The read address wraps when the address reaches wrap boundary 
	              if (ar_wrap_en) 
	                begin
	                  axi_araddr <= (axi_araddr - ar_wrap_size); 
	                end
	              else 
	                begin
	                axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
	                //araddr aligned to 4 byte boundary
	                axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                end                      
	            default: //reserved (incremental burst for example)
	              begin
	                axi_araddr <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB]+1;
	                //for arsize = 4 bytes (010)
	              end
	          endcase              
	        end
	      else if((axi_arlen_cntr == axi_arlen) && ~axi_rlast && axi_arv_arr_flag )   
	        begin
	          axi_rlast <= 1'b1;
	        end          
	      else if (S_AXI_RREADY)   
	        begin
	          axi_rlast <= 1'b0;
	        end          
	    end 
	end       
	// Implement axi_arvalid generation

	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arv_arr_flag && ~axi_rvalid)
	        begin
	          axi_rvalid <= 1'b1;
			  axi_rresp  <= 2'b0; 
	          // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          axi_rvalid <= 1'b0;
	        end            
	    end
	end 
	
	// ------------------------------------------
	// -- Example code to access user logic memory region
	// ------------------------------------------

	generate
	  if (USER_NUM_MEM >= 1)
	    begin
	      assign mem_select  = 1;
	      assign mem_address = (axi_arv_arr_flag? axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]:(axi_awv_awr_flag? axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]:0));
	    end
	endgenerate
	     
	// implement Block RAM(s)
	generate 
	  for(i=0; i<= USER_NUM_MEM-1; i=i+1)
	    begin:BRAM_GEN
	      wire mem_rden;
	      wire mem_wren;
	
	      assign mem_wren = axi_wready && S_AXI_WVALID ;
	
	      assign mem_rden = axi_arv_arr_flag ; //& ~axi_rvalid
	     
	      for(mem_byte_index=0; mem_byte_index<= (C_S_AXI_DATA_WIDTH/8-1); mem_byte_index=mem_byte_index+1)
	      begin:BYTE_BRAM_GEN
	        wire [8-1:0] data_in ;
	        wire [8-1:0] data_out;
	        reg  [8-1:0] byte_ram [0 : 15];
	        integer  j;
	     
	        //assigning 8 bit data
	        assign data_in  = S_AXI_WDATA[(mem_byte_index*8+7) -: 8];
	        assign data_out = byte_ram[mem_address];
	     
	        always @( posedge S_AXI_ACLK )
	        begin
	          if (mem_wren && S_AXI_WSTRB[mem_byte_index])
	            begin
	              byte_ram[mem_address] <= data_in;
	            end   
	        end    
	      
	        always @( posedge S_AXI_ACLK )
	        begin
	          if (mem_rden)
	            begin
	              mem_data_out[i][(mem_byte_index*8+7) -: 8] <= data_out;
	            end   
	        end    
	               
	    end
	  end       
	endgenerate
	//Output register or memory read data

	always @( mem_data_out, axi_rvalid)
	begin
	  if (axi_rvalid) 
	    begin
	      // Read address mux
	      axi_rdata <= mem_data_out[0];
	    end   
	  else
	    begin
	      axi_rdata <= 32'h00000000;
	    end       
	end    

	// Add user logic here

  ///*** Confiiguration Memory ***///
	
	always @( posedge S_AXI_ACLK )
	begin
		if ( S_AXI_ARESETN == 1'b0 )
	    begin
			start_rg		<= 0;
	    end 
		else
	    begin    
			if (S_AXI_WREADY && axi_awv_awr_flag && (axi_awaddr == `START_BASE_PHYS))
	        begin
				start_rg <= S_AXI_WDATA[0:0];
	        end   
			else begin
	          start_rg <= 0;
	        end 
	    end
	end 


	
	always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
	   if (S_AXI_ARESETN == 1'b0) begin
	       S_AXI_ARADDR_rg <= 0;
	   end
	   else begin
	       if(axi_arv_arr_flag) begin
	           S_AXI_ARADDR_rg <= S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH - 1:0];
	       end
	       else begin
	           S_AXI_ARADDR_rg <= S_AXI_ARADDR_rg;
	       end
	   end
	end
	
	///*** Local Data Memory ***///	

    reg [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb_rg;
	
	always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin	      
			AXI_LDM_addra_rg 	<= 0;
			AXI_LDM_dina_rg 	<= 0;
			AXI_LDM_ena_rg 		<= 0;
			AXI_LDM_wea_rg 		<= 0;
	    end 
	  else
	    begin    
			s_axi_wstrb_rg <= S_AXI_WSTRB;
			if (S_AXI_WREADY && axi_awv_awr_flag && (s_axi_wstrb_rg == 4'hF)&&(axi_awaddr[39:16] == `LDM_INPUT_BASE_PHYS)) begin
					AXI_LDM_addra_rg	<= {axi_awaddr[`PE_NUM_BITS+2-1:2],axi_awaddr[`PE_NUM_BITS+`LDM_NUM_BITS+`LDM_ADDR_BITS+2-1:`PE_NUM_BITS+`LDM_ADDR_BITS+2],axi_awaddr[`PE_NUM_BITS+`LDM_ADDR_BITS+2-1:`PE_NUM_BITS+2]};
					AXI_LDM_dina_rg	 	<= S_AXI_WDATA[`WORD_BITS-1:0];
					AXI_LDM_ena_rg	 	<= S_AXI_WREADY;
					AXI_LDM_wea_rg 		<= S_AXI_WREADY;
			end
			else if (axi_arv_arr_flag && (axi_araddr[39:16] == `LDM_OUTPUT_BASE_PHYS)) begin	
					AXI_LDM_addra_rg	<= {axi_araddr[`PE_NUM_BITS+2-1:2],axi_araddr[`PE_NUM_BITS+`LDM_NUM_BITS+`LDM_ADDR_BITS+2-1:`PE_NUM_BITS+`LDM_ADDR_BITS+2],axi_araddr[`PE_NUM_BITS+`LDM_ADDR_BITS+2-1:`PE_NUM_BITS+2]};
					AXI_LDM_ena_rg	 	<= axi_arv_arr_flag;
					AXI_LDM_wea_rg 		<= ~axi_arv_arr_flag;
			end  
			else begin
				AXI_LDM_addra_rg 	<= 0;
				AXI_LDM_dina_rg 	<= 0;
				AXI_LDM_ena_rg 		<= 0;
				AXI_LDM_wea_rg 		<= 0;
	        end            
	    end
	end

	always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin	      			
			AXI_CRAM_addra_rg 	<= 0;
			AXI_CRAM_dina_rg 	<= 0;
			AXI_CRAM_ena_rg 	<= 0;
			AXI_CRAM_wea_rg 	<= 0;
			
		  	AXI_WRAM_addra_rg 	<= 0;
			AXI_WRAM_dina_rg 	<= 0;
			AXI_WRAM_ena_rg 	<= 0;
			AXI_WRAM_wea_rg 	<= 0;
			
		  	AXI_BRAM_addra_rg 	<= 0;
			AXI_BRAM_dina_rg 	<= 0;
			AXI_BRAM_ena_rg 	<= 0;
			AXI_BRAM_wea_rg 	<= 0;
	    end 
	  else
	    begin    
			if (S_AXI_WREADY && axi_awv_awr_flag && (s_axi_wstrb_rg == 4'hF)) begin
			case (axi_awaddr[39:16])
				`CRAM_INPUT_BASE_PHYS: begin
					AXI_CRAM_addra_rg 	<= axi_awaddr[`CRAM_ADDR_BITS+2-1:2];
					AXI_CRAM_dina_rg 	<= S_AXI_WDATA;
					AXI_CRAM_ena_rg 	<= S_AXI_WREADY;
					AXI_CRAM_wea_rg 	<= S_AXI_WREADY;
				end
				`WRAM_INPUT_BASE_PHYS: begin
					AXI_WRAM_addra_rg 	<= axi_awaddr[`WRAM_ADDR_BITS+2-1:2];
					AXI_WRAM_dina_rg 	<= S_AXI_WDATA[`WORD_BITS-1:0];
					AXI_WRAM_ena_rg 	<= S_AXI_WREADY;
					AXI_WRAM_wea_rg 	<= S_AXI_WREADY;
				end
				`BRAM_INPUT_BASE_PHYS: begin
					AXI_BRAM_addra_rg 	<= axi_awaddr[`BRAM_ADDR_BITS+2-1:2];
					AXI_BRAM_dina_rg 	<= S_AXI_WDATA[`WORD_BITS-1:0];
					AXI_BRAM_ena_rg 	<= S_AXI_WREADY;
					AXI_BRAM_wea_rg 	<= S_AXI_WREADY;
				end
				default: begin					
					AXI_CRAM_addra_rg 	<= 0;
					AXI_CRAM_dina_rg 	<= 0;
					AXI_CRAM_ena_rg 	<= 0;
					AXI_CRAM_wea_rg 	<= 0;
					
					AXI_WRAM_addra_rg 	<= 0;
					AXI_WRAM_dina_rg 	<= 0;
					AXI_WRAM_ena_rg 	<= 0;
					AXI_WRAM_wea_rg 	<= 0;
					
					AXI_BRAM_addra_rg 	<= 0;
					AXI_BRAM_dina_rg 	<= 0;
					AXI_BRAM_ena_rg 	<= 0;
					AXI_BRAM_wea_rg 	<= 0;
				end
				endcase

			end  
			else begin				
				AXI_CRAM_addra_rg 	<= 0;
				AXI_CRAM_dina_rg 	<= 0;
				AXI_CRAM_ena_rg 	<= 0;
				AXI_CRAM_wea_rg 	<= 0;
				
				AXI_WRAM_addra_rg 	<= 0;
				AXI_WRAM_dina_rg 	<= 0;
				AXI_WRAM_ena_rg 	<= 0;
				AXI_WRAM_wea_rg 	<= 0;
				
				AXI_BRAM_addra_rg 	<= 0;
				AXI_BRAM_dina_rg 	<= 0;
				AXI_BRAM_ena_rg 	<= 0;
				AXI_BRAM_wea_rg 	<= 0;
	        end            
	    end
	end
	always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) 
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin	      
    		complete_rg <= 0;
	    end 
	  else
	    begin  
			if(start_rg) begin
				complete_rg <= 0;
			end
			else if (complete_wr) begin
				complete_rg <= 1;
			end		  
			else begin
				complete_rg <= complete_rg;
			end
	    end
	end

CNN_1D_Core cnn_core
(
	.CLK(S_AXI_ACLK),
	.RST(S_AXI_ARESETN),			
	.AXI_LDM_addra_in(AXI_LDM_addra_rg),
	.AXI_LDM_dina_in(AXI_LDM_dina_rg),
	.AXI_LDM_ena_in(AXI_LDM_ena_rg),
	.AXI_LDM_wea_in(AXI_LDM_wea_rg),
	.AXI_CRAM_addra_in(AXI_CRAM_addra_rg),
	.AXI_CRAM_dina_in(AXI_CRAM_dina_rg),
	.AXI_CRAM_ena_in(AXI_CRAM_ena_rg),
	.AXI_CRAM_wea_in(AXI_CRAM_wea_rg),
	.AXI_WRAM_addra_in(AXI_WRAM_addra_rg),
	.AXI_WRAM_dina_in(AXI_WRAM_dina_rg),
	.AXI_WRAM_ena_in(AXI_WRAM_ena_rg),
	.AXI_WRAM_wea_in(AXI_WRAM_wea_rg),
	.AXI_BRAM_addra_in(AXI_BRAM_addra_rg),
	.AXI_BRAM_dina_in(AXI_BRAM_dina_rg),
	.AXI_BRAM_ena_in(AXI_BRAM_ena_rg),
	.AXI_BRAM_wea_in(AXI_BRAM_wea_rg),
	.start_in(start_rg),
	.AXI_LDM_douta_out(AXI_LDM_douta_wr),
	.complete_out(complete_wr)  
);


	
endmodule
