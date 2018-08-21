`timescale 1ns / 1ps

module Reg(CLK, RS_ID, RT_ID, REG_W_ID, Reg_WE, Reg_RData1, Reg_RData2, Reg_WData );
	input CLK ;
	input [2:0] RS_ID, RT_ID , REG_W_ID;
	input Reg_WE;
	input [15:0] Reg_WData;
	output [15:0] Reg_RData1;
	output [15:0] Reg_RData2;
	reg signed [15:0] Register [0:7];
	
	/*add your code here*/
	wire [15:0] Reg_RData1;
	wire [15:0] Reg_RData2;	
	
	assign Reg_RData1 = Register[RS_ID];
	assign Reg_RData2 = Register[RT_ID];

	always@(posedge CLK) begin
		if( Reg_WE == 1 )
			Register[REG_W_ID] <= Reg_WData;
		else 
			Register[REG_W_ID] <= Register[REG_W_ID];
		
	end

endmodule
