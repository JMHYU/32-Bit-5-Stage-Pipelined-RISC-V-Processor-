`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 13:28:29
// Design Name: 
// Module Name: tb_RISCVpipeline
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


module tb_RISCVpipeline();
    reg clk, rst, key;
    wire [ 7:0] digit;
	wire [ 7:0] fnd;
	wire [15:0] LED;
    
    
    RISCVpipeline u1(
    .key(key),
	.digit(digit),
	.fnd(fnd),
	.LED(LED),
	.clk(clk), .reset(rst)
    );
    
    initial begin
        key = 0;
        rst = 0;
        #54 rst = 1;
    end
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
endmodule

