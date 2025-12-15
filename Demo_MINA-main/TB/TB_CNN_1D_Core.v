`timescale 1ns / 1ns
`include "common.vh"

`define		LDM_DEPTH   340
`define		CRAM_DEPTH  42
`define		WRAM_DEPTH  56+16+16+12+20+28+16+16+12+20+28+640+64+64+48+80+112+64+64+48+80+112+1536+256+256+192+320+448+256+256+192+320+448
`define		BRAM_DEPTH  8+2+2+2+2+2+2+2+2+2+2+16+4+4+4+4+4+4+4+4+4+4+32+8+8+8+8+8+8+8+8+8+8


// `define		LDM_DEPTH   340
// `define		CRAM_DEPTH  1
// `define		WRAM_DEPTH  56+16+16+12+20+28+16+16+12+20+28+640+64+64+48+80+112
// `define		BRAM_DEPTH  8+2+2+2+2+2+2+2+2+2+2+16+4+4+4+4+4


// `define		LDM_DEPTH   1280
// `define		CRAM_DEPTH  1
// `define		WRAM_DEPTH  640
// `define		BRAM_DEPTH  16

// `define		LDM_DEPTH   340
// `define		CRAM_DEPTH  1
// `define		WRAM_DEPTH  56
// `define		BRAM_DEPTH  8

// `define		LDM_DEPTH   1280
// `define		CRAM_DEPTH  1
// `define		WRAM_DEPTH  0
// `define		BRAM_DEPTH  0

// `define		LDM_DEPTH   1280
// `define		CRAM_DEPTH  1
// `define		WRAM_DEPTH  16
// `define		BRAM_DEPTH  2

