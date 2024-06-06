`timescale 1ns/1ps
module CPU(
    input clk,
    input rst
);

//PC_OUTPUT
wire [7:0] PC_wire;

//IM_OUTPUT
wire [15:0] IM2DM_inst;

//ID_OUTPUT
wire [2:0] ID2RF_o_addr_0, ID2RF_o_addr_1, ID2RF_w_addr;  
wire [7:0] ID_imm;
wire [6:0] ID2ALU_ALU_OP;
wire branch, mem2Reg, ALUSrc, RF_w_en, DM_w_en, DM_r_en, is_jal;

//RF_OUTPUT
wire [7:0] RF_r_data_0, RF_r_data_1;

//ALU_OUTPUT
wire [7:0] ALU_o_ALU;
wire B_PCSrc;

//DM_OUTPUT
wire [7:0] DM_o_DM_data;

//------------------------------------------------
wire [7:0] PC_ADD, PC_ADD_HALFWORDS, PC_BRANCH;
wire PCSrc;
assign PCSrc            = branch & B_PCSrc;
assign PC_BRANCH        = PC_wire + ID_imm;
assign PC_ADD_HALFWORDS = PC_wire + 1;
assign PC_ADD           = (PCSrc)? PC_BRANCH : PC_ADD_HALFWORDS; 

wire [7:0] RF_w_data;
assign RF_w_data =  (mem2Reg)? DM_o_DM_data :
                    ( is_jal)? PC_ADD_HALFWORDS: 
                    ALU_o_ALU;

wire [7:0] ALU_data_1_in;
assign ALU_data_1_in = (ALUSrc)? ID_imm : RF_r_data_1;

//------------------------------------------------
PC PC(
    .clk(clk),
    .rst(rst),
    .PC_ADD(PC_ADD),
    .o_PC(PC_wire)
);

IM IM(
    .clk(clk),
    .rst(rst),
    .PC_in(PC_wire),
    .inst(IM2DM_inst)
);

ID ID(
    .inst(IM2DM_inst),
    .o_addr_0(ID2RF_o_addr_0),
    .o_addr_1(ID2RF_o_addr_1),
    .o_w_addr(ID2RF_w_addr),
    .imm(ID_imm),
    .ALU_OP(ID2ALU_ALU_OP),
    .Branch(branch),
    .Mem2Reg(mem2Reg),
    .ALUSrc(ALUSrc),
    .RF_w_en(RF_w_en),
    .DM_w_en(DM_w_en),
    .DM_r_en(DM_r_en),
    .is_jal(is_jal)
);

RF RF(
    .clk(clk),
    .rst(rst),
    .RF_w_en(RF_w_en),
    .r_addr_0(ID2RF_o_addr_0),
    .r_addr_1(ID2RF_o_addr_1),
    .w_addr(ID2RF_w_addr),
    .w_data(RF_w_data),
    .o_r_data_0(RF_r_data_0),
    .o_r_data_1(RF_r_data_1)    
);

ALU ALU(
    .r0_data(RF_r_data_0),
    .r1_data(ALU_data_1_in),
    .ALU_OP(ID2ALU_ALU_OP),
    .B_PCSrc(B_PCSrc),
    .o_data(ALU_o_ALU)
);

DM DM(
    .clk(clk),
    .rst(rst),
    .DM_w_en(DM_w_en),
    .DM_r_en(DM_r_en),
    .addr(ID_imm),
    .DM_w_data(RF_r_data_1),
    .o_DM_data(DM_o_DM_data)  
);

    initial begin
        $dumpfile("CPU.vcd");  // Specify the dump file
        $dumpvars(0, CPU); // Dump all variables in the testbench
    end

endmodule
