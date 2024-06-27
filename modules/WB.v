`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 13:19:04
// Design Name: 
// Module Name: WB
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


module WB(
    input               Ctl_RegWrite_in, Ctl_MemtoReg_in,
    output reg          Ctl_RegWrite_out,
    input               jal_in, jalr_in,
    input      [31:0]   PC_in,
    input      [4:0]    Rd_in,
    input      [31:0]   ReadDatafromMem_in, ALUresult_in,
    output reg [4:0]    Rd_out,
    output reg [31:0]   WriteDatatoReg_out);
    
    always @(*) begin
        casex({Ctl_MemtoReg_in,(jalr_in || jal_in)})
           2'bx1 : WriteDatatoReg_out = PC_in + 4;
           2'b00 : WriteDatatoReg_out = ALUresult_in;
           2'b10 : WriteDatatoReg_out = ReadDatafromMem_in;
           default : WriteDatatoReg_out = 32'b0;
        endcase
        Rd_out = Rd_in;
        Ctl_RegWrite_out = Ctl_RegWrite_in;
    end
    
endmodule
