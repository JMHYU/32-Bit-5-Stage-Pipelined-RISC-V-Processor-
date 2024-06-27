`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 13:17:07
// Design Name: 
// Module Name: Execution
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


module Execution(
    input clk, reset,
    input Ctl_ALUSrc_in, Ctl_MemtoReg_in, Ctl_RegWrite_in, Ctl_MemRead_in, Ctl_MemWrite_in, Ctl_Branch_in, Ctl_ALUOpcode1_in, Ctl_ALUOpcode0_in,
    output reg           Ctl_MemtoReg_out, Ctl_RegWrite_out, Ctl_MemRead_out, Ctl_MemWrite_out, Ctl_Branch_out,
    input [4:0] Rd_in,
    output reg [4:0] Rd_out,
    input jal_in, jalr_in,
    output reg jal_out, jalr_out,
    input [31:0] PC_in, Immediate_in, ReadData1_in, ReadData2_in,
    input [31:0] mem_data, wb_data,
    input [6:0] funct7_in,
    input [2:0] funct3_in,
    input [1:0] ForwardA_in, ForwardB_in,
    output reg Zero_out,
    output reg [31:0] ALUresult_out, ReadData2_out, PC_out);
    
    wire [3:0] ALU_ctl;
    wire [31:0] ALUresult;
    wire Zero;
    reg [31:0] ForwardB_input, ALU_input1;
    wire [31:0] ALU_input2;
    wire [31:0] EX_PC_test = PC_in >> 2;
    always @(*)
        case(ForwardA_in)
            2'b10 : ALU_input1 = mem_data;
            2'b01 : ALU_input1 = wb_data;
            default : ALU_input1 = ReadData1_in;
        endcase
    always @(*)        
        case(ForwardB_in)
            2'b10 : ForwardB_input = mem_data;
            2'b01 : ForwardB_input = wb_data;
            default : ForwardB_input =  ReadData2_in;
        endcase
    assign ALU_input2 = (Ctl_ALUSrc_in) ? Immediate_in : ForwardB_input;

    ALU_control B0 (.ALUop({Ctl_ALUOpcode1_in, Ctl_ALUOpcode0_in}), .funct7(funct7_in), .funct3(funct3_in), .ALU_ctl(ALU_ctl));
    ALU B1 (.ALU_ctl(ALU_ctl), .in1(ALU_input1), .in2(ALU_input2), .out(ALUresult), .zero(Zero));

// Execution Stage와 Memory Stage 사이에 pipelining용 register 생성
    always @(posedge clk) begin
        Ctl_MemtoReg_out <= (reset) ? 1'b0 : Ctl_MemtoReg_in;
        Ctl_RegWrite_out <= (reset) ? 1'b0 : Ctl_RegWrite_in;
        Ctl_MemRead_out  <= (reset) ? 1'b0 : Ctl_MemRead_in;
        Ctl_MemWrite_out <= (reset) ? 1'b0 : Ctl_MemWrite_in;
        Ctl_Branch_out   <= (reset) ? 1'b0 : Ctl_Branch_in;
        
        PC_out           <= (reset) ? 1'b0 : PC_in;
        jalr_out         <= (reset) ? 1'b0 : jalr_in;
        jal_out          <= (reset) ? 1'b0 : jal_in;
        
        Rd_out           <= (reset) ? 1'b0 : Rd_in;
        ReadData2_out    <= (reset) ? 1'b0 : ForwardB_input;
        ALUresult_out    <= (reset) ? 1'b0 : ALUresult;
        Zero_out         <= (reset) ? 1'b0 : Zero;   
    end
endmodule
