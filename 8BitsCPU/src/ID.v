module ID(
    input       [15:0] inst,
    output      [ 2:0] o_addr_0,
    output      [ 2:0] o_addr_1,
    output      [ 2:0] o_w_addr,
    output      [ 7:0] imm,
    output      [ 6:0] ALU_OP,
    output             Branch,
    output             Mem2Reg,
    output             ALUSrc,
    output             RF_w_en,
    output             DM_w_en,
    output             DM_r_en,
    output             is_jal
);
 `include "constant.vh"
reg [2:0] cur_inst;
assign ALU_OP = {inst[15:11], inst[1:0]};

//o_addr_0
always @(*) begin
    case(inst[15:13])
        ALU_CAL    : cur_inst <= ALU_CAL    ;  
        ALU_IMM    : cur_inst <= ALU_IMM    ; 
        BRANCH     : cur_inst <= BRANCH     ;
        BRANCH_JUMP: cur_inst <= BRANCH_JUMP;
        DM_FUN     : cur_inst <= DM_FUN;
        default: cur_inst <= ILLEGAL_FUN;
    endcase
end

assign o_addr_0 = ( cur_inst == ALU_CAL     |
                    cur_inst == ALU_IMM     |
                    cur_inst == BRANCH      |
                    cur_inst == BRANCH_JUMP 
                    )? inst[7:5] : 0;

//o_addr_1
assign o_addr_1 = ((cur_inst == ALU_CAL & (inst[12:11]!= BIN_SHIFT_IMM)) | 
                    cur_inst == BRANCH |
                    cur_inst == DM_FUN & (inst[12:11] == SD)
                    )? inst[4:2] : 0;

assign o_w_addr = ( cur_inst == ALU_CAL | 
                    cur_inst == ALU_IMM | 
                    cur_inst == BRANCH_JUMP | 
                    cur_inst == DM_FUN & (inst[12:11] == LD))? 
                    inst[10:8] : 0;

//imm part
assign imm =(cur_inst == ALU_CAL & (inst[12:11] == BIN_SHIFT_IMM))? {5'b00000 ,inst[4:2]} : 
            (cur_inst == ALU_IMM )?      {3'b000, inst[ 4:0]}:
            (cur_inst == BRANCH )?       {3'b000, inst[10:8], inst[ 1:0]}:
            (cur_inst == BRANCH_JUMP )?  inst[ 7:0]:
            (cur_inst == DM_FUN & (inst[12:11] == LD))? inst[ 7:0]:
            (cur_inst == DM_FUN & (inst[12:11] == SD))? {inst[10:5], inst[1:0]}:
            0;
//RF_w_en
assign RF_w_en = (  cur_inst == ALU_CAL| 
                    cur_inst == ALU_IMM |
                    cur_inst == BRANCH_JUMP|
                    (cur_inst == DM_FUN & inst[12:11] == LD));
//ALUSrc
assign ALUSrc = (cur_inst == ALU_CAL)? (inst[12:11] == BIN_SHIFT_IMM) :
                (cur_inst == ALU_IMM)? 1:
                0;

assign Branch   = (cur_inst == BRANCH | cur_inst == BRANCH_JUMP);
assign Mem2Reg  = (cur_inst == DM_FUN & inst[12:11] == LD);
assign DM_w_en  = (cur_inst == DM_FUN & inst[12:11] == SD);
assign DM_r_en  = (cur_inst == DM_FUN & inst[12:11] == LD);
assign is_jal   = (cur_inst == BRANCH_JUMP);
endmodule

