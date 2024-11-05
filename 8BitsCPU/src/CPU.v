// `include "ALU.v"
// `include "DM.v"
// `include "ID.v"
// `include "IM.v"
// `include "PC.v"
// `include "RF.v"

module CPU(
    input               clk,
    input               rst,
    input               isReg, //is read reg or DM
    input       [7:0]   i_inst,
    input       [7:0]   i_cpu_addr,
    output      [7:0]   o_CPU_data,
    output              o_is_done
);

//CPU control part
wire [7:0] o_CPU_RF_data, o_CPU_DM_data;
assign o_CPU_data = isReg? o_CPU_RF_data : o_CPU_DM_data;

wire val_CPU_Addr[7:0];
//CPU_state_control
wire  inCmd, is;

//PC_OUTPUT
wire [7:0] PC_wire;

//IM_OUTPUT
wire [7:0] i_ID_addr;
wire [15:0] IM2ID_inst;

assign i_ID_addr = (inCmd)? i_cpu_addr : PC_wire;

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
assign PC_ADD_HALFWORDS = PC_wire + 16'h0002;
assign PC_ADD           = (PCSrc)? PC_BRANCH : PC_ADD_HALFWORDS; 

wire [7:0] RF_w_data;
assign RF_w_data =  (mem2Reg)? DM_o_DM_data :
                    ( is_jal)? PC_ADD_HALFWORDS: 
                    ALU_o_ALU;

wire [7:0] ALU_data_1_in;
assign ALU_data_1_in = (ALUSrc)? ID_imm : RF_r_data_1;

wire [7:0] DM_addr;
assign DM_addr = ID_imm + RF_r_data_0;

//------------------------------------------------

CPU_State_Control CPU_State_Control(
    .clk(clk),
    .rst(rst),
    .IM_inst(IM2ID_inst),
    .i_inst(i_inst),
    .inCmd(inCmd),
    .o_is_done(o_is_done)
);

PC PC(
    .clk(clk),
    .rst(rst),
    .inCmd(inCmd),
    .PC_ADD(PC_ADD),
    .i_is_done(o_is_done),
    .o_PC(PC_wire)
);

IM IM(
    .clk(clk),
    .rst(rst),
    .inCmd(inCmd),
    .i_inst(i_inst),
    .i_addr(i_ID_addr),
    .o_inst(IM2ID_inst)
);

ID ID(
    .inst(IM2ID_inst),
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
    .i_CPU_RF_addr(i_cpu_addr[2:0]),
    .r_addr_0(ID2RF_o_addr_0),
    .r_addr_1(ID2RF_o_addr_1),
    .w_addr(ID2RF_w_addr),
    .w_data(RF_w_data),
    .o_CPU_RF_data(o_CPU_RF_data),
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
    .i_CPU_DM_addr(i_cpu_addr),
    .addr(DM_addr),
    .DM_w_data(RF_r_data_1),
    .o_CPU_DM_data(o_CPU_DM_data),
    .o_DM_data(DM_o_DM_data)  
);

    // initial begin
    //     $dumpfile("CPU.vcd");  // Specify the dump file
    //     $dumpvars(0, CPU); // Dump all variables in the testbench
    // end

endmodule
