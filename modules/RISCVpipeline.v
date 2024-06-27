`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 13:19:36
// Design Name: 
// Module Name: RISCVpipeline
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


module RISCVpipeline(
    input 	key,
	output 	[ 7:0] digit,
	output 	[ 7:0] fnd,
	output 	[15:0] LED,
	input clk, reset
	);
	wire rst;
	assign rst = ~reset;
	wire c;
	wire [2:0] LED_clk;
	wire [31:0] pc, ins;
	wire ind_ctl_0, ind_ctl_1, ind_ctl_2, ind_ctl_3, ind_ctl_4, ind_ctl_5, ind_ctl_6, ind_ctl_7;
	wire exe_ctl_0, exe_ctl_1, exe_ctl_2, exe_ctl_3, exe_ctl_4, exe_ctl_5, exe_ctl_6, exe_ctl_7;
	wire mem_ctl_0, mem_ctl_1, mem_ctl_2, mem_ctl_3, mem_ctl_4, mem_ctl_5, mem_ctl_6, mem_ctl_7;
	wire wb_ctl_0,  wb_ctl_1,  wb_ctl_2,  wb_ctl_3,  wb_ctl_4,  wb_ctl_5,  wb_ctl_6,  wb_ctl_7;
	
	wire hzd_stall;
	wire [ 1:0]  exe_fwd_A, exe_fwd_B;
	
	wire [31:0]  ind_pc, ind_data1, ind_data2, ind_imm;
    wire [31:0]	 exe_pc, exe_data2, exe_addr, exe_result;
    wire [31:0]  mem_pc, mem_addr, mem_result, mem_data;		
    wire [31:0]  wb_data;
	wire [4:0]	 ind_rd, ind_rs1, ind_rs2;	
	wire [4:0]   exe_rd;	
	wire [4:0]   mem_rd;	
	wire [4:0]   wb_rd;
	wire [6:0]	 ind_funct7;
	wire [2:0]	 ind_funct3;
	wire 		 ind_jal, ind_jalr;		
	wire         exe_jalr, exe_jal, exe_zero;	
	wire         mem_jalr, mem_jal, mem_PCSrc;

	wire	[31:0] clk_address, clk_count;
	wire 	[31:0] data = (key)? mem_data : clk_count;
	wire 	[31:0] RAM_address = (key) ? (clk_address<<2) : exe_result;
	assign LED =  (key) ? 16'b1000_0000_0000_0000 : 16'b0;
//////////////////////////////////////////////////////////////////////////////////////
LED_channel LED0(
	.data(data),							.digit(digit),
	.LED_clk(LED_clk),					.fnd(fnd));
//////////////////////////////////////////////////////////////////////////////////////
counter A0_counter(
	.key1(key),
	.mem_data(mem_data),
	.clk_address(clk_address),
	.indrs1(ind_rs1),
	.inddata1(ind_data1),
	.clk(clk),								.LED_clk(LED_clk),
	.rst(rst),								.clk_out(c),
	.pc_in(pc),						        
	.clk_count_out(clk_count));
//////////////////////////////////////////////////////////////////////////////////////	
	wire ind_PCSrc;
	wire [31:0] ind_PCimm_out;
	wire [1:0] ind_fwd_A, ind_fwd_B;
	wire [31:0] IF_PC_out;
	wire Ctl_Branch_imm;
	wire [31:0] BTB_target;
	wire [1:0] BTB_predic;
	wire BTB_MISS;
	wire [33:0] BTB_PASS;
	
	InFetch A1_InFetch(		
        .PCWrite(hzd_stall), .PCSrc(BTB_predic[1]),      .PC_out(pc),
        .PCimm_in(BTB_target),                        .IF_PC_out(IF_PC_out),    
                                                      .instruction_out(ins),
        .BTB_MISS(BTB_MISS),
        .BTB_PASS(BTB_PASS),
        .reset(rst),
        .clk(c)		
	);			

	BTB AA_BTB(
	.i_clk(c), .i_rst(rst),
	.ind_Ctl_branch_in(Ctl_Branch_imm),
	.IF_PC_in(IF_PC_out), .IND_PC_in(pc), .PCimm_in(ind_PCimm_out),
	.PCSrc(ind_PCSrc),
	.hz_stall(hzd_stall),
	.predict(BTB_predic),
	.target(BTB_target),
	.MISS(BTB_MISS),
	.IND_PC_PASS(BTB_PASS));
			
	InDecode A3_InDecode(
        .Ctl_RegWrite_in(wb_ctl_2),                 .Ctl_ALUSrc_out(ind_ctl_0), .Ctl_MemtoReg_out(ind_ctl_1), .Ctl_RegWrite_out(ind_ctl_2), 
                                                    .Ctl_MemRead_out(ind_ctl_3), .Ctl_MemWrite_out(ind_ctl_4), .Ctl_Branch_out(ind_ctl_5), 
                                                    .Ctl_ALUOpcode1_out(ind_ctl_6), .Ctl_ALUOpcode0_out(ind_ctl_7), .Ctl_Branch_imm(Ctl_Branch_imm),
        .WriteReg(wb_rd),  .WriteData(wb_data),
        .PC_in(pc),                                 .PC_out(ind_pc),  
        .instruction_in(ins),                       .Rs1_out(ind_rs1), .Rs2_out(ind_rs2), .Rd_out(ind_rd),
                                                    .ReadData1_out(ind_data1), .ReadData2_out(ind_data2), .Immediate_out(ind_imm),
                                                    .funct7_out(ind_funct7), .funct3_out(ind_funct3), .jalr_out(ind_jalr), .jal_out(ind_jal),  
        .stall(hzd_stall),                                       
        .reset(rst),
        .clk(c),
        .PCSrc(ind_PCSrc),
        .PCimm_out(ind_PCimm_out),
        .fwd_A_in(ind_fwd_A), .fwd_B_in(ind_fwd_B),
        .mem_data(exe_result),
        .BTB_MISS(BTB_MISS)								
	);


	Hazard_detection_unit A3_Hazard (
         .exe_Ctl_MemRead_in(ind_ctl_3), .mem_Ctl_MemRead_in(exe_ctl_3), .exe_Ctl_RegWrite_in(ind_ctl_2), 
         .exe_Rd_in(ind_rd), .mem_Rd_in(exe_rd),
         .instruction_in(ins[24:15]), .opcode(ins[6:0]), .func3(ins[14:12]),
                                                                                        .stall_out(hzd_stall)					
	);
	Execution A4_Execution(
        .Ctl_ALUSrc_in(ind_ctl_0),                                              .Ctl_MemtoReg_out(exe_ctl_1), .Ctl_RegWrite_out(exe_ctl_2), 
        .Ctl_MemtoReg_in(ind_ctl_1),                                            .Ctl_MemRead_out(exe_ctl_3), .Ctl_MemWrite_out(exe_ctl_4), 
        .Ctl_RegWrite_in(ind_ctl_2),                                            .Ctl_Branch_out(exe_ctl_5),
        .Ctl_MemRead_in(ind_ctl_3),                                             
        .Ctl_MemWrite_in(ind_ctl_4),                                             
        .Ctl_Branch_in(ind_ctl_5), 
        .Ctl_ALUOpcode1_in(ind_ctl_6), 
        .Ctl_ALUOpcode0_in(ind_ctl_7),
        
        .Rd_in(ind_rd),                                                         .Rd_out(exe_rd),
        .ReadData1_in(ind_data1), .ReadData2_in(ind_data2),                     .ReadData2_out(exe_data2),
        .mem_data(exe_result),    .wb_data(wb_data),                            .ALUresult_out(exe_result),
        
        .PC_in(ind_pc), .Immediate_in(ind_imm),                                 .PC_out(exe_pc),
        .funct7_in(ind_funct7), .funct3_in(ind_funct3),                           .Zero_out(exe_zero),  
        
        .jalr_in(ind_jalr), .jal_in(ind_jal),                                   .jalr_out(exe_jalr), .jal_out(exe_jal),
        .ForwardA_in(exe_fwd_A), .ForwardB_in(exe_fwd_B),
        
        .reset(rst), 
        .clk(c)		
	);
	Forwarding_unit A5_Forwarding (
        .mem_Ctl_RegWrite_in(exe_ctl_2), .wb_Ctl_RegWrite_in(mem_ctl_2),   
        .exe_Rs1_in(ind_rs1), .exe_Rs2_in(ind_rs2),
		.ind_Rs1_in(ins[19:15]), .ind_Rs2_in(ins[24:20]),
        .mem_Rd_in(exe_rd), .wb_Rd_in(mem_rd),
        .opcode(ins[6:0]),
                                                                        .exe_ForwardA_out(exe_fwd_A), .exe_ForwardB_out(exe_fwd_B),
																		.ind_ForwardA_out(ind_fwd_A), .ind_ForwardB_out(ind_fwd_B)
	);
	Memory A6_Memory(
        .Ctl_MemtoReg_in(exe_ctl_1), .Ctl_RegWrite_in(exe_ctl_2),     .Ctl_MemtoReg_out(mem_ctl_1), .Ctl_RegWrite_out(mem_ctl_2),
        .Ctl_MemRead_in(exe_ctl_3),  .Ctl_MemWrite_in(exe_ctl_4), 
        .Ctl_Branch_in(exe_ctl_5),           
        .Zero_in(exe_zero),                                           
        
        .PC_in(exe_pc),                                               .PC_out(mem_pc),
        .Rd_in(exe_rd),                                               .Rd_out(mem_rd),
        .jalr_in(exe_jalr), .jal_in(exe_jal),                         .jalr_out(mem_jalr), .jal_out(mem_jal),
        
        .Write_Data(exe_data2),                                       .Read_Data(mem_data),
        .ALUresult_in(RAM_address),                                   .ALUresult_out(mem_result),
        
        .reset(rst),
        .clk(c)		
	);
	WB A7_WB(
        .Ctl_MemtoReg_in(mem_ctl_1),
        .Ctl_RegWrite_in(mem_ctl_2),         
        .jalr_in(mem_jalr), .jal_in(mem_jal),
                                              .Ctl_RegWrite_out(wb_ctl_2),
        .PC_in(mem_pc),
        .ReadDatafromMem_in(mem_data),  
        .ALUresult_in(mem_result),            .WriteDatatoReg_out(wb_data),
        
        .Rd_in(mem_rd),                       .Rd_out(wb_rd)		
	);

endmodule


