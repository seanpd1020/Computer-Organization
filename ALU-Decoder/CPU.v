`timescale 1ns / 1ps

module CPU(CLK, START);

	input CLK, START;
	wire [15:0] PC;
	wire [25:0] Instr;
	wire [5:0] OP;
	
	wire [2:0] RS_ID, RT_ID , RD_ID;
	wire [15:0] Reg_RData1, Reg_RData2, Reg_WData;
	wire Reg_WE;
	
	wire [15:0] DM_RData, DM_WData ;
	wire DM_WE;
	
	wire [15:0] address;
	wire [13:0] immediate_in;
	
	wire [5:0] funct;
	
	wire [1:0] ALU_OP;
	wire [3:0] ALU_CTRL;
	
	wire [15:0] ALU_result;
	wire [15:0] extend_sign;
	
	wire [15:0] Mux_to_ALU;
	wire ALU_src;
	wire MEM_to_REG;
	wire REG_Dst;
	
	wire [2:0] REG_W_ID;
	
	wire [15:0] ALU_src1,ALU_src2;
	wire [15:0] Mux_Mem_to_reg_out;
	
	
	
	PC i_PC(.CLK(CLK), .START(START), .PC(PC));
	IM i_IM(.START(START), .PC(PC), .Instr(Instr));
	Reg i_Reg(.CLK(CLK), .RS_ID(RS_ID), .RT_ID(RT_ID),  .REG_W_ID(REG_W_ID) ,.Reg_WE(Reg_WE), .Reg_RData1(Reg_RData1), .Reg_RData2(Reg_RData2), .Reg_WData(Reg_WData) );
	
	
	
	Decoder i_Decoder(.OP(OP), .Reg_WE(Reg_WE), .DM_WE(DM_WE) , .ALU_OP(ALU_OP) , .ALU_src(ALU_src) , .MEM_to_REG(MEM_to_REG) , .REG_Dst(REG_Dst) ,.funct(funct));
	
	MUX_2_to_1 #(.size(3))MUX_REG_Dst(.data0_i(RT_ID),.data1_i(RD_ID),.select_i(REG_Dst),.data_o(REG_W_ID));
	
	sign_extend i_sign_extend(.immediate_in(immediate_in),.sign_extend(extend_sign));
	
	MUX_2_to_1 #(.size(16))MUX_ALUsrc(.data0_i(Reg_RData2),.data1_i(extend_sign),.select_i(ALU_src),.data_o(Mux_to_ALU));
	
	
	ALU_ctrl i_ALU_ctrl(.funct(funct),.ALU_OP(ALU_OP),.ALU_CTRL(ALU_CTRL));
	
	ALU i_ALU(.source1(Reg_RData1),.source2(Reg_RData2),.ALU_CTRL(ALU_CTRL),.result(ALU_result));
	
	DM i_DM(.CLK(CLK), .address(ALU_result), .DM_WE(DM_WE), .DM_RData(DM_RData), .DM_WData(DM_WData) );
	
	MUX_2_to_1 #(.size(16))MUX_MEM_to_REG(.data0_i(ALU_result),.data1_i(DM_RData),.select_i(MEM_to_REG),.data_o(Mux_Mem_to_reg_out));
	
	assign OP = Instr[25:20];
	assign RS_ID = Instr[19:17];
	assign RT_ID = Instr[16:14];
	assign RD_ID = Instr[13:11];
	assign DM_WData = Reg_RData2; 
	assign immediate_in = Instr[13:0];
	assign funct = Instr[5:0];
	assign ALU_src1 = Instr[19:17];
	assign ALU_src2 = Instr[16:14];
	assign Reg_WData = (MEM_to_REG == 0)?ALU_result:DM_WData;
	/*add your code here*/
	
	
	
endmodule
