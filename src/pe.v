`timescale 1ns / 1ps

module pe(
    input wire clk,
    input wire rst,
    input wire load_weight,        // Control signal: 1 = Load Weight, 0 = Compute
    input wire signed [7:0] in_n,  // Input from North (Activation data or Weight)
    input wire signed [23:0] in_w, // Input from West (Partial Sum coming in)
    output reg signed [7:0] out_s, // Output to South (Passing activation down)
    output reg signed [23:0] out_e // Output to East (Resulting Partial Sum)
    );

    // Internal storage for the stationary weight
    reg signed [7:0] weight_reg;
    
    // Internal wire for calculation
    // Multiplication result: 8-bit * 8-bit = 16-bit
    // We strictly use signed arithmetic for ML
    wire signed [15:0] mult_result;
    
    // The MAC operation
    assign mult_result = in_n * weight_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            weight_reg <= 8'd0;
            out_s <= 8'd0;
            out_e <= 24'd0;
        end
        else begin
            if (load_weight) begin
                // SETUP PHASE:
                // If load_weight is high, the data coming from North is actually the weight.
                // Store it. Don't compute yet.
                weight_reg <= in_n;
                
                // Pass 0s or keep previous values during loading to prevent garbage data
                out_s <= in_n; 
                out_e <= in_w;
            end
            else begin
                // COMPUTE PHASE:
                // 1. Pass the North input to South (for the PE below us)
                out_s <= in_n;
                
                // 2. Perform MAC: New Sum = Input_West + (Input_North * Stored_Weight)
                // We add the mult_result to the incoming partial sum
                out_e <= in_w + {{8{mult_result[15]}}, mult_result}; 
                
                // Note: {{8{...}}} is sign extension to convert 16-bit mult to 24-bit add
            end
        end
    end

endmodule