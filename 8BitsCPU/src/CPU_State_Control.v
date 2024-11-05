module CPU_State_Control (
    input               clk,
    input               rst,
    input      [15:0]   IM_inst,
    input      [ 7:0]   i_inst,
    output              inCmd,
    output       reg    o_is_done
);

localparam init_inCmd = 0, cnt0_isAllOne = 1, cnt1_isAllOne = 2, ed_inst = 3;
reg [1:0] inCmd_fsm, inCmd_nxt_fsm;

assign inCmd = (inCmd_fsm != ed_inst);
always @(*) begin
    case (inCmd_fsm)
        init_inCmd: inCmd_nxt_fsm <= cnt0_isAllOne;
        cnt0_isAllOne: inCmd_nxt_fsm <= (i_inst == 8'hFF)? cnt1_isAllOne : cnt0_isAllOne;
        cnt1_isAllOne: inCmd_nxt_fsm <= (i_inst == 8'hFF)? ed_inst : cnt0_isAllOne;
        ed_inst: inCmd_nxt_fsm <= ed_inst;
        default:
            inCmd_nxt_fsm <= ed_inst;
    endcase
end

always @(posedge clk or posedge rst) begin
    if(rst)
        inCmd_fsm <= init_inCmd;
    else
        inCmd_fsm <= inCmd_nxt_fsm;
end

always @(posedge clk or posedge rst) begin
    if(rst)
        o_is_done <= 0;
    else if((IM_inst == 16'hFFFF) && ~inCmd)
        o_is_done <= 1;
    else
        o_is_done <= o_is_done;
end
endmodule //CPU_State_Control