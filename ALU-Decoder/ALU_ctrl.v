`timescale 1ns / 1ps

module ALU_ctrl( funct, ALU_OP,ALU_CTRL );

	input [5:0] funct;
	input [1:0] ALU_OP;
	output [3:0]ALU_CTRL;
   
	wire [3:0]ALU_CTRL;
	
	/* add your design */
	assign ALU_CTRL = ({ALU_OP,funct}==8'b10_100000)?4'b0010://add
				({ALU_OP,funct}==8'b10_100010)?4'b1010://sub
				({ALU_OP,funct}==8'b10_101010)?4'b1011:4'b0000;//slt,default:0
	


endmodule
