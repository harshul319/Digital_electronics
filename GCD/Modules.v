`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2025 00:45:20
// Design Name: 
// Module Name: Modules
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


module PIPO( data_out, data_in, load, clk );
input [15:0] data_in;
input load, clk;
output reg [15:0] data_out;

always @(negedge clk)
    if(load) data_out <= data_in;

endmodule


module  SUB (out, in1, in2);
input [15:0] in1, in2;
output reg [15:0] out;
always @(*)
    out = in1-in2;
endmodule


module COMPARE (lt, gt, eq, data1, data2);
input [15:0] data1, data2;
output lt, gt, eq;
assign lt=data1<data2;
assign gt=data1>data2;
assign eq=data1==data2;
endmodule


module MUX (out, in0, in1, sel);
input [15:0] in0, in1;
input sel;
output [15:0] out;
assign out=sel?in1:in0;
endmodule