`include "common.vh"
module Dual_Port_RAM
#(
  parameter AWIDTH = 13, // address width
  parameter DWIDTH = 32 // data width
)
(
  input clka, // clock
  ///*** Port A***///
  input ena, // port A read enable
  input wea, // port A write enable
  input [AWIDTH-1:0] addra, // port A address
  input [DWIDTH-1:0] dina, // port A data
  output reg [DWIDTH-1:0] douta, // port A data output
  
  ///*** Port B***///
  input clkb, // clock
  input enb, // port A read enable
  input web, // port A write enable
  input [AWIDTH-1:0] addrb, // port A address
  input [DWIDTH-1:0] dinb, // port A data
  output reg [DWIDTH-1:0] doutb // port A data output
);

	reg [DWIDTH-1:0] mem [2**AWIDTH-1:0];

	always @(posedge clka) begin
		// /*** Port A***///
		if (ena&enb) begin
			if(wea) begin
				mem[addra] <= dina;
			end
			else if(web) begin
				mem[addrb] <= dinb;
			end
			
			douta <= mem[addra];
			doutb <= mem[addrb];
		end
		else if(ena) begin
			if(wea) begin
				mem[addra] <= dina;
			end
			douta <= mem[addra];
		end
		else if (enb) begin
			if(web) begin
				mem[addrb] <= dinb;
			end
			doutb <= mem[addrb];
		end
		
	end
	
endmodule

module Dual_Port_RAM_2
#(
  parameter AWIDTH = 10, // address width
  parameter DWIDTH = 32 // data width
)
(
  input clka, // clock
  ///*** Port A***///
  input ena, // port A read enable
  input wea, // port A write enable
  input [AWIDTH-1:0] addra, // port A address
  input [DWIDTH-1:0] dina, // port A data
  output reg [DWIDTH-1:0] douta, // port A data output
  
  ///*** Port B***///
  input clkb, // clock
  input enb, // port A read enable
  input web, // port A write enable
  input [AWIDTH-1:0] addrb, // port A address
  input [DWIDTH-1:0] dinb, // port A data
  output reg [DWIDTH-1:0] doutb // port A data output
);

	reg [DWIDTH-1:0] mem [2**AWIDTH-1:0];

	always @(posedge clka) begin
		// /*** Port A***///
		if (ena&enb) begin
			if(wea) begin
				mem[addra] <= dina;
			end
			else if(web) begin
				mem[addrb] <= dinb;
			end
			
			douta <= mem[addra];
			doutb <= mem[addrb];
		end
		else if(ena) begin
			if(wea) begin
				mem[addra] <= dina;
			end
			douta <= mem[addra];
		end
		else if (enb) begin
			if(web) begin
				mem[addrb] <= dinb;
			end
			doutb <= mem[addrb];
		end
		else begin
			douta <= 0;
			doutb <= 0;
		end
		
	end
	
endmodule
