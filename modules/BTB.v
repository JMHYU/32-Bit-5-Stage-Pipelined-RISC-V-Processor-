`timescale 1ns / 1ps

module BTB(
	input 		  i_clk, i_rst,
	input 	 	  ind_Ctl_branch_in,
	input		  hz_stall,
	input  [31:0] IF_PC_in, IND_PC_in, PCimm_in,
	input 		   PCSrc,
	output reg    MISS,
	output [1:0]  predict,
	output [31:0] target,
	output [33:0] IND_PC_PASS
);
    parameter  ST_NOT_TAKEN = 2'b01,
			   LK_NOT_TAKEN = 2'b00,
               LK_TAKEN = 2'b10,
               ST_TAKEN = 2'b11,
               BTB_SIZE = 10,
               MAP_BIT_SIZE = 4;
	
	wire 		new_branch;
	reg  [3 :0] count;
	wire [4 :0] IND_tag, IF_tag;
	reg  [4 :0] tag;
	wire [33:0] IF_info, IND_info;
	reg  [33:0] info;
	reg  [MAP_BIT_SIZE :0] MAP[0:60];
	reg  [33:0] BTB[0:BTB_SIZE];
	
	
	assign IND_tag    = MAP[IND_PC_in>>2];
	assign IF_tag 	  = MAP[IF_PC_in>>2];
	assign new_branch = (ind_Ctl_branch_in) && (IND_tag[4] == 1'b0); // branch인데, 아직 기록이 안 된 것일 경우
	assign IND_info   = (IND_tag[4]) ? BTB[IND_tag[3:0]] : 33'b0;	
	assign IF_info    = (IF_tag[4])  ? BTB[IF_tag[3:0]]  : 33'b0;

	assign {predict, target} = IF_tag[4] ? IF_info : 0; // MAPPING이 되어 있는 명령어만 제대로 내보낸다.
	wire [31:0] target_test = target >> 2;
	
	// count logic(= BTB index)
	always @(posedge i_clk) begin
		if(i_rst)
			count <= 0;
		else if( (!hz_stall) && new_branch ) // stall이 발생하면, PC reg, IF/ID reg 모두 정지.
			count <= count + 1'b1;
	end
	

	// prediction FSM 생성
	reg  [1 :0] next_state;
	wire [1 :0] state;
	wire [31:0] s_target;
	assign {state, s_target} = IND_info;
	always @(*) begin
		case(state)
			ST_TAKEN 	  : next_state = (PCSrc) ? ST_TAKEN 	 :  LK_TAKEN; 
			LK_TAKEN 	  : next_state = (PCSrc) ? ST_TAKEN 	 :  LK_NOT_TAKEN;			
			ST_NOT_TAKEN  : next_state = (PCSrc) ? LK_NOT_TAKEN  :  ST_NOT_TAKEN;
			LK_NOT_TAKEN  : next_state = (PCSrc) ? LK_TAKEN 	 :  ST_NOT_TAKEN;
			default 	  : next_state = LK_NOT_TAKEN;
		endcase
	end


	always @(*) begin
	   if(new_branch && PCSrc)
	       MISS = 1'b1;
	   else
	       MISS = ind_Ctl_branch_in && ( {state[1], s_target} != {PCSrc, PCimm_in} );
	end	 
	
	assign IND_PC_PASS = {PCSrc, PCimm_in};
	
	
	// MAP BRAM 생성
	always @(posedge i_clk) begin
		if(!hz_stall && new_branch)
			MAP[(IND_PC_in >> 2)] <= {1'b1, count}; 
		if(i_rst)
			tag <= 4'b0;
		else 
			tag <= MAP[(IND_PC_in >> 2)];
	end
	
	// MAP initialize
	initial begin
        $readmemh("BTBMAP.mem", MAP);
    end
	
	// BTB BRAM 생성
	always @(posedge i_clk) begin
		if(!hz_stall && new_branch)
			BTB[count] <= {PCSrc, 1'b0, PCimm_in};
		else if(ind_Ctl_branch_in)
			BTB[IND_tag[3:0]] <= {next_state, PCimm_in};
		if(i_rst)
			info <= 32'b0;
		else
			info <= BTB[IF_tag[3:0]];
	end

endmodule
