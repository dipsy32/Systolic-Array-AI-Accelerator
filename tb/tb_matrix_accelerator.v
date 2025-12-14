`timescale 1ns / 1ps

module tb_matrix_accelerator;

    reg clk;
    reg rst;
    reg load_weight;
    reg [31:0] activation_in;
    wire [95:0] result_out;

    matrix_accelerator uut (
        .clk(clk), 
        .rst(rst), 
        .load_weight(load_weight), 
        .activation_in(activation_in), 
        .result_out(result_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        load_weight = 0;
        activation_in = 0;

        #20;
        rst = 0;

        // ============================================
        // PHASE 1: LOAD WEIGHTS (Identity Matrix)
        // ============================================
        $display("Loading Weights...");
        load_weight = 1;
        
        // We load rows from Bottom to Top (like pushing a stack)
        // Row 3: 0 0 0 1
        activation_in = 32'h01000000; 
        #10;
        
        // Row 2: 0 0 1 0
        activation_in = 32'h00010000;
        #10;
        
        // Row 1: 0 1 0 0
        activation_in = 32'h00000100;
        #10;
        
        // Row 0: 1 0 0 0
        activation_in = 32'h00000001;
        #10;
        
        // Stop Loading
        load_weight = 0;
        activation_in = 0;
        #20;

        // ============================================
        // PHASE 2: COMPUTE 
        // ============================================
        $display("Streaming Input Vector [1, 1, 1, 1]...");
        
        // Input: 1, 1, 1, 1 (Hex: 01010101)
        activation_in = 32'h01010101;
        
        // Run for enough cycles for the wave to pass through the array
        #100;
        
        $finish;
    end
    
endmodule