module TB_CNN_1D_Core();
    reg CLK;
    reg RST;
    
    // Input signals
    reg [`PE_NUM_BITS+`LDM_NUM_BITS+`LDM_ADDR_BITS-1:0] AXI_LDM_addra_in;
    reg signed [`WORD_BITS-1:0] AXI_LDM_dina_in;
    reg AXI_LDM_ena_in;
    reg AXI_LDM_wea_in;

    reg [`CRAM_ADDR_BITS-1:0] AXI_CRAM_addra_in;
    reg signed [`CTX_BITS-1:0] AXI_CRAM_dina_in;
    reg AXI_CRAM_ena_in;
    reg AXI_CRAM_wea_in;

    reg [`WRAM_ADDR_BITS-1:0] AXI_WRAM_addra_in;
    reg [`WORD_BITS-1:0] AXI_WRAM_dina_in;
    reg AXI_WRAM_ena_in;
    reg AXI_WRAM_wea_in;

    reg [`BRAM_ADDR_BITS-1:0] AXI_BRAM_addra_in;
    reg [`WORD_BITS-1:0] AXI_BRAM_dina_in;
    reg AXI_BRAM_ena_in;
    reg AXI_BRAM_wea_in;

    reg start_in;

    // Output signals
    wire signed [`WORD_BITS-1:0] AXI_LDM_douta_out;
    wire complete_out;

    // Memory initialization
    reg [32:0] LDM  [0:`LDM_DEPTH-1];
    reg [63:0] CRAM [0:`CRAM_DEPTH-1];
    reg [32:0] WRAM [0:`WRAM_DEPTH-1];
    reg [32:0] BRAM [0:`BRAM_DEPTH-1];
	integer a;    // Intermediate variable for address calculation
	reg [15:0] address; // 16-bit address

    integer i;

    // Instantiate the CNN_1D_Core module
    CNN_1D_Core uut (
        .CLK(CLK),
        .RST(RST),
        .AXI_LDM_addra_in(AXI_LDM_addra_in),
        .AXI_LDM_dina_in(AXI_LDM_dina_in),
        .AXI_LDM_ena_in(AXI_LDM_ena_in),
        .AXI_LDM_wea_in(AXI_LDM_wea_in),
        .AXI_CRAM_addra_in(AXI_CRAM_addra_in),
        .AXI_CRAM_dina_in(AXI_CRAM_dina_in),
        .AXI_CRAM_ena_in(AXI_CRAM_ena_in),
        .AXI_CRAM_wea_in(AXI_CRAM_wea_in),
        .AXI_WRAM_addra_in(AXI_WRAM_addra_in),
        .AXI_WRAM_dina_in(AXI_WRAM_dina_in),
        .AXI_WRAM_ena_in(AXI_WRAM_ena_in),
        .AXI_WRAM_wea_in(AXI_WRAM_wea_in),
        .AXI_BRAM_addra_in(AXI_BRAM_addra_in),
        .AXI_BRAM_dina_in(AXI_BRAM_dina_in),
        .AXI_BRAM_ena_in(AXI_BRAM_ena_in),
        .AXI_BRAM_wea_in(AXI_BRAM_wea_in),
        .start_in(start_in),
        .AXI_LDM_douta_out(AXI_LDM_douta_out),
        .complete_out(complete_out)
    );

    // Clock generation
    initial begin
        CLK <= 1'b0;
        forever #5 CLK = ~CLK;  // 10ns clock period
    end
	integer outfile, outfile2, outfile3; // Declare an integer for the file descriptor

    // Simulation logic
    initial begin
        // Initialize inputs
        RST <= 1'b0;
        AXI_LDM_addra_in <= 0;
        AXI_LDM_dina_in <= 0;
        AXI_LDM_ena_in <= 0;
        AXI_LDM_wea_in <= 0;
        AXI_CRAM_addra_in <= 0;
        AXI_CRAM_dina_in <= 0;
        AXI_CRAM_ena_in <= 0;
        AXI_CRAM_wea_in <= 0;
        AXI_WRAM_addra_in <= 0;
        AXI_WRAM_dina_in <= 0;
        AXI_WRAM_ena_in <= 0;
        AXI_WRAM_wea_in <= 0;
        AXI_BRAM_addra_in <= 0;
        AXI_BRAM_dina_in <= 0;
        AXI_BRAM_ena_in <= 0;
        AXI_BRAM_wea_in <= 0;
        start_in <= 0;
		#40;
		// Write to Context RAM (CRAM)
 
        AXI_CRAM_addra_in <= 0;
        AXI_CRAM_dina_in <= 0;
        AXI_CRAM_ena_in <= 1'b0;
        AXI_CRAM_wea_in <= 1'b0;
        #10;
		
        // Reset sequence
        #60 RST <= 1'b1;
		#45
        // Load memory files
        $readmemh("/home/hoailuan/Research/2024/ECG_Diem/mini_inception_1280_Test_Index_Old/LDM_File.txt", LDM);
        $readmemh("/home/hoailuan/Research/2024/ECG_Diem/mini_inception_1280_Test_Index_Old/CRAM_File.txt", CRAM);
        $readmemh("/home/hoailuan/Research/2024/ECG_Diem/mini_inception_1280_Test_Index_Old/WRAM_File.txt", WRAM);
        $readmemh("/home/hoailuan/Research/2024/ECG_Diem/mini_inception_1280_Test_Index_Old/BRAM_File.txt", BRAM);

        // Write to Local Data Memory (LDM)
        for (i = 0; i < `LDM_DEPTH; i = i + 1) begin
            AXI_LDM_addra_in <= {LDM[i][`PE_NUM_BITS+`WORD_BITS-1:`WORD_BITS],2'd0,LDM[i][`PE_NUM_BITS+`LDM_ADDR_BITS+`WORD_BITS-1:`WORD_BITS+`PE_NUM_BITS]};
            AXI_LDM_dina_in <= LDM[i][`WORD_BITS-1:0];
            AXI_LDM_ena_in <= 1'b1;
            AXI_LDM_wea_in <= 1'b1;
            #10;
        end
        AXI_LDM_ena_in <= 1'b0;
        AXI_LDM_wea_in <= 1'b0;

        
		#40;
        // Write to Write RAM (WRAM)
        for (i = 0; i < `WRAM_DEPTH; i = i + 1) begin
            AXI_WRAM_addra_in <= WRAM[i][`WRAM_ADDR_BITS+`WORD_BITS-1:`WORD_BITS];
            AXI_WRAM_dina_in <= WRAM[i][`WORD_BITS-1:0];
            AXI_WRAM_ena_in <= 1'b1;
            AXI_WRAM_wea_in <= 1'b1;
            #10;
        end
        AXI_WRAM_ena_in <= 1'b0;
        AXI_WRAM_wea_in <= 1'b0;
		
		#40;
        // Write to Broadcast RAM (BRAM)
        for (i = 0; i < `BRAM_DEPTH; i = i + 1) begin
            AXI_BRAM_addra_in <= BRAM[i][`BRAM_ADDR_BITS+`WORD_BITS-1:`WORD_BITS];
            AXI_BRAM_dina_in <= BRAM[i][`WORD_BITS-1:0];
            AXI_BRAM_ena_in <= 1'b1;
            AXI_BRAM_wea_in <= 1'b1;
            #10;
        end
        AXI_BRAM_ena_in <= 1'b0;
        AXI_BRAM_wea_in <= 1'b0;
		
		#40;
		// Write to Context RAM (CRAM)
        for (i = 0; i < `CRAM_DEPTH; i = i + 1) begin
            AXI_CRAM_addra_in <= CRAM[i][`CRAM_ADDR_BITS+32-1:32];
            AXI_CRAM_dina_in <= CRAM[i][`CTX_BITS-1:0];
            AXI_CRAM_ena_in <= 1'b1;
            AXI_CRAM_wea_in <= 1'b1;
            #10;
        end
        AXI_CRAM_ena_in <= 1'b0;
        AXI_CRAM_wea_in <= 1'b0;
		
        // Start the core
        #20 start_in <= 1'b1;
        #10 start_in <= 1'b0;

        // Open the file for writing. "output.txt" is the filename, and "w" specifies write mode.
		outfile = $fopen("/home/hoailuan/Research/2024/ECG_Diem/mini_inception_1280_Test_Index/output.txt", "w");

		// Wait for completion
		wait (complete_out == 1'b1);
		#100
		// Write to Local Data Memory (LDM)
		for (i = 0; i < 1281; i = i + 1) begin
			// Calculate the address
			a = i / 20;
			address = (i + a * 12) & 16'hFFFF; // Mask to 16 bits
			AXI_LDM_addra_in <= {address[`PE_NUM_BITS-1:0],2'd0,address[`PE_NUM_BITS+`LDM_ADDR_BITS-1:`PE_NUM_BITS]};
			AXI_LDM_ena_in <= 1'b1;
			AXI_LDM_wea_in <= 1'b0;
			#10;
			
			// Write to file instead of just displaying
			if(i>=1)
			// $fwrite(outfile, "%04h_%04h\n", i-1, AXI_LDM_douta_out);
			$fwrite(outfile, "%04h\n", AXI_LDM_douta_out);
		end
		
		// Close the file after the loop completes
		AXI_LDM_ena_in <= 1'b0;
		AXI_LDM_wea_in <= 1'b0;
		$fclose(outfile);
		/////////////////next session 
		#100
		 // Write to Local Data Memory (LDM)
        for (i = 0; i < `LDM_DEPTH; i = i + 1) begin
            AXI_LDM_addra_in <= {LDM[i][`PE_NUM_BITS+`WORD_BITS-1:`WORD_BITS],2'd0,LDM[i][`PE_NUM_BITS+`LDM_ADDR_BITS+`WORD_BITS-1:`WORD_BITS+`PE_NUM_BITS]};
            AXI_LDM_dina_in <= LDM[i][`WORD_BITS-1:0];
            AXI_LDM_ena_in <= 1'b1;
            AXI_LDM_wea_in <= 1'b1;
            #10;
        end
        AXI_LDM_ena_in <= 1'b0;
        AXI_LDM_wea_in <= 1'b0;
		
		 // Start the core
        #20 start_in <= 1'b1;
        #10 start_in <= 1'b0;

        // Open the file for writing. "output.txt" is the filename, and "w" specifies write mode.
		outfile2 = $fopen("/home/hoailuan/Research/2024/ECG_Diem/mini_inception_1280_Test_Index/output2.txt", "w");

		// Wait for completion
		wait (complete_out == 1'b1);
		#1000
		// Write to Local Data Memory (LDM)
		for (i = 0; i < 1281; i = i + 1) begin
			// Calculate the address
			a = i / 20;
			address = (i + a * 12) & 16'hFFFF; // Mask to 16 bits
			AXI_LDM_addra_in <= {address[`PE_NUM_BITS-1:0],2'd0,address[`PE_NUM_BITS+`LDM_ADDR_BITS-1:`PE_NUM_BITS]};
			AXI_LDM_ena_in <= 1'b1;
			AXI_LDM_wea_in <= 1'b0;
			#10;
			
			// Write to file instead of just displaying
			if(i>=1)
			// $fwrite(outfile, "%04h_%04h\n", i-1, AXI_LDM_douta_out);
			$fwrite(outfile2, "%04h\n", AXI_LDM_douta_out);
		end
		
		// Close the file after the loop completes
		AXI_LDM_ena_in <= 1'b0;
		AXI_LDM_wea_in <= 1'b0;
		$fclose(outfile2);


		/////////////////next session 
		#100
		 // Write to Local Data Memory (LDM)
        for (i = 0; i < `LDM_DEPTH; i = i + 1) begin
            AXI_LDM_addra_in <= {LDM[i][`PE_NUM_BITS+`WORD_BITS-1:`WORD_BITS],2'd0,LDM[i][`PE_NUM_BITS+`LDM_ADDR_BITS+`WORD_BITS-1:`WORD_BITS+`PE_NUM_BITS]};
            AXI_LDM_dina_in <= LDM[i][`WORD_BITS-1:0];
            AXI_LDM_ena_in <= 1'b1;
            AXI_LDM_wea_in <= 1'b1;
            #10;
        end
        AXI_LDM_ena_in <= 1'b0;
        AXI_LDM_wea_in <= 1'b0;
		
		 // Start the core
        #20 start_in <= 1'b1;
        #10 start_in <= 1'b0;

        // Open the file for writing. "output.txt" is the filename, and "w" specifies write mode.
		outfile3 = $fopen("/home/hoailuan/Research/2024/ECG_Diem/mini_inception_1280_Test_Index/output3.txt", "w");

		// Wait for completion
		wait (complete_out == 1'b1);
		#1000
		// Write to Local Data Memory (LDM)
		for (i = 0; i < 1281; i = i + 1) begin
			// Calculate the address
			a = i / 20;
			address = (i + a * 12) & 16'hFFFF; // Mask to 16 bits
			AXI_LDM_addra_in <= {address[`PE_NUM_BITS-1:0],2'd0,address[`PE_NUM_BITS+`LDM_ADDR_BITS-1:`PE_NUM_BITS]};
			AXI_LDM_ena_in <= 1'b1;
			AXI_LDM_wea_in <= 1'b0;
			#10;
			
			// Write to file instead of just displaying
			if(i>=1)
			// $fwrite(outfile, "%04h_%04h\n", i-1, AXI_LDM_douta_out);
			$fwrite(outfile3, "%04h\n", AXI_LDM_douta_out);
		end
		
		// Close the file after the loop completes
		AXI_LDM_ena_in <= 1'b0;
		AXI_LDM_wea_in <= 1'b0;
		$fclose(outfile3);
		
		
		// Display completion message and stop the simulation
		$display("Simulation complete.");
        $stop;
    end
endmodule
