`timescale 1ns / 1ps

module Decoder( OP, Reg_WE, DM_WE, ALU_OP, ALU_src,MEM_to_REG,REG_Dst,funct);
	input [5:0] OP;
	input [5:0] funct;
	output Reg_WE, DM_WE, ALU_src,MEM_to_REG,REG_Dst;
	output [1:0] ALU_OP;
	
	wire Reg_WE, DM_WE, ALU_src,MEM_to_REG,REG_Dst;
	wire [1:0] ALU_OP;
	/* add your design */   	
	assign Reg_WE = (OP == 6'b000000)?1:0;
	assign DM_WE = (OP == 6'b100011 || OP == 6'b101011)?1:0;
	assign ALU_src = (OP == 6'b000000)?0:1;
	assign ALU_OP = (OP == 6'b000000)?2'b10:2'b00;
	assign REG_Dst = (OP == 6'b000000)?1:0;
	assign MEM_to_REG = (OP == 6'b000000)?0:1;
	
	
	
	
endmodule
