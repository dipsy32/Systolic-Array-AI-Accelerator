`timescale 1ns / 1ps

module tb_pe;

    // Inputs
    reg clk;
    reg rst;
    reg load_weight;
    reg signed [7:0] in_n;
    reg signed [23:0] in_w;

    // Outputs
    wire signed [7:0] out_s;
    wire signed [23:0] out_e;

    // Instantiate the Unit Under Test (UUT)
    pe uut (
        .clk(clk), 
        .rst(rst), 
        .load_weight(load_weight), 
        .in_n(in_n), 
        .in_w(in_w), 
        .out_s(out_s), 
        .out_e(out_e)
    );

    // Clock generation (10ns period = 100MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        load_weight = 0;
        in_n = 0;
        in_w = 0;

        // Reset the system
        #20;
        rst = 0;
        
        // --- TEST CASE 1: LOAD WEIGHT ---
        // We want to load a weight of 5 into the PE
        $display("Time: %0t | Test Case 1: Loading Weight 5", $time);
        load_weight = 1;
        in_n = 8'd5;   // This 5 represents the weight coming from North
        in_w = 24'd0;
        
        #10; // Wait for one clock edge
        
        // --- TEST CASE 2: COMPUTE (Positive) ---
        // Weight is now 5. Let's input 2 from North.
        // Expected Psum = 0 (from West) + (2 * 5) = 10
        $display("Time: %0t | Test Case 2: Compute 2 * 5", $time);
        load_weight = 0;
        in_n = 8'd2;   // Activation
        in_w = 24'd0;  // Partial sum from West
        
        #10;
        
        // --- TEST CASE 3: ACCUMULATE (Positive) ---
        // Weight is still 5. Let's input 3 from North.
        // Let's pretend previous PE sent us a partial sum of 10.
        // Expected Psum = 10 (from West) + (3 * 5) = 25
        $display("Time: %0t | Test Case 3: Accumulate 10 + (3 * 5)", $time);
        in_n = 8'd3;
        in_w = 24'd10; 

        #10;

        // --- TEST CASE 4: SIGNED ARITHMETIC (Negative) ---
        // Let's reload a negative weight: -4
        $display("Time: %0t | Test Case 4: Reload Weight -4", $time);
        load_weight = 1;
        in_n = -8'd4; // 2's complement -4
        
        #10;
        
        // Compute with negative weight
        // Weight = -4. Input = 3. Psum in = 100.
        // Expected = 100 + (3 * -4) = 100 - 12 = 88
        $display("Time: %0t | Test Case 5: Negative Calc 100 + (3 * -4)", $time);
        load_weight = 0;
        in_n = 8'd3;
        in_w = 24'd100;
        
        #10;
        
        $finish;
    end
    
    // Monitor changes
    initial begin
        $monitor("Time=%0t | Load=%b | In_N=%d | In_W=%d | Out_S=%d | Out_E=%d", 
                 $time, load_weight, in_n, in_w, out_s, out_e);
    end

endmodule