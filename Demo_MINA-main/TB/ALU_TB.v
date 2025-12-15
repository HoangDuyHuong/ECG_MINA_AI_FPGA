`timescale 1ns/1ns
`include "common.vh"

module ALU_tb;

    // Testbench signals
    reg                                 CLK;
    reg                                 RST;
    reg                                 En_in;
    reg signed [`ALU_CFG_BITS-1:0]      CFG_in;
    reg                                 S0_valid_in;
    reg signed [`WORD_BITS-1:0]         S0_in;
    reg                                 S1_valid_in;
    reg signed [`WORD_BITS-1:0]         S1_in;
    reg                                 S2_valid_in;
    reg signed [`WORD_BITS-1:0]         S2_in;
    wire signed [`WORD_BITS-1:0]        D0_out;
    wire                                Valid_out;
	reg									valid;
	reg	[5:0]							test_case;

    // Instantiate the ALU module
    ALU uut (
        .CLK(CLK),
        .RST(RST),
        .En_in(En_in),
        .CFG_in(CFG_in),
        .S0_valid_in(S0_valid_in),
        .S0_in(S0_in),
        .S1_valid_in(S1_valid_in),
        .S1_in(S1_in),
        .S2_valid_in(S2_valid_in),
        .S2_in(S2_in),
        .D0_out(D0_out),
        .Valid_out(Valid_out)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;  // 100 MHz clock
    end

    function [15:0] to_fixed_point;
        input real value;
        begin
            to_fixed_point = $rtoi(value * (1 << 6)); // Multiply by 2^6 to handle 5 fractional bits
        end
    endfunction

  // Test sequence using an always block
    always @(posedge CLK) begin
        if (~RST) begin
            // Set default values on reset
            CFG_in      <= `EXE_NOP;
            S0_valid_in <= 0;
            S0_in       <= 0;
            S1_valid_in <= 0;
            S1_in       <= 0;
            S2_valid_in <= 0;
            S2_in       <= 0;
        end
        else begin
            // Test EXE_ADD operation
			if(test_case == 1) begin
				CFG_in      <= `EXE_ADD;
				S0_valid_in <= 1;
				S0_in       <= to_fixed_point(-20.5);  // Example input value
				S1_valid_in <= 1;
				S1_in       <= to_fixed_point(-20.5);  // Example input value
				S2_valid_in <= 1;
				S2_in       <= to_fixed_point(2.5);  // Example input value
			end
			else if(test_case == 2) begin
				CFG_in      <= `EXE_MAC;
				S0_valid_in <= 1;
				S0_in       <= to_fixed_point(-20.5);  // Example input value
				S1_valid_in <= 1;
				S1_in       <= to_fixed_point(-2.5);  // Example input value
				S2_valid_in <= 1;
				S2_in       <= to_fixed_point(-1.5);  // Example input value
			end
			else if(test_case == 3) begin
				CFG_in      <= `EXE_MP;
				S0_valid_in <= 1;
				S0_in       <= to_fixed_point(-25.5);  // Example input value
				S1_valid_in <= 1;
				S1_in       <= to_fixed_point(-18.5);  // Example input value
				S2_valid_in <= 1;
				S2_in       <= to_fixed_point(-2.5);  // Example input value
			end
			else begin
				CFG_in      <= 0;
				S0_valid_in <= 0;
				S0_in       <= 0;  // Example input value
				S1_valid_in <= 0;
				S1_in       <= 0;  // Example input value
				S2_valid_in <= 0;
				S2_in       <= 0;  // Example input value
			end
			
        end
    end

	
    // Test procedure
    initial begin
        // Initialize inputs
        RST 		<= 0;
        En_in 		<= 0;
        CFG_in 		<= 0;
        S0_valid_in <= 0;
        S0_in 		<= 0;
        S1_valid_in <= 0;
        S1_in 		<= 0;
        S2_valid_in <= 0;
        S2_in 		<= 0;
		valid		<= 0;
		test_case	<= 0;

        // Reset the ALU
        #60;
        RST 		<= 1;
		valid		<= 1;
        #15;
		test_case	<= 1;
		#10
		test_case	<= 2;	
		#10
		test_case	<= 3;	
		#10
		test_case	<= 0;
		#10
		test_case	<= 1;
		#10
		test_case	<= 2;	
		#10
		test_case	<= 3;	
		#10
		test_case	<= 0;
        // // Test EXE_ADD (Adder Operation)
        // CFG_in 		<= `EXE_ADD;
        // S0_valid_in <= valid;
        // S0_in 		<= to_fixed_point(-20.5);  // Example input value
        // S1_valid_in <= valid;
        // S1_in 		<= to_fixed_point(-20.5);  // Example input value
        // S2_valid_in <= valid;
        // S2_in 		<= to_fixed_point(-20.5);  // Example input value
        // #10;

        // // Test EXE_MAC (Multiply-Add Operation)
        // CFG_in 		<= `EXE_MAC;
        // S0_in 		<= 16'h0003;  // Example input value
        // S1_in 		<= 16'h0004;  // Example input value
        // S2_in 		<= 16'h0001;  // Example input value
        // #10;

        // // Test EXE_MP (Max Pooling Operation)
        // CFG_in 		<= `EXE_MP;
        // S0_in 		<= 16'h0005;  // Example input value
        // S1_in 		<= 16'h0004;  // Example input value
        // S2_in 		<= 16'h0007;  // Example input value
        // #10;

        // // Test EXE_NOP (No Operation)
        // CFG_in 		<= `EXE_NOP;
        // S0_valid_in <= 0;
        // S1_valid_in <= 0;
        // S2_valid_in <= 0;
        // #100;
		// // Test EXE_ADD (Adder Operation)
        // CFG_in 		<= `EXE_NOP;
        // S0_valid_in <= valid;
        // S0_in 		<= to_fixed_point(-20.5);  // Example input value
        // S1_valid_in <= valid;
        // S1_in 		<= to_fixed_point(-20.5);  // Example input value
        // S2_valid_in <= valid;
        // S2_in 		<= to_fixed_point(-20.5);  // Example input value
        // #10;
        // // Test EXE_ADD (Adder Operation)
        // CFG_in 		<= `EXE_ADD;
        // S0_valid_in <= valid;
        // S0_in 		<= to_fixed_point(-20.5);  // Example input value
        // S1_valid_in <= valid;
        // S1_in 		<= to_fixed_point(-20.5);  // Example input value
        // S2_valid_in <= valid;
        // S2_in 		<= to_fixed_point(-20.5);  // Example input value
        // #10;

        // // Test EXE_MAC (Multiply-Add Operation)
        // CFG_in 		<= `EXE_MAC;
        // S0_in 		<= 16'h0003;  // Example input value
        // S1_in 		<= 16'h0004;  // Example input value
        // S2_in 		<= 16'h0001;  // Example input value
        // #10;

        // // Test EXE_MP (Max Pooling Operation)
        // CFG_in 		<= `EXE_MP;
        // S0_in 		<= 16'h0005;  // Example input value
        // S1_in 		<= 16'h0004;  // Example input value
        // S2_in 		<= 16'h0007;  // Example input value
        // #10;

        // // Test EXE_NOP (No Operation)
        // CFG_in 		<= `EXE_NOP;
        // S0_valid_in <= 0;
        // S1_valid_in <= 0;
        // S2_valid_in <= 0;
        #200;
        // End of test
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | CFG: %0d | S0: %0d | S1: %0d | S2: %0d | D0_out: %0d | Valid_out: %0b",
                 $time, CFG_in, S0_in, S1_in, S2_in, D0_out, Valid_out);
    end

endmodule
