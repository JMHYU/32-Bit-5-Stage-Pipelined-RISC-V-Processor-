`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 13:17:43
// Design Name: 
// Module Name: iMEM
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


module iMEM(
        input                 clk, reset,
        input                 BTB_MISS,
        input                 IF_ID_Write, PCSrc,
        input       [31:0]    PC_in,
        output reg  [31:0]   instruction_out);
        
    parameter ROM_size = 61;
    reg [31:0] ROM [0:ROM_size-1];
    integer i;
    
    initial begin
        $readmemh("darksocv.rom.mem", ROM);
    end
    
    always @ (posedge clk) begin
        if(!IF_ID_Write) begin
            if(reset|| (PCSrc && BTB_MISS) ) 
                instruction_out <= 32'b0;
            else 
                instruction_out <= ROM[PC_in[31:2]];
        end
    end
    
endmodule

