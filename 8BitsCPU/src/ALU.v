module ALU (
    input       [7:0]       r0_data,
    input       [7:0]       r1_data,
    input       [6:0]       ALU_OP,
    output      reg         B_PCSrc,
    output      reg[7:0]    o_data
);
`include "constant.vh"
//ALU_OP
// 6:4 | 3:2 | 1:0|
//-----------------------
// FUN | OP  | OP |# ALU_CAL 
// FUN | OP  | DC | # otherwise 

// wire B_PCSrc;
// assign B_PCSrc = (ALU_OP[6:4] == BRANCH || ALU_OP[6:4] == BRANCH_JUMP)? B_PCSrc: 1'b0;

always @(*) begin
    B_PCSrc <= 0;
    o_data <= 0;
    case (ALU_OP[6:4])
        ALU_CAL:case(ALU_OP[3:2])
                NUM_CAL:case(ALU_OP[1:0])
                        ADD: o_data <= r0_data + r1_data;
                        SUB: o_data <= r0_data - r1_data;
                        MUL: o_data <= r0_data * r1_data;
                        default:
                            begin 
                                o_data <= 0;
                            end
                        endcase
                BIN_CAL:case(ALU_OP[1:0])
                        AND: o_data <= r0_data & r1_data;
                        OR : o_data <= r0_data | r1_data;
                        XOR: o_data <= r0_data ^ r1_data;
                        default:
                            begin
                                o_data <= 0;
                            end                
                        endcase
                BIM_SHIFT:case(ALU_OP[1:0])
                        SLL: o_data <= r0_data << r1_data;
                        SRL: o_data <= r0_data >> r1_data;
                        default:
                            begin
                                o_data <= 0;
                            end                    
                        endcase
                BIN_SHIFT_IMM:case(ALU_OP[1:0])
                        SLLI: o_data <= r0_data << r1_data;
                        SRLI: o_data <= r0_data >> r1_data;
                        default:
                            begin
                                o_data <= 0;
                            end    
                        endcase
                endcase
        ALU_IMM:case(ALU_OP[3:2])
                    ANDI: o_data <= r0_data & r1_data;
                    ORI : o_data <= r0_data | r1_data;
                    XORI: o_data <= r0_data ^ r1_data;
                    ADDI: o_data <= r0_data + r1_data;
                    default:
                        o_data <= 0;
                endcase
        BRANCH: case(ALU_OP[3:2])
                    BEQ: B_PCSrc <= (r0_data == r1_data);
                    BLT: B_PCSrc <= (r0_data <  r1_data);
                    BNE: B_PCSrc <= (r0_data != r1_data);
                    default:
                        B_PCSrc <= 0;
                endcase
        BRANCH_JUMP:case(ALU_OP[3:2])
                        JAL: B_PCSrc <= 1;
                    default:
                        B_PCSrc <= 0;
                    endcase    
        default:
            begin
                o_data <= 0;
                B_PCSrc <= 0;
            end
    endcase
end
    
endmodule
