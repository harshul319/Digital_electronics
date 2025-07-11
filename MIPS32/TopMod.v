`timescale 1ns / 1ps
module TopMod(
    input  wire        clk,       // 100 MHz on-board clock
    output wire [7:0]  D0_SEG,
    output wire [3:0]  D0_AN,
    output wire [7:0]  D1_SEG,
    output wire [3:0]  D1_AN
);
    wire [31:0] reg5val;
    
    wire slow_clk;
    clock_divider #(50000000) div1 (
    .clk_in(clk),
    .rst(1'b0),
    .clk_out(slow_clk)
);


    // Instantiate CPU
    pipe_MIPS32 cpu (
        .clk      (slow_clk),
        .reg_out5 (reg5val)
    );

    // Instantiate display driver
    seven_seg_display disp (
        .clk   (slow_clk),
        .data  (reg5val),
        .D0_SEG(D0_SEG),
        .D0_AN (D0_AN),
        .D1_SEG(D1_SEG),
        .D1_AN (D1_AN)
    );
endmodule
