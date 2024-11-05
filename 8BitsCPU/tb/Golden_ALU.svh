`include "constant.vh"
class Golden_ALU;
    function new();
    endfunction; //new()

    function bit[7:0] o_data(bit [6:0] ALU_OP, bit [7:0] r0_data, bit [7:0] r1_data);
        if(ALU_OP == {ALU_CAL, NUM_CAL,ADD})
            return r0_data + r1_data;
        if(ALU_OP == {ALU_CAL, NUM_CAL,SUB})
            return r0_data - r1_data;
        if(ALU_OP == {ALU_CAL, NUM_CAL,MUL})
            return r0_data * r1_data;

        if(ALU_OP == {ALU_CAL, BIN_CAL,AND})
            return r0_data & r1_data;
        if(ALU_OP == {ALU_CAL, BIN_CAL,OR})
            return r0_data | r1_data;
        if(ALU_OP == {ALU_CAL, BIN_CAL,XOR})
            return r0_data ^ r1_data;
        
        if(ALU_OP == {ALU_CAL, BIM_SHIFT, SLL})
            return r0_data << r1_data;
        if(ALU_OP == {ALU_CAL, BIM_SHIFT, SRL})
            return r0_data >> r1_data;

        if(ALU_OP == {ALU_CAL, BIN_SHIFT_IMM, SLLI})
            return r0_data << r1_data;
        if(ALU_OP == {ALU_CAL, BIN_SHIFT_IMM, SRLI})
            return r0_data >> r1_data;



        if(ALU_OP[6:2] == {ALU_IMM, ANDI})
            return r0_data & r1_data;
        if(ALU_OP[6:2] == {ALU_IMM, ORI})
            return r0_data | r1_data;        
        if(ALU_OP[6:2] == {ALU_IMM, XORI})
            return r0_data ^ r1_data;
        if(ALU_OP[6:2] == {ALU_IMM, ADDI})
            return r0_data + r1_data;  

        return 0;
    endfunction

    function bit B_PCSrc(bit [6:0] ALU_OP, bit [7:0] r0_data, bit [7:0] r1_data);
        if(ALU_OP[6:2] == {BRANCH, BEQ})
            return r0_data == r1_data;
        if(ALU_OP[6:2] == {BRANCH, BLT})
            return r0_data < r1_data;        
        if(ALU_OP[6:2] == {BRANCH, BNE})
            return r0_data != r1_data;
        if(ALU_OP[6:2] == {BRANCH_JUMP, JAL})
            return 1;
        return 0;
    endfunction
endclass //className
