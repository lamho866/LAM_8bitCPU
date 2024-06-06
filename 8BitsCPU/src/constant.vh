
`ifndef FUN_CODE
    `define FUN_CODE
    parameter ALU_CAL       = 3'b000;  
    parameter ALU_IMM       = 3'b001; 
    parameter BRANCH        = 3'b010;
    parameter BRANCH_JUMP   = 3'b011;
    parameter DM_FUN        = 3'b100;

    parameter ILLEGAL_FUN   = 3'b111;
`endif


`ifndef ALU_CAL_CODE
    `define ALU_CAL_CODE
    parameter NUM_CAL       = 2'b00; 
    parameter BIN_CAL       = 2'b01; 
    parameter BIM_SHIFT     = 2'b10;
    parameter BIN_SHIFT_IMM = 2'b11;

    //NUM_CAL
    parameter ADD = 2'b00;
    parameter SUB = 2'b01;
    parameter MUL = 2'b10;
    //BIN_CAL
    parameter AND = 2'b00;
    parameter OR  = 2'b01;
    parameter XOR = 2'b10;
    //BIM_SHIFT
    parameter SLL = 2'b00;
    parameter SRL = 2'b01;
    //BIN_SHIFT_IMM
    parameter SLLI = 2'b00;
    parameter SRLI = 2'b01;
`endif

`ifndef ALU_IMM_CODE
    `define ALU_IMM_CODE
    parameter ANDI  = 2'b00; 
    parameter ORI   = 2'b01; 
    parameter XORI  = 2'b10;
    parameter ADDI  = 2'b11; 
`endif

`ifndef BRANCH_CODE
    `define BRANCH_CODE
    parameter BEQ  = 2'b00; 
    parameter BLT  = 2'b01; 
    parameter BNE  = 2'b10;
`endif

`ifndef JUMP_CODE
    `define JUMP_CODE
    parameter JAL  = 2'b00; 
`endif

`ifndef DM_CODE
    `define DM_CODE
    parameter LD  = 2'b00; 
    parameter SD  = 2'b01; 
`endif
