module clock_divider #(parameter DIV_VAL = 50_000_000)(
    input wire clk_in,
    input wire rst,
    output reg clk_out
);
    reg [31:0] counter = 0;

    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter <= 0;
            clk_out <= 0;
        end else if (counter == DIV_VAL - 1) begin
            counter <= 0;
            clk_out <= ~clk_out;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule
