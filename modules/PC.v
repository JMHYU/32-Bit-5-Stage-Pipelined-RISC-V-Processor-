`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 13:18:53
// Design Name: 
// Module Name: PC
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


module PC(
    input               clk, reset,
    input               PCWrite,
    input        [31:0] PC_in,
    output reg   [31:0] PC_out);
    
    always @(posedge clk) begin
        if(reset)         PC_out <= 31'b0;
        else if(PCWrite)  PC_out <= PC_out;
        else              PC_out <= PC_in;
    end

endmodule
