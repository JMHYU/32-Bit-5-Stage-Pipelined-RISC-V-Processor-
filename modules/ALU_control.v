`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 13:16:43
// Design Name: 
// Module Name: ALU_control
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


module ALU_control(
    input [1:0] ALUop,
    input [6:0] funct7,
    input [2:0] funct3,
    output reg [3:0] ALU_ctl
    ); 
    
    always @(*) begin
        casex({ALUop, funct3, funct7})
            12'b00_xxx_xxxxxxx : ALU_ctl = 4'b0010; // load, store
            12'b01_000_xxxxxxx : ALU_ctl = 4'b0110; // beq
            12'b01_001_xxxxxxx : ALU_ctl = 4'b1111; // bne : beq는 substract로도 구현할 수 있으나, bne는 그렇지 않다.
            12'b01_100_xxxxxxx : ALU_ctl = 4'b0111; // blt
            12'b01_101_xxxxxxx : ALU_ctl = 4'b1000; // bge
            12'b10_000_0000000 : ALU_ctl = 4'b0010; //add
            12'b10_000_0100000 : ALU_ctl = 4'b0110; //sub
            12'b10_111_0000000 : ALU_ctl = 4'b0000; // and
            12'b10_110_0000000 : ALU_ctl = 4'b0001; // or
            12'b10_001_0000000 : ALU_ctl = 4'b1001; // sll
            12'b10_101_0000000 : ALU_ctl = 4'b1010; // srl
            12'b11_000_xxxxxxx : ALU_ctl = 4'b0010; // addi, jalr 
            12'b11_111_xxxxxxx : ALU_ctl = 4'b0000; // andi
            12'b11_001_xxxxxxx : ALU_ctl = 4'b1001; // slli
            12'b11_101_xxxxxxx : ALU_ctl = 4'b1010; // srli
            default : ALU_ctl = 4'bx;
        endcase
    end
endmodule

