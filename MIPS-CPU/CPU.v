`timescale 1ns / 1ps

module CPU(CLK, START);

	input CLK, START;
	//PC and Instruction memory net
	wire [15:0] PC_In;
	wire [15:0] PC_Out;
	wire [25:0] Instr;
	
	//Register file net
	wire [2:0] RS_ID, RT_ID, RD_ID, Reg_W_ID;
	wire [15:0] Reg_RData1, Reg_RData2, Reg_WData;
	
	//Decoder(Control) net
	wire [5:0] OP;
	wire Reg_Dst;
	wire Jump;
	wire Branch;
	wire Mem_Read;
	wire Mem_to_Reg;
	wire [1:0] ALU_OP;
	wire Mem_Write;
	wire ALU_Src;	
	wire Reg_Write;
	
	//Sign-extend net
	wire [13:0] Immediate_In;
	wire [15:0] Extend_Sign;
	
	//ALU control net
	wire [5:0] Funct;
	wire [3:0] ALU_Ctrl_Out;
	
	//ALU net
	wire [15:0] ALU_Src1, ALU_Src2, ALU_Result;
	wire Zero;
	
	//Data memory net
	wire [15:0] DM_RData, DM_WData, Address;
	
	//MUXs net
	wire [15:0] MUX_Src2_to_ALU;
	wire [15:0] MUX_Mem_to_Reg_Out;
	wire [2:0]  MUX_Inst_to_Reg;
	wire [15:0] MUX_Branch_Out;
	wire [15:0] MUX_Jump_Out;
	wire [15:0] Jump_Address;
	
	//Adders net
	wire [15:0] PC_Count_Add_Src1, PC_Count_Add_Src2, PC_Count_Add_Result;
	wire [15:0] Branch_Add_Src1, Branch_Add_Src2, Branch_Add_Result;
	
	//Other net
	wire Branch_Select;

	//Old module
	PC i_PC(.CLK(CLK), .START(START), .PC_In(PC_In), .PC_Out(PC_Out));
	IM i_IM(.START(START), .PC(PC_Out), .Instr(Instr));
	Reg i_Reg(.CLK(CLK), .RS_ID(RS_ID), .RT_ID(RT_ID), .Reg_W_ID(Reg_W_ID), .Reg_Write(Reg_Write), .Reg_WData(Reg_WData), .Reg_RData1(Reg_RData1), .Reg_RData2(Reg_RData2));
	Decoder i_Decoder(.OP(OP), .Reg_Dst(Reg_Dst), .Jump(Jump), .Branch(Branch), .Mem_Read(Mem_Read), .Mem_to_Reg(Mem_to_Reg), .ALU_OP(ALU_OP), .Mem_Write(Mem_Write), .ALU_Src(ALU_Src), .Reg_Write(Reg_Write));
	sign_extend i_Sign_Extend(.Immediate_In(Immediate_In), .Sign_Extend(Extend_Sign));
	ALU_ctrl i_ALU_Ctrl(.Funct(Funct), .ALU_OP(ALU_OP), .ALU_Ctrl_Out(ALU_Ctrl_Out));
	ALU i_ALU(.Source1(ALU_Src1), .Source2(ALU_Src2), .ALU_Ctrl(ALU_Ctrl_Out), .Result(ALU_Result), .Zero(Zero));
	DM i_DM(.CLK(CLK), .Address(Address), .Mem_Write(Mem_Write), .Mem_Read(Mem_Read), .DM_WData(DM_WData), .DM_RData(DM_RData));
	MUX_2_to_1 #(.size(16))MUX_Mem_to_Reg(.data0_i(ALU_Result), .data1_i(DM_RData), .select_i(Mem_to_Reg), .data_o(MUX_Mem_to_Reg_Out));
	MUX_2_to_1 #(.size(3)) MUX_Reg_Dst(.data0_i(RT_ID), .data1_i(RD_ID), .select_i(Reg_Dst), .data_o(MUX_Inst_to_Reg));
	MUX_2_to_1 #(.size(16))MUX_ALUSrc(.data0_i(Reg_RData2), .data1_i(Extend_Sign), .select_i(ALU_Src), .data_o(MUX_Src2_to_ALU));
	
	//New module
	MUX_2_to_1 #(.size(16))MUX_Branch(.data0_i(PC_Count_Add_Result), .data1_i(Branch_Add_Result), .select_i(Branch_Select), .data_o(MUX_Branch_Out));
	MUX_2_to_1 #(.size(16))MUX_Jump(.data0_i(MUX_Branch_Out), .data1_i(Jump_Address), .select_i(Jump), .data_o(MUX_Jump_Out));
	Add PC_Count_Add(.Source1(PC_Count_Add_Src1), .Source2(PC_Count_Add_Src2), .Result(PC_Count_Add_Result));
	Add Branch_Add(.Source1(Branch_Add_Src1), .Source2(Branch_Add_Src2), .Result(Branch_Add_Result));
	
	//PC net assignment
	assign PC_In = MUX_Jump_Out;
	
	//Register file net assignment
	assign RS_ID = Instr[19:17];
	assign RT_ID = Instr[16:14];
	assign RD_ID = Instr[13:11];
	assign Reg_W_ID = MUX_Inst_to_Reg;
	assign Reg_WData = MUX_Mem_to_Reg_Out;
	
	//Decoder(Control) net assignment
	assign OP = Instr[25:20];
	
	//Sign-extend net assignment
	assign Immediate_In = Instr[13:0];
	
	//ALU control net assignment
	assign Funct = Instr[5:0];
	
	//ALU net assignment
	assign ALU_Src1 = Reg_RData1;
	assign ALU_Src2 = MUX_Src2_to_ALU;
	
	//Data memory net assignment
	assign DM_WData = Reg_RData2;
	assign Address = ALU_Result;
	
	//MUXs net assignment
	assign Jump_Address = Instr[15:0];
	//Adders net assignment
	assign PC_Count_Add_Src1 = PC_Out;
	assign PC_Count_Add_Src2 = 16'd1;
	assign Branch_Add_Src1 = PC_Out + 16'd1;
	assign Branch_Add_Src2 = Instr[13:0];
	
	//Other net assignment
	assign Branch_Select = (Branch == 1 && Zero == 1) ? 1 : 0;
	
endmodule

