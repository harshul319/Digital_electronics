`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2025 01:05:39
// Design Name: 
// Module Name: Controller
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


module controller( ldA, ldB, sel1, sel2, sel_in, done, clk, lt, gt, eq, start );
input clk, lt, gt, eq, start;
output reg ldA, ldB, sel1, sel2, sel_in, done;

parameter S0=3'b000, S1=3'b001, S2=3'b010, S3=3'b011, S4=3'b100, S5=3'b101;
reg[2:0] state;
always @(posedge clk)
begin
    case(state)
    S0: begin
        if(start) state<=S1;       
        end
    S1: begin
            state<=S2;
        end
    S2: begin
            if(eq) state<=S5;
            else if(lt) state<=S3;
            else if(gt) state<=S4;   
        end
    S3: begin
            if(eq) state<=S5;
            else if(lt) state<=S3;
            else if(gt) state<=S4;   
        end  
    S4: begin
            if(eq) state<=S5;
            else if(lt) state<=S3;
            else if(gt) state<=S4;   
        end
    S5: state<=S5;
    default: state<=S0;
    endcase
end

always @(state)
begin
    case(state)
    S0: begin
            sel_in=1;
            ldA=1;
            ldB=0;
            done=0;
        end
    S1: begin
            sel_in=1;
            ldA=0;
            ldB=1;
        end
    S2, S3, S4: if(eq) done=1;
        else if(lt) begin
                        sel1=1; sel2=0; sel_in=0;
                        ldA=0; ldB=1;
                    end
         else if(gt) begin
                        sel1=0; sel2=1; sel_in=0;
                        ldA=1; ldB=0;
                    end  
    S5: begin
            done=1; sel1=0; sel2=0; ldA=0; ldB=0;
        end          
    default: begin
                ldA=0;
                ldB=0;
             end
             
    endcase
end


endmodule
