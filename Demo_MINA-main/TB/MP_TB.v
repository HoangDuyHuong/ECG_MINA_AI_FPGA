module MaxValue_tb;
    // Testbench signals
    reg CLK;
    reg RST;
    reg signed [15:0] S0_in;
    reg signed [15:0] S1_in;
    reg signed [15:0] S2_in;
    wire signed [15:0] max_out;

    // Instantiate the MaxValue module
    MaxValue uut (
        .CLK(CLK),
        .RST(RST),
        .S0_in(S0_in),
        .S1_in(S1_in),
        .S2_in(S2_in),
        .max_out(max_out)
    );

    // Clock generation
    always begin
        #5 CLK = ~CLK; // 10 time units period
    end
    function [15:0] to_fixed_point;
        input real value;
        begin
            to_fixed_point = $rtoi(value * (1 << 6)); // Multiply by 2^6 to handle 5 fractional bits
        end
    endfunction
    // Testbench procedure
    initial begin
        // Initialize signals
        CLK <= 0;
        RST <= 1;
        S0_in <= 16'sd0;
        S1_in <= 16'sd0;
        S2_in <= 16'sd0;

        // Reset pulse
        #10;
        RST <= 0;

        // Test case 1: All positive values
        S0_in <= 16'sd64;  // 1.0 (fixed point: 1 sign bit, 9 integer bits, 6 fractional bits)
        S1_in <= 16'sd192; // 3.0
        S2_in <= 16'sd128; // 2.0
        #10;
        $display("Test 1 - Max Out: %d (Expected: 192)", max_out);

        // Test case 2: Mixed values with one negative
        S0_in <= -16'sd64;  // -1.0
        S1_in <= 16'sd128;  // 2.0
        S2_in <= 16'sd64;   // 1.0
        #10;
        $display("Test 2 - Max Out: %d (Expected: 128)", max_out);

        // Test case 3: All negative but greater than -10
        S0_in <= -16'sd64;  // -1.0
        S1_in <= -16'sd128; // -2.0
        S2_in <= -16'sd96;  // -1.5
        #10;
        $display("Test 3 - Max Out: %d (Expected: -64)", max_out);

        // Test case 4: All negative values smaller than -10
        S0_in <= -16'sd800;  // -12.5
        S1_in <= -16'sd1024; // -16.0
        S2_in <= -16'sd960;  // -15.0
        #10;
        $display("Test 4 - Max Out: %d (Expected: -640)", max_out);

        // Test case 5: Mixed values with all being less than -10
        S0_in <= -16'sd700;  // -10.9375
        S1_in <= -16'sd1024; // -16.0
        S2_in <= -16'sd680;  // -10.625
        #10;
		S0_in <= to_fixed_point(-20.5);   // multiplicand (5.75 in fixed-point)
        S1_in <= to_fixed_point(-20.25);   // multiplier (3.25 in fixed-point)
        S2_in <= to_fixed_point(-19.75);    // accumulation value (2.5 in fixed-point)
		#10;
		S0_in <= to_fixed_point(-5.25);   // multiplicand (5.75 in fixed-point)
        S1_in <= to_fixed_point(-2.75);   // multiplier (3.25 in fixed-point)
        S2_in <= to_fixed_point(0);    // accumulation value (2.5 in fixed-point)
        $display("Test 5 - Max Out: %d (Expected: -640)", max_out);

        #100;
   
        $display("Test 6 - Max Out after reset: %d (Expected: 0)", max_out);

        $finish;
    end

endmodule


module MaxValue (
    input wire CLK,                    
    input wire RST,                    
    input wire signed [15:0] S0_in,    // Fixed-point input: 1 sign bit, 9 integer bits, 6 fractional bits
    input wire signed [15:0] S1_in,    // Fixed-point input: 1 sign bit, 9 integer bits, 6 fractional bits
    input wire signed [15:0] S2_in,    // Fixed-point input: 1 sign bit, 9 integer bits, 6 fractional bits
    output reg signed [15:0] max_out   // Fixed-point output: 1 sign bit, 9 integer bits, 6 fractional bits
);

    // Define the fixed-point representation of -10 (16-bit fixed-point: 1 sign, 9 integer, 6 fractional)
    localparam signed [15:0] NEG_TEN = -10 << 6; // Shift by 6 to represent -10 in 6 fractional bits

    // Internal wire to hold the maximum value of S0, S1, and S2
    wire signed [15:0] max_S0_S1;
    wire signed [15:0] max_S_all;

    // Find the maximum value between S0 and S1
    assign max_S0_S1 = (S0_in > S1_in) ? S0_in : S1_in;

    // Find the maximum value between max_S0_S1 and S2
    assign max_S_all = (max_S0_S1 > S2_in) ? max_S0_S1 : S2_in;

    // Sequential logic to determine max_out based on clock and reset
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            max_out <= 16'sd0; // Reset max_out to 0
        end
        else begin
            if (max_S_all < NEG_TEN)
                max_out <= NEG_TEN;
            else
                max_out <= max_S_all;
        end
    end

endmodule
