`timescale 1ns / 1ps
module seven_seg_display(
    input  wire        clk,
    input  wire [31:0] data,     // we'll map data[3:0] → D0, data[7:4] → D1
    output reg  [7:0]  D0_SEG,   // segments a-g + DP (active low)
    output reg  [3:0]  D0_AN,    // digit enables (active low)
    output reg  [7:0]  D1_SEG,
    output reg  [3:0]  D1_AN
);

    // 7-segment encoding for hex 0-F (active low)
    function [7:0] encode;
        input [3:0] nib;
        case (nib)
            4'h0: encode = 8'b11000000;
            4'h1: encode = 8'b11111001;
            4'h2: encode = 8'b10100100;
            4'h3: encode = 8'b10110000;
            4'h4: encode = 8'b10011001;
            4'h5: encode = 8'b10010010;
            4'h6: encode = 8'b10000010;
            4'h7: encode = 8'b11111000;
            4'h8: encode = 8'b10000000;
            4'h9: encode = 8'b10010000;
            4'hA: encode = 8'b10001000;
            4'hB: encode = 8'b10000011;
            4'hC: encode = 8'b11000110;
            4'hD: encode = 8'b10100001;
            4'hE: encode = 8'b10000110;
            4'hF: encode = 8'b10001110;
            default: encode = 8'b11111111;
        endcase
    endfunction

    // On every clock, update the two displays
    always @(posedge clk) begin
        // D0 shows lower nibble
        D0_SEG <= encode(data[7:4]);
        D0_AN  <= 4'b1110;    // enable digit 0 only

        // D1 shows next nibble
        D1_SEG <= encode(data[3:0]);
        D1_AN  <= 4'b0111;    // enable digit 0 of second module
    end
endmodule
