`timescale 1ns / 1ps

module matrix_accelerator(
    input wire clk,
    input wire rst,
    input wire load_weight,
    input wire [31:0] activation_in, 
    output wire [95:0] result_out    
    );

    wire [31:0] skewed_activations;
    wire [95:0] zero_west_input;
    
    // Internal wire for the selected input
    wire [31:0] array_input_n;

    assign zero_west_input = 96'd0;

    // 1. Instantiate Skew Buffer (Always running)
    skew_buffer skew_unit (
        .clk(clk),
        .rst(rst),
        .raw_input(activation_in),
        .skewed_output(skewed_activations)
    );

    // 2. THE FIX: MUX LOGIC
    // If loading weights, use RAW input (bypass skew).
    // If computing, use SKEWED input.
    assign array_input_n = (load_weight) ? activation_in : skewed_activations;

    // 3. Instantiate the Systolic Array
    systolic_array array_core (
        .clk(clk),
        .rst(rst),
        .load_weight(load_weight),
        .in_n(array_input_n),      // <--- Connect the MUX output here
        .in_w(zero_west_input),   
        .out_s(),                  
        .out_e(result_out)         
    );

endmodule