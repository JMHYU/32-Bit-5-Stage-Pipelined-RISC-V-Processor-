`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 13:17:24
// Design Name: 
// Module Name: Forwarding_unit
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


module Forwarding_unit(
    input mem_Ctl_RegWrite_in, wb_Ctl_RegWrite_in,
    input [4:0] exe_Rs1_in, exe_Rs2_in, mem_Rd_in, wb_Rd_in,
	input [4:0] ind_Rs1_in, ind_Rs2_in,
	input [6:0] opcode,
    output [1:0] exe_ForwardA_out, exe_ForwardB_out,
	output [1:0] ind_ForwardA_out, ind_ForwardB_out
    );

	wire [4:0] Rs2_in = (
            opcode == 7'b0000011 ||
            opcode == 7'b0010011 ||
            opcode == 7'b1100111)       ? 0 : ind_Rs2_in;	
            
    assign exe_ForwardA_out = (mem_Ctl_RegWrite_in && (mem_Rd_in == exe_Rs1_in)) ? 2'b10 : (wb_Ctl_RegWrite_in && (wb_Rd_in == exe_Rs1_in)) ? 2'b01 : 2'b00;
    assign exe_ForwardB_out = (mem_Ctl_RegWrite_in && (mem_Rd_in == exe_Rs2_in)) ? 2'b10 : (wb_Ctl_RegWrite_in && (wb_Rd_in == exe_Rs2_in)) ? 2'b01 : 2'b00;
	
	//additional code
	assign ind_ForwardA_out = (mem_Ctl_RegWrite_in && (mem_Rd_in == ind_Rs1_in)) ? 2'b10 : (wb_Ctl_RegWrite_in && (wb_Rd_in == ind_Rs1_in)) ? 2'b01 : 2'b00;
    assign ind_ForwardB_out = (mem_Ctl_RegWrite_in && (mem_Rd_in == Rs2_in)) ? 2'b10 : (wb_Ctl_RegWrite_in && (wb_Rd_in == Rs2_in)) ? 2'b01 : 2'b00;
	
endmodule
