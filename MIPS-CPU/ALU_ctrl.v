`timescale 1ns / 1ps

module ALU_ctrl(Funct, ALU_OP, ALU_Ctrl_Out);

    	input [5:0] Funct;
	input [1:0] ALU_OP;
    	output [3:0] ALU_Ctrl_Out;
	wire [3:0]ALU_Ctrl_Out;
	////  ALUOP  ////   ////  Function  ////
	//  R-type 10  //   //   add 100000   //
	//  beq    01  //   //   sub 100010   //
	//  else   00  //   //   slt 101010   //
	/////////////////   ////////////////////
	
	///  ALUOP  Function  ALU_Ctrl  ///
	//    10     000000     0000     //
	//    10     100000     0010     //
	//    10     100010     0110     //
	//    10     101010     0111     //
	//    01     XXXXXX     0110     //
	//    00     XXXXXX     0010     //
	///////////////////////////////////
	
	/* add your code here */
	assign ALU_Ctrl_Out = ({ALU_OP,Funct}==8'b10_000000)?4'b0000://nothing
			({ALU_OP,Funct}==8'b10_100000)?4'b0010://add
			({ALU_OP,Funct}==8'b10_100010)?4'b0110://sub
			({ALU_OP,Funct}==8'b10_101010)?4'b0111://slt
			(ALU_OP==2'b01)?4'b0110://beq
			(ALU_OP==2'b00)?4'b0010:4'b0000;//lw,sw,default:0
	
endmodule
