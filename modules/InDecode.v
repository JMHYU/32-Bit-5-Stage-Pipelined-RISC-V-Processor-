`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 13:17:58
// Design Name: 
// Module Name: InDecode
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


module InDecode(
    input clk, reset,
    input stall,
    input BTB_MISS,
    input Ctl_RegWrite_in,
    output reg Ctl_Branch_out, Ctl_ALUSrc_out, Ctl_MemtoReg_out, Ctl_RegWrite_out, Ctl_MemRead_out, Ctl_MemWrite_out, Ctl_ALUOpcode1_out, Ctl_ALUOpcode0_out,
    input [4:0] WriteReg,
    input [31:0] PC_in, instruction_in, WriteData,
    output reg [4:0] Rd_out, Rs1_out, Rs2_out,
    output reg [31:0] PC_out, ReadData1_out, ReadData2_out, Immediate_out,
    output reg [6:0] funct7_out,
    output reg [2:0] funct3_out,
    output reg jalr_out, jal_out,
    output reg PCSrc,
    output reg [31:0] PCimm_out,
    output Ctl_Branch_imm,
    input [1:0] fwd_A_in, fwd_B_in,
    input [31:0] mem_data
    );
 
     wire [6:0] opcode = instruction_in[6:0];
     wire [4:0] Rd = instruction_in[11:7];
     wire [2:0] func3 = instruction_in[14:12];
     wire [4:0] Rs1 = instruction_in[19:15];     
     wire [6:0] func7 = instruction_in[31:25];
     
     wire real_Rs2 = (opcode != 7'b00000_11) && (opcode != 7'b00100_11) && (opcode != 7'b11001_11);
	 wire [4:0] Rs2 = (real_Rs2) ? instruction_in[24:20] : 0; 
    
    
    
     wire      jalr = (opcode == 7'b1100111) ? 1 : 0;
     wire       jal = (opcode == 7'b1101111) ? 1 : 0;
     
     wire [7:0] Ctl_out;
     reg [7:0] Control;  
   
   Control_unit B0 (.opcode(opcode), .Ctl_out(Ctl_out), .reset(reset));
   
   always @(*) Control = (stall) ? 1'b0 : Ctl_out;
   
   assign Ctl_Branch_imm = Control[2];
   
   parameter reg_size = 32;
   reg [31:0] Reg[0:reg_size-1];
   
   always @(posedge clk) begin
        if(reset) Reg[0] <= 0;
        else if( Ctl_RegWrite_in && (WriteReg != 0) ) Reg[WriteReg] <= WriteData;
   end
   
   reg [31:0] Immediate;
   always @(*) begin
    case(opcode)
      7'b00000_11 : Immediate = $signed(instruction_in[31:20]);
      7'b00100_11 : Immediate = $signed(instruction_in[31:20]);
      7'b11001_11 : Immediate = $signed(instruction_in[31:20]);
      7'b01000_11 : Immediate = $signed({instruction_in[31:25], instruction_in[11:7]});
      7'b11000_11 : Immediate = $signed({instruction_in[31], instruction_in[7], instruction_in[30:25], instruction_in[11:8]});
      7'b11011_11 : Immediate = $signed({instruction_in[31], instruction_in[19:12], instruction_in[20], instruction_in[30:21]});
      default     : Immediate = 32'b0; 
   endcase
   end
   

   always@(posedge clk) begin
     PC_out             <= (reset) ? 1'b0 : PC_in;
     funct7_out         <= (reset) ? 1'b0 : func7;
     funct3_out         <= (reset) ? 1'b0 : func3;
     Rd_out             <= (reset) ? 1'b0 : Rd;
     Rs1_out            <= (reset) ? 1'b0 : Rs1;
     Rs2_out            <= (reset) ? 1'b0 : Rs2;
     ReadData1_out      <= (reset) ? 1'b0 : (Ctl_RegWrite_in && WriteReg==Rs1) ? WriteData : Reg[Rs1]; // bypass ¿ë
     ReadData2_out      <= (reset) ? 1'b0 : (Ctl_RegWrite_in && WriteReg==Rs2) ? WriteData : Reg[Rs2]; // bypass ¿ë
     jalr_out           <= (reset) ? 1'b0 : jalr;
     jal_out            <= (reset) ? 1'b0 : jal;
     Ctl_ALUSrc_out     <= (reset) ? 1'b0 : Control[7];
     Ctl_MemtoReg_out   <= (reset) ? 1'b0 : Control[6];
     Ctl_RegWrite_out   <= (reset) ? 1'b0 : Control[5];
     Ctl_MemRead_out    <= (reset) ? 1'b0 : Control[4];
     Ctl_MemWrite_out   <= (reset) ? 1'b0 : Control[3];
     Ctl_Branch_out     <= (reset) ? 1'b0 : Control[2];
     Ctl_ALUOpcode1_out <= (reset) ? 1'b0 : Control[1];
     Ctl_ALUOpcode0_out <= (reset) ? 1'b0 : Control[0];
     Immediate_out      <= (reset) ? 1'b0 : Immediate;  
   end
   
   	// additional code
	
	reg [31:0] COM_input1, COM_input2;
	
    always @(*)
        case(fwd_A_in)
            2'b10 : COM_input1 = mem_data;
            2'b01 : COM_input1 = WriteData;
            default : COM_input1 = Reg[Rs1];
        endcase
		
    always @(*)        
        case(fwd_B_in)
            2'b10 : COM_input2 = mem_data;
            2'b01 : COM_input2 = WriteData;
            default : COM_input2 = Reg[Rs2];
        endcase	
	
    wire [31:0] COM_input1_test = COM_input1 >> 2;
	always @(*) begin
		if(jalr) 
			PCimm_out = COM_input1 + (Immediate << 1);
		else 
			PCimm_out = PC_in + (Immediate << 1);
	end
	
	
	always @(*) begin
		casex({opcode, func3})
			10'b1100111_xxx : PCSrc = 1'b1;							// jalr
			10'b1101111_xxx : PCSrc = 1'b1;							// jal 
			10'b1100011_000 : PCSrc = (COM_input1 == COM_input2) ? 1'b1 : 1'b0;		// beq 
			10'b1100011_001 : PCSrc = (COM_input1 != COM_input2) ? 1'b1 : 1'b0;		// bne 
			10'b1100011_100 : PCSrc = (COM_input1 <  COM_input2) ? 1'b1 : 1'b0;		// blt 
			10'b1100011_101 : PCSrc = (COM_input1 >= COM_input2) ? 1'b1 : 1'b0;		// bge 
			default : PCSrc = 1'b0;
		endcase
	end
	
	wire [31:0] ind_test = PC_in >>2;
	wire [31:0] ind_PCimm_test = PCimm_out >> 2;
    
endmodule


