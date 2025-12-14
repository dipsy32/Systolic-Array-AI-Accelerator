`timescale 1ns / 1ps

module skew_buffer(
    input wire clk,
    input wire rst,             
    input wire [31:0] raw_input, 
    output wire [31:0] skewed_output 
    );

    wire [7:0] in0 = raw_input[7:0];
    wire [7:0] in1 = raw_input[15:8];
    wire [7:0] in2 = raw_input[23:16];
    wire [7:0] in3 = raw_input[31:24];

    reg [7:0] d1_1;
    reg [7:0] d2_1, d2_2;
    reg [7:0] d3_1, d3_2, d3_3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            d1_1 <= 0;
            d2_1 <= 0; d2_2 <= 0;
            d3_1 <= 0; d3_2 <= 0; d3_3 <= 0;
        end
        else begin
            // Pipeline for Col 1
            d1_1 <= in1;

            // Pipeline for Col 2
            d2_1 <= in2;
            d2_2 <= d2_1;

            // Pipeline for Col 3
            d3_1 <= in3;
            d3_2 <= d3_1;
            d3_3 <= d3_2;
        end
    end

    assign skewed_output[7:0]   = in0;   
    assign skewed_output[15:8]  = d1_1;  
    assign skewed_output[23:16] = d2_2;  
    assign skewed_output[31:24] = d3_3;  

endmodule
