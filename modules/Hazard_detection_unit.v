`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 13:15:59
// Design Name: 
// Module Name: Hazard_detection_unit
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


module Hazard_detection_unit(
    input       exe_Ctl_MemRead_in,
    input [4:0] exe_Rd_in, mem_Rd_in,
    input [9:0] instruction_in,
    input [6:0] opcode,
    input [2:0] func3,
    input       mem_Ctl_MemRead_in,
    input       exe_Ctl_RegWrite_in,
    output      stall_out
    );
    
    reg is_branch;
    always @(*) begin
		casex({opcode, func3})
			10'b1100111_xxx : is_branch = 1'b1;							// jalr
			10'b1101111_xxx : is_branch = 1'b1;							// jal 
			10'b1100011_000 : is_branch = 1'b1;	// beq 
			10'b1100011_001 : is_branch = 1'b1;		// bne 
			10'b1100011_100 : is_branch = 1'b1;		// blt 
			10'b1100011_101 : is_branch = 1'b1;	// bge 
			default : is_branch = 1'b0;
		endcase
	end
    
    
    wire [4:0] Rs1_in = instruction_in[4:0];
    wire [4:0] Rs2_in = (
            opcode == 7'b0000011 || // lw
            opcode == 7'b0010011 || // addi...
            opcode == 7'b1100111)       ? 0 : instruction_in[9:5];
    
    wire stall_0 = (exe_Ctl_MemRead_in && (exe_Rd_in==Rs1_in || exe_Rd_in == Rs2_in)) ? 1'b1 : 1'b0;
    wire stall_1 = (is_branch && mem_Ctl_MemRead_in && (mem_Rd_in==Rs1_in || mem_Rd_in == Rs2_in)) ? 1'b1 : 1'b0;
    wire stall_2 = (is_branch && exe_Ctl_RegWrite_in && (exe_Rd_in==Rs1_in || exe_Rd_in == Rs2_in)) ? 1'b1 : 1'b0;
    or(stall_out, stall_0, stall_1, stall_2);
    
    
endmodule

