`timescale 1ns / 1ps

module systolic_array(
    input wire clk,
    input wire rst,
    input wire load_weight,       // Global load signal
    input wire [31:0] in_n,       // 4 inputs from North (8-bit each)
    input wire [95:0] in_w,       // 4 inputs from West (24-bit each)
    output wire [31:0] out_s,     // 4 outputs to South (8-bit each)
    output wire [95:0] out_e      // 4 outputs to East (24-bit each)
    );

    // Grid Dimensions
    parameter ROWS = 4;
    parameter COLS = 4;

    // Internal connecting wires
    // These 2D arrays store the connections BETWEEN PEs
    // wires_n[i][j] is the North input for PE at row i, col j
    wire signed [7:0]  conn_n [ROWS:0][COLS-1:0]; 
    wire signed [23:0] conn_w [ROWS-1:0][COLS:0]; 

    // Generate variables
    genvar i, j;

    generate
        // 1. Assign External Inputs to the boundary wires
        for (j = 0; j < COLS; j = j + 1) begin : INPUT_MAP_N
            // Map the flat 32-bit input to the top row (Row 0)
            assign conn_n[0][j] = in_n[8*j +: 8]; 
        end

        for (i = 0; i < ROWS; i = i + 1) begin : INPUT_MAP_W
            // Map the flat 96-bit input to the left column (Col 0)
            assign conn_w[i][0] = in_w[24*i +: 24];
        end

        // 2. Instantiate the 4x4 Grid of PEs
        for (i = 0; i < ROWS; i = i + 1) begin : ROW_LOOP
            for (j = 0; j < COLS; j = j + 1) begin : COL_LOOP
                
                pe pe_inst (
                    .clk(clk),
                    .rst(rst),
                    .load_weight(load_weight),
                    // Input from North (Row i, Col j)
                    .in_n(conn_n[i][j]),      
                    // Input from West (Row i, Col j)
                    .in_w(conn_w[i][j]),      
                    // Output to South (becomes North input for Row i+1)
                    .out_s(conn_n[i+1][j]),   
                    // Output to East (becomes West input for Col j+1)
                    .out_e(conn_w[i][j+1])    
                );
                
            end
        end

        // 3. Assign Boundary Wires to External Outputs
        for (j = 0; j < COLS; j = j + 1) begin : OUTPUT_MAP_S
            // The South output of the last row (Row 4) goes out
            assign out_s[8*j +: 8] = conn_n[ROWS][j];
        end

        for (i = 0; i < ROWS; i = i + 1) begin : OUTPUT_MAP_E
            // The East output of the last column (Col 4) goes out
            assign out_e[24*i +: 24] = conn_w[i][COLS];
        end

    endgenerate

endmodule