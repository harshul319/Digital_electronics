`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2025 00:13:20
// Design Name: 
// Module Name: DatapathAndController
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module GCD_datapath( gt, lt, eq, ldA, ldB, sel1, sel2, sel_in, data_in, clk , Aout );
input ldA, ldB, sel1, sel2, sel_in, clk;
input [15:0] data_in;
output gt, lt, eq;
output wire [15:0] Aout;
wire [15:0] Bout, X, Y, Bus, SubOut;

    PIPO A (Aout, Bus, ldA, clk);
    PIPO B (Bout, Bus, ldB, clk);
    MUX MUX_in1 (X, Aout, Bout, sel1);
    MUX MUX_in2 (Y, Aout, Bout, sel2);
    MUX MUX_load (Bus, SubOut, data_in, sel_in);
    SUB SB (SubOut, X, Y);
    COMPARE COMP (lt, gt, eq, Aout, Bout);

endmodule















