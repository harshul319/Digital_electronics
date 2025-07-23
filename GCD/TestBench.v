`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2025 01:35:55
// Design Name: 
// Module Name: tb
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


module GCD_test;
  reg         clk, start;
  reg  [15:0] data_in;
  wire        lt, gt, eq, done;
  wire        ldA, ldB, sel1, sel2, sel_in;
  wire [15:0] A;
  // DUT instantiations
  GCD_datapath DP (
    .gt   (gt),
    .lt   (lt),
    .eq   (eq),
    .ldA  (ldA),
    .ldB  (ldB),
    .sel1 (sel1),
    .sel2 (sel2),
    .sel_in(sel_in),
    .data_in(data_in),
    .clk  (clk),
    .Aout(A)
  );
  controller CON (
    .ldA   (ldA),
    .ldB   (ldB),
    .sel1  (sel1),
    .sel2  (sel2),
    .sel_in(sel_in),
    .done  (done),
    .clk   (clk),
    .lt    (lt),
    .gt    (gt),
    .eq    (eq),
    .start (start)
  );

  initial begin
    clk   <= 0;
    start <= 0;
    data_in <= 16'd143;  // First load
    start <= 1;
    #16 start <= 0;
    // Give it some time to load A and B
    #12 data_in <= 16'd78;  // Next load
    #100 $finish;
  end

  always #5 clk = ~clk;
  
  initial
  begin
    $monitor ($time, " %d %b", DP.Aout, done);
  end
endmodule
