module high_res_nco #(
    parameter ADDR_BITS = 10,     
    parameter DATA_BITS = 18,     
    parameter PHASE_BITS = 20     
)(
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire [PHASE_BITS-1:0] freq_word,
    input wire sin_cos_sel,  // 0=sine, 1=cosine
    output reg [DATA_BITS-1:0] dds_out
);

    reg [PHASE_BITS-1:0] phase_acc;
    reg [DATA_BITS-1:0] sine_lut [0:(2**ADDR_BITS)-1];
    
    wire [ADDR_BITS-1:0] sine_addr = phase_acc[PHASE_BITS-1:PHASE_BITS-ADDR_BITS];
    wire [ADDR_BITS-1:0] cos_addr = sine_addr + (2**(ADDR_BITS-2));
    
    initial $readmemh("sine_lut.mem", sine_lut);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_acc <= 0;
            dds_out <= 0;
        end else if (enable) begin
            phase_acc <= phase_acc + freq_word;
            dds_out <= sin_cos_sel ? sine_lut[cos_addr] : sine_lut[sine_addr];
        end
    end

endmodule