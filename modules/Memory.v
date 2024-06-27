`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 13:18:41
// Design Name: 
// Module Name: Memory
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


module Memory(
    input               reset, clk,
    input               Ctl_MemtoReg_in, Ctl_RegWrite_in, Ctl_MemRead_in, Ctl_MemWrite_in, Ctl_Branch_in,
    output reg          Ctl_MemtoReg_out, Ctl_RegWrite_out,
    input      [4:0]    Rd_in,
    output reg [4:0]    Rd_out,
    input               jal_in, jalr_in,
    input               Zero_in,
    input      [31:0]   Write_Data, ALUresult_in, PC_in,
    
    output reg          jal_out, jalr_out,
    output reg  [31:0]  Read_Data, ALUresult_out, PC_out);
    


    parameter RAM_size = 1024;
    reg [31:0] RAM [0:RAM_size-1];
    
    initial begin
        $readmemh("darksocv.ram.mem", RAM);
    end
    
    always @(posedge clk) begin
        if (Ctl_MemWrite_in)
            RAM[ALUresult_in>>2] <= Write_Data;
        if(reset)
            Read_Data <= 0;
        else
            Read_Data <= RAM[ALUresult_in>>2];
    end
    
    always @ (posedge clk) begin
        Ctl_MemtoReg_out <= (reset) ? 1'b0 : Ctl_MemtoReg_in;
        Ctl_RegWrite_out <= (reset) ? 1'b0 : Ctl_RegWrite_in;
        Rd_out           <= (reset) ? 0 : Rd_in;
        ALUresult_out    <= (reset) ? 0 : ALUresult_in;
        jalr_out         <= (reset) ? 0 : jalr_in;
        jal_out          <= (reset) ? 0 : jal_in;
        PC_out           <= (reset) ? 0 : PC_in;
    end
    
endmodule
