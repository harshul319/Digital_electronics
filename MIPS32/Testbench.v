`timescale 1ns/1ps
module test_mips32;

  reg        clk;
  integer    k;

  // instantiate your pipelined CPU
  pipe_MIPS32 mips (clk);

  // ────────────────────────────────────────────────────────
  // generate a two-phase clock
  // ────────────────────────────────────────────────────────
  initial begin
    clk = 0; 
    forever begin
      #5 clk = 1; 
      #5 clk = 0;
    end
    
  end


  // ────────────────────────────────────────────────────────
  // initialize register file, instruction memory, PC, etc.
  // ────────────────────────────────────────────────────────
  initial begin
    // reg[0] through reg[30] = their index
    for (k = 0; k < 32; k = k + 1)
      mips.Reg[k] <= k;

    // program in Mem[0..8]:
    mips.Mem[0] <= 32'h2801000a;  // ADDI  R1, R0, 10
    mips.Mem[1] <= 32'h28020014;  // ADDI  R2, R0, 20
    mips.Mem[2] <= 32'h28030019;  // ADDI  R3, R0, 25
    mips.Mem[3] <= 32'h0ce77800;  // OR    R7, R7, R7   -- dummy instr.
    mips.Mem[4] <= 32'h0ce77800;  // OR    R7, R7, R7   -- dummy instr.
    mips.Mem[5] <= 32'h00222000;  // ADD   R4, R1, R2
    mips.Mem[6] <= 32'h0ce77800;  // OR    R7, R7, R7   -- dummy instr.
    mips.Mem[7] <= 32'h00832800;  // ADD   R5, R4, R3
    mips.Mem[8] <= 32'hfc000000;  // HLT

    // reset PC and control flags
    mips.HALTED        <= 0;
    mips.PC            <= 0;
    mips.TAKEN_BRANCH  <= 0;

    // let it run for enough cycles, then dump regs 0-5
    #280
    for (k = 0; k < 6; k = k + 1)
      $display("R%1d - %2d", k, mips.Reg[k]);
     $finish;
  end




endmodule
