`timescale 1ns / 1ps

module tb_nco;
    
    reg clk = 0;
    reg rst_n = 0;
    reg enable = 0;
    reg [19:0] freq_word = 0;  
    reg sin_cos_sel = 0;
    wire [17:0] dds_out;       
    
    high_res_nco dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .freq_word(freq_word),
        .sin_cos_sel(sin_cos_sel),
        .dds_out(dds_out)
    );
    
    always #5 clk = ~clk; 
    
    initial begin
        $dumpfile("nco.vcd");
        $dumpvars(0, tb_nco);
        
        #50 rst_n = 1;
        #10 enable = 1;
        freq_word = 20'h10000; 
        
        sin_cos_sel = 0;
        #2000;
        
        // Test cosine  
        sin_cos_sel = 1;
        #2000;
        
        $finish;
    end
    
endmodule