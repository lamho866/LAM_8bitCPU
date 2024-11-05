`timescale 1ns/1ps
`include "Golden_ID.svh"

module tv_ID;

//IM_INPUT
logic [15:0] IM2DM_inst;

//ID_OUTPUT
logic [2:0] o_addr_0, o_addr_1, o_w_addr;  
logic [7:0] ID_imm;
logic [6:0] ALU_OP;
logic branch, mem2Reg, ALUSrc, RF_w_en, DM_w_en, DM_r_en, is_jal;
Golden_ID ID_Golden;

ID ID(
    .inst(IM2DM_inst),
    .o_addr_0(o_addr_0),
    .o_addr_1(o_addr_1),
    .o_w_addr(o_w_addr),
    .imm(ID_imm),
    .ALU_OP(ALU_OP),
    .Branch(branch),
    .Mem2Reg(mem2Reg),
    .ALUSrc(ALUSrc),
    .RF_w_en(RF_w_en),
    .DM_w_en(DM_w_en),
    .DM_r_en(DM_r_en),
    .is_jal(is_jal)
);

function void ID_Print_Output();
$display("o_addr_0: %03b, o_addr_1: %03b, o_w_addr: %03b,\nID_imm: %08b, ALU_OP: %08b,\nbranch: %0b, mem2Reg: %0b, ALUSrc: %0b, RF_w_en: %0b, DM_w_en: %0b, DM_r_en: %0b, is_jal: %0b", 
    o_addr_0, o_addr_1, o_w_addr, ID_imm, ALU_OP, branch, mem2Reg, ALUSrc, RF_w_en, DM_w_en, DM_r_en, is_jal
);

endfunction;

function Checker_ScoreBoard(bit [15:0] inst);
    $display("time: %010t | inst: %016b", $time, inst);
    // ID_Print_Output();
    if(o_addr_0 != ID_Golden.o_addr_0(inst)) $error("o_addr_0 Wrong Value: %b | %b", o_addr_0, ID_Golden.o_addr_0(inst));
    if(o_addr_1 != ID_Golden.o_addr_1(inst)) $error("o_addr_1 Wrong Value: %b | %b", o_addr_1, ID_Golden.o_addr_1(inst));
    if(o_w_addr != ID_Golden.o_w_addr(inst)) $error("o_w_addr Wrong Value: %b | %b", o_w_addr, ID_Golden.o_w_addr(inst));
    if(ID_imm != ID_Golden.imm(inst)) $error("imm Wrong Value: %b | %b", ID_imm, ID_Golden.imm(inst));
    if(ALU_OP != ID_Golden.ALU_OP(inst)) $error("ALU_OP Wrong Value: %b | %b", ALU_OP, ID_Golden.ALU_OP(inst));
    if(branch != ID_Golden.Branch(inst)) $error("Branch Wrong Value: %b | %b", branch, ID_Golden.Branch(inst));
    if(mem2Reg != ID_Golden.Mem2Reg(inst)) $error("Mem2Reg Wrong Value: %b | %b", mem2Reg, ID_Golden.Mem2Reg(inst));
    if(ALUSrc != ID_Golden.ALUSrc(inst)) $error("ALUSrc Wrong Value: %b | %b", ALUSrc, ID_Golden.ALUSrc(inst));
    if(RF_w_en != ID_Golden.RF_w_en(inst)) $error("RF_w_en Wrong Value: %b | %b", RF_w_en, ID_Golden.RF_w_en(inst));
    if(DM_w_en != ID_Golden.DM_w_en(inst)) $error("DM_w_en Wrong Value: %b | %b", DM_w_en, ID_Golden.DM_w_en(inst));
    if(DM_r_en != ID_Golden.DM_r_en(inst)) $error("DM_r_en Wrong Value: %b | %b", DM_r_en, ID_Golden.DM_r_en(inst));
    if(is_jal != ID_Golden.is_jal(inst)) $error("is_jal Wrong Value: %b | %b", is_jal, ID_Golden.is_jal(inst));
    $display("----------------------------------");
endfunction

function IllegaCode_ScoreBoard(bit [15:0] inst);
    $display("IllegalCode Check");
    $display("time: %010t | inst: %016b", $time, inst);
    // ID_Print_Output();
    if(o_addr_0 != 0) $error("o_addr_0 Wrong Value: %b | 0", o_addr_0);
    if(o_addr_1 != 0) $error("o_addr_1 Wrong Value: %b | 0", o_addr_1);
    if(o_w_addr != 0) $error("o_w_addr Wrong Value: %b | 0", o_w_addr);
    if(ID_imm != 0) $error("imm Wrong Value: %b | 0", ID_imm);
    // if(ALU_OP != 0) $error("ALU_OP Wrong Value: %b | %b", ALU_OP, ID_Golden.ALU_OP(inst));
    if(branch != 0) $error("Branch Wrong Value: %b | 0", branch);
    if(mem2Reg != 0) $error("Mem2Reg Wrong Value: %b | 0", mem2Reg);
    if(ALUSrc != 0) $error("ALUSrc Wrong Value: %b | 0", ALUSrc);
    if(RF_w_en != 0) $error("RF_w_en Wrong Value: %b | 0", RF_w_en);
    if(DM_w_en != 0) $error("DM_w_en Wrong Value: %b | 0", DM_w_en);
    if(DM_r_en != 0) $error("DM_r_en Wrong Value: %b | 0", DM_r_en);
    if(is_jal != 0) $error("is_jal Wrong Value: %b | 0", is_jal);
    $display("----------------------------------");
endfunction

task Check_cmd (bit [15:0] inst);
    IM2DM_inst = inst;
    #10;
    Checker_ScoreBoard(inst);
endtask //Check_cmd

task SimpleInst_Check();
    $display("ALU_CAL");
    Check_cmd(16'b000_00_011_000_001_00);
    Check_cmd(16'b000_00_011_000_001_00);
    Check_cmd(16'b000_00_011_000_001_01);
    Check_cmd(16'b000_00_011_000_001_10);

    Check_cmd(16'b000_01_011_000_001_00);
    Check_cmd(16'b000_01_011_000_001_01);
    Check_cmd(16'b000_01_011_000_001_10);

    Check_cmd(16'b000_10_011_000_001_00);
    Check_cmd(16'b000_10_011_000_001_01);

    Check_cmd(16'b000_11_011_000_100_00); //slli
    Check_cmd(16'b000_11_011_000_100_01); //slri
    
    //ALU_IMM
    $display("ALU_IMM");
    Check_cmd(16'b001_00_011_000_01010);
    Check_cmd(16'b001_01_011_000_01010);
    Check_cmd(16'b001_10_011_000_01010);
    Check_cmd(16'b001_11_011_000_01010);
    
    //BRANCH
    $display("BRANCH");
    Check_cmd(16'b010_00_010_000_001_10);
    Check_cmd(16'b010_01_010_000_001_10);
    Check_cmd(16'b010_10_010_000_001_10);

    //JAL
    $display("JAL");
    Check_cmd(16'b011_00_011_00001010);
    
    //LD, SD
    $display("LD, SD");
    Check_cmd(16'b100_00_011_010_01010); //LD
    Check_cmd(16'b100_01_010_011_010_10); //SD
endtask;

task Check_Illegal_cmd(bit [15:0] inst);
    IM2DM_inst = inst;
    #10;
    IllegaCode_ScoreBoard(inst);    
endtask;

task Illegal_cmdFixed_Random(bit[4:0] head);
    bit [15:0] RandomCmd;
    RandomCmd = $urandom_range(16'hFFFF, 0);
    RandomCmd[15:11] = head;
    Check_Illegal_cmd(RandomCmd);
endtask

task Illegal_cmdFixed_Random_OPCode000(bit[4:0] head, bit [1:0]tail);
    bit [15:0] RandomCmd;
    RandomCmd = $urandom_range(16'hFFFF, 0);
    RandomCmd[15:11] = head;
    RandomCmd[1:0] = tail;
    Check_Illegal_cmd(RandomCmd);
endtask

bit [4:0] head;
task Illegal_cmdList();
    Check_Illegal_cmd(16'hFFFF);

    // Fix in ALU
    Illegal_cmdFixed_Random_OPCode000(5'b000_00, 2'b11);
    Illegal_cmdFixed_Random_OPCode000(5'b000_01, 2'b11);
    Illegal_cmdFixed_Random_OPCode000(5'b000_10, 2'b10);
    Illegal_cmdFixed_Random_OPCode000(5'b000_10, 2'b11);
    Illegal_cmdFixed_Random_OPCode000(5'b000_11, 2'b10);
    Illegal_cmdFixed_Random_OPCode000(5'b000_11, 2'b11);


    Illegal_cmdFixed_Random(5'b010_11);

    Illegal_cmdFixed_Random(5'b011_01);
    Illegal_cmdFixed_Random(5'b011_10);
    Illegal_cmdFixed_Random(5'b011_11);
    
    Illegal_cmdFixed_Random(5'b100_10);
    Illegal_cmdFixed_Random(5'b100_11);

    //useless
    // head = 5'b10010;
    // for(int i = 18; i < 32; i = i + 1) begin
    //     Illegal_cmdFixed_Random(head);
    //     head = head + 1;
    // end
endtask;

task random_Check(int round);
    bit [15:0] RandomCmd;
    for(int i = 0; i < round; ++i) begin
        RandomCmd = $urandom_range(16'hFFFF, 0);
        Check_cmd(RandomCmd);
        #1;
    end
endtask

initial begin
    $display("Start");
    $display("----------------------------------");
    ID_Golden = new();

    SimpleInst_Check();
    Illegal_cmdList();
    random_Check(30000);
    $finish;
end
endmodule
