`include "constant.vh"

class Golden_ID;

    function new();
    endfunction //new()

    function bit isALU_CAL(bit [15:0] inst);
        return (inst[15:13] == ALU_CAL) && (inst[1:0] != 2'b11) && ({inst[12:11],inst[1:0]} != {BIM_SHIFT, 2'b10}) && ({inst[12:11],inst[1:0]} != {BIN_SHIFT_IMM, 2'b10});
    endfunction

    function bit isALU_IMM(bit [15:0] inst);
        return (inst[15:13] == ALU_IMM);
    endfunction

    function bit isBRANCH(bit [15:0] inst);
        return (inst[15:13] == BRANCH) && (inst[12:11] != 2'b11);
    endfunction

    function bit isBRANCH_JUMP(bit [15:0] inst);
        return (inst[15:11] == {BRANCH_JUMP, JAL}) && (inst[12:11] == 2'b00);
    endfunction

    function bit[2:0] o_addr_0(bit [15:0] inst);
        if(this.isALU_CAL(inst)|| this.isALU_IMM(inst) || this.isBRANCH(inst) || this.DM_r_en(inst) || this.DM_w_en(inst)) begin
            return inst[7:5];
        end
        return 0;
    endfunction

    function bit[2:0] o_addr_1(bit [15:0] inst);
        if(
            (this.isALU_CAL(inst) && (inst[12:11] != BIN_SHIFT_IMM)) ||
            this.isBRANCH(inst) || this.DM_w_en(inst)
        ) begin
            return inst[4:2];
        end
        return 0;
    endfunction

    function bit[2:0] o_w_addr(bit [15:0] inst);
        if(this.isALU_CAL(inst)|| this.isALU_IMM(inst) || this.isBRANCH_JUMP(inst) || this.DM_r_en(inst)) begin
            return inst[10:8];
        end
        return 0;    
        
    endfunction

    function bit[7:0] imm(bit [15:0] inst);
        if(isALU_CAL(inst) && inst[12:11] == BIN_SHIFT_IMM)
            return {5'b00000, inst[4:2]};
        if(isALU_IMM(inst))
            return {3'b000, inst[4:0]};
        if(isBRANCH(inst))
            return (inst[10] == 1? {3'b111, inst[10:8], inst[ 1:0]} : {3'b000, inst[10:8], inst[ 1:0]});
        if(this.is_jal(inst))
            return {inst[7:0]};
        if(this.DM_r_en(inst))
            return {3'b000, inst[4:0]};
        if(this.DM_w_en(inst))
            return {3'b000, inst[10:8], inst[1:0]};
        return 0;
    endfunction

    function bit[6:0] ALU_OP(bit [15:0] inst);
        return {inst[15:11], inst[1:0]};
    endfunction

    function bit Branch(bit [15:0] inst);
        return (inst[15:11] == {BRANCH, BEQ}) || 
            (inst[15:11] == {BRANCH, BLT}) || 
            (inst[15:11] == {BRANCH, BNE}) || 
            this.is_jal(inst);
    endfunction

    function bit Mem2Reg(bit [15:0] inst);
        return this.DM_r_en(inst);
    endfunction

    function bit ALUSrc(bit [15:0] inst);
        return this.isALU_IMM(inst) || 
        (this.isALU_CAL(inst) && inst[12:11] == BIN_SHIFT_IMM);

        
    endfunction

    function bit RF_w_en(bit [15:0] inst);
        return this.isALU_CAL(inst) || this.isALU_IMM(inst) || this.is_jal(inst) || this.DM_r_en(inst);
    endfunction

    function bit DM_w_en(bit [15:0] inst);
        return inst[15:11] == {DM_FUN, SD};
    endfunction

    function bit DM_r_en(bit [15:0] inst);
        return inst[15:11] == {DM_FUN, LD};
    endfunction

    function bit is_jal(bit [15:0] inst);
        return inst[15:11] == {BRANCH_JUMP,JAL};
    endfunction
endclass //ID