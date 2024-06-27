`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 13:26:59
// Design Name: 
// Module Name: LED_channel
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


module LED_channel(
	input [31:0] data,
	input [2:0] LED_clk,
	output reg [7:0] digit,
	output reg [7:0] fnd
    );
    reg [3:0] segment;
	always@(*) begin
		case(segment)
          4'b0001 : fnd = ~8'b01111001;   // 1
          4'b0010 : fnd = ~8'b00100100;   // 2
          4'b0011 : fnd = ~8'b00110000;   // 3
          4'b0100 : fnd = ~8'b00011001;   // 4
          4'b0101 : fnd = ~8'b00010010;   // 5
          4'b0110 : fnd = ~8'b00000010;   // 6
          4'b0111 : fnd = ~8'b01111000;   // 7
          4'b1000 : fnd = ~8'b00000000;   // 8
          4'b1001 : fnd = ~8'b00010000;   // 9 
          4'b1010 : fnd = ~8'b00001000;   // A
          4'b1011 : fnd = ~8'b00000011;   // b
          4'b1100 : fnd = ~8'b01000110;   // C
          4'b1101 : fnd = ~8'b00100001;   // d
          4'b1110 : fnd = ~8'b00000110;   // E
          4'b1111 : fnd = ~8'b00001110;   // F
          default : fnd = ~8'b01000000;   // 0
		endcase
	end

	always@(*) begin
	   case(LED_clk)
	   	3'b000 : begin
	   		digit = 8'b0000_0001;
			segment = data[3:0];
		end
		3'b001 : begin
	   		digit = 8'b0000_0010;
			segment = data[7:4];
		end
		3'b010 : begin
	   		digit = 8'b0000_0100;
			segment = data[11:8];
		end
		3'b011 : begin
	   		digit = 8'b0000_1000;
			segment = data[15:12];
		end
		3'b100 : begin
	   		digit = 8'b0001_0000;
			segment = data[19:16];
		end
		3'b101 : begin
	   		digit = 8'b0010_0000;
			segment = data[23:20];
		end
		3'b110 : begin
	   		digit = 8'b0100_0000;
			segment = data[27:24];
		end
		3'b111 : begin
	   		digit = 8'b1000_0000;
			segment = data[31:28];
		end
		default : begin
	   		digit = 8'b1111_1111;
			segment = 4'b1111;
		end
	   endcase
	end
endmodule
