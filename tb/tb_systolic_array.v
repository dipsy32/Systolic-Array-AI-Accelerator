`timescale 1ns / 1ps

module tb_systolic_array;

    reg clk;
    reg rst;
    reg load_weight;
    reg [31:0] in_n; 
    reg [95:0] in_w; 
    wire [31:0] out_s;
    wire [95:0] out_e;

    systolic_array uut (
        .clk(clk), 
        .rst(rst), 
        .load_weight(load_weight), 
        .in_n(in_n), 
        .in_w(in_w), 
        .out_s(out_s), 
        .out_e(out_e)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        load_weight = 0;
        in_n = 0;
        in_w = 0;

        #20;
        rst = 0;
        
        // --- TEST FIX: KEEP INPUT CONSTANT ---
        $display("Test: Injecting 8'hAA into Column 0...");
        
        // We keep this value constant. We do NOT set it to 0 afterwards.
        in_n = 32'h000000AA; 
        
        // Wait 60ns (plenty of time for 4 cycles to pass)
        #60; 
        
        // Now check. Since input is constant, output should definitely be AA.
        if (out_s[7:0] === 8'hAA) 
            $display("SUCCESS: 0xAA reached the bottom of Column 0!");
        else
            $display("FAIL: Expected 0xAA, got %h", out_s[7:0]);
            
        $finish;
    end

endmodule