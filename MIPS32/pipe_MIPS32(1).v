`timescale 1ns / 1ps
module pipe_MIPS32(
    input  wire        clk,
    output reg [31:0]  reg_out5   // captures Reg[5] on HLT
);

  // ─────────────────────────────────────────────────────────────
  // Pipeline registers
  // ─────────────────────────────────────────────────────────────
  reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
  reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
  reg [2:0]  ID_EX_type, EX_MEM_type, MEM_WB_type;
  reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
  reg        EX_MEM_cond;
  reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;

  // Register file & memory
  reg [31:0] Reg [0:31];
  reg [31:0] Mem [0:1023];

  // Control flags
  reg HALTED       = 1'b0;
  reg TAKEN_BRANCH = 1'b0;

  // Opcode parameters
  parameter ADD    = 6'd0,   SUB    = 6'd1,  AND    = 6'd2,  OR     = 6'd3,
            SLT    = 6'd4,   MUL    = 6'd5,  HLT    = 6'b111111,
            LW     = 6'b001000, SW   = 6'b001001,
            ADDI   = 6'b001010, SUBI = 6'b001011,
            SLTI   = 6'b001100, BNEQZ= 6'b001101,
            BEQZ   = 6'b001110;

  parameter RR_ALU = 3'b000, RM_ALU = 3'b001,
            LOAD   = 3'b010, STORE  = 3'b011,
            BRANCH = 3'b100, HALT   = 3'b101;

  // ─────────────────────────────────────────────────────────────
  // Initialize instruction memory
  // ─────────────────────────────────────────────────────────────
  initial begin
    $readmemh("Instructions.hex", Mem);
  end

  // ─────────────────────────────────────────────────────────────
  // IF stage + branch flag (posedge clk)
  // ─────────────────────────────────────────────────────────────
  always @(posedge clk) begin
    if (!HALTED) begin
      // default clear
      TAKEN_BRANCH <= 1'b0;

      if (((EX_MEM_IR[31:26] == BEQZ)  && EX_MEM_cond) ||
          ((EX_MEM_IR[31:26] == BNEQZ) && !EX_MEM_cond)) begin
        // taken branch
        IF_ID_IR     <= Mem[EX_MEM_ALUOut];
        TAKEN_BRANCH <= 1'b1;
        IF_ID_NPC    <= EX_MEM_ALUOut + 1;
        PC           <= EX_MEM_ALUOut + 1;
      end else begin
        // sequential
        IF_ID_IR     <= Mem[PC];
        IF_ID_NPC    <= PC + 1;
        PC           <= PC + 1;
      end
    end
  end

  // ─────────────────────────────────────────────────────────────
  // ID stage (negedge clk)
  // ─────────────────────────────────────────────────────────────
  always @(negedge clk) begin
    if (!HALTED) begin
      ID_EX_A   <= (IF_ID_IR[25:21] == 5'b0) ? 32'd0 : Reg[IF_ID_IR[25:21]];
      ID_EX_B   <= (IF_ID_IR[20:16] == 5'b0) ? 32'd0 : Reg[IF_ID_IR[20:16]];
      ID_EX_NPC <= IF_ID_NPC;
      ID_EX_IR  <= IF_ID_IR;
      ID_EX_Imm <= {{16{IF_ID_IR[15]}}, IF_ID_IR[15:0]};

      case (IF_ID_IR[31:26])
        ADD,SUB,AND,OR,SLT,MUL: ID_EX_type <= RR_ALU;
        ADDI,SUBI,SLTI:         ID_EX_type <= RM_ALU;
        LW:                     ID_EX_type <= LOAD;
        SW:                     ID_EX_type <= STORE;
        BNEQZ,BEQZ:             ID_EX_type <= BRANCH;
        HLT:                    ID_EX_type <= HALT;
        default:                ID_EX_type <= HALT;
      endcase
    end
  end

  // ─────────────────────────────────────────────────────────────
  // EX stage (posedge clk)
  // ─────────────────────────────────────────────────────────────
  always @(posedge clk) begin
    if (!HALTED) begin
      EX_MEM_type  <= ID_EX_type;
      EX_MEM_IR    <= ID_EX_IR;
      EX_MEM_cond  <= EX_MEM_cond; // hold previous if not branch

      case (ID_EX_type)
        RR_ALU: begin
          case (ID_EX_IR[31:26])
            ADD: EX_MEM_ALUOut <= ID_EX_A + ID_EX_B;
            SUB: EX_MEM_ALUOut <= ID_EX_A - ID_EX_B;
            AND: EX_MEM_ALUOut <= ID_EX_A & ID_EX_B;
            OR : EX_MEM_ALUOut <= ID_EX_A | ID_EX_B;
            SLT: EX_MEM_ALUOut <= (ID_EX_A < ID_EX_B);
            MUL: EX_MEM_ALUOut <= ID_EX_A * ID_EX_B;
            default: EX_MEM_ALUOut <= 32'hxxxxxxxx;
          endcase
        end
        RM_ALU: begin
          case (ID_EX_IR[31:26])
            ADDI: EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm;
            SUBI: EX_MEM_ALUOut <= ID_EX_A - ID_EX_Imm;
            SLTI: EX_MEM_ALUOut <= (ID_EX_A < ID_EX_Imm);
            default: EX_MEM_ALUOut <= 32'hxxxxxxxx;
          endcase
        end
        LOAD,STORE: begin
          EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm;
          EX_MEM_B      <= ID_EX_B;
        end
        BRANCH: begin
          EX_MEM_ALUOut <= ID_EX_NPC + ID_EX_Imm;
          EX_MEM_cond   <= (ID_EX_A == 0);
        end
      endcase
    end
  end

  // ─────────────────────────────────────────────────────────────
  // MEM stage (negedge clk)
  // ─────────────────────────────────────────────────────────────
  always @(negedge clk) begin
    if (!HALTED) begin
      MEM_WB_type <= EX_MEM_type;
      MEM_WB_IR   <= EX_MEM_IR;

      case (EX_MEM_type)
        RR_ALU,RM_ALU: MEM_WB_ALUOut <= EX_MEM_ALUOut;
        LOAD:          MEM_WB_LMD    <= Mem[EX_MEM_ALUOut];
        STORE: if (!TAKEN_BRANCH)
                    Mem[EX_MEM_ALUOut] <= EX_MEM_B;
      endcase
    end
  end

  // ─────────────────────────────────────────────────────────────
  // WB stage (posedge clk)
  // ─────────────────────────────────────────────────────────────
  always @(posedge clk) begin
    if (!TAKEN_BRANCH) begin
      case (MEM_WB_type)
        RR_ALU:
          Reg[MEM_WB_IR[15:11]] <= MEM_WB_ALUOut;
        RM_ALU,LOAD:
          Reg[MEM_WB_IR[20:16]] <= 
            (MEM_WB_type == LOAD ? MEM_WB_LMD : MEM_WB_ALUOut);
        HALT: begin
          HALTED   <= 1'b1;
          reg_out5 <= Reg[5];
        end
      endcase
    end
  end

endmodule
