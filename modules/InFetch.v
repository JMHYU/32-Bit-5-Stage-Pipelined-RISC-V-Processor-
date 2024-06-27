`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 13:18:20
// Design Name: 
// Module Name: InFetch
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


module InFetch(
    input               clk, reset,
    input               PCSrc, // Flush
    input               PCWrite, //Stall
    input        [31:0] PCimm_in,
    input               BTB_MISS,
    input        [33:0] BTB_PASS,
    output       [31:0] instruction_out,
    output reg   [31:0] PC_out,
    output       [31:0] IF_PC_out);
	
    wire [31:0] PC;
	
	wire [31:0] real_PCimm_in = (BTB_MISS) ? BTB_PASS[31:0] : PCimm_in;
    wire        real_PCSrc = (BTB_MISS) ? BTB_PASS[33:32] : PCSrc;
	wire        repair = (BTB_PASS[31:0] == PC) && (BTB_MISS) && (!real_PCSrc);
	wire [31:0] repair_PC = (repair) ? PC_out : PC;
    wire [31:0] PC4 = (real_PCSrc) ? real_PCimm_in : repair_PC + 4;
    wire [31:0] test_IF_imm = real_PCimm_in>>2;
    
    PC B1_PC(
    .clk(clk),
    .reset(reset),
    .PCWrite(PCWrite),
    .PC_in(PC4), 
    .PC_out(PC));
    
    assign IF_PC_out = PC;
    
    iMEM B2_iMEM(
    .clk(clk),
    .reset(reset),
    .BTB_MISS(BTB_MISS),
    .IF_ID_Write(PCWrite),
    .PCSrc(real_PCSrc),
    .PC_in(PC),
    .instruction_out(instruction_out));
    
    always @ (posedge clk) begin
        if(reset)  PC_out <= 32'b0;
        else if (PCWrite) PC_out <= PC_out;
        else if (BTB_MISS && real_PCSrc) PC_out <= 32'b0;
        else if (repair) PC_out <= 32'b0;
        else              PC_out <= PC;
    end
    
    wire [31:0] IF_test = PC >> 2;
endmodule
