`timescale 1ns/1ps
module tb_IM;

logic clk;
logic rst;
logic inCmd;
logic [ 7:0]i_inst, i_addr;
logic [15:0]o_inst;

initial clk = 1;
always #5 clk = ~clk;

localparam init_inCmd = 0, cnt0_isAllOne = 1, cnt1_isAllOne = 2, ed_inst = 3;
reg [1:0] inCmd_fsm, inCmd_nxt_fsm;

assign inCmd = (inCmd_nxt_fsm != ed_inst);

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

IM IM(
    .clk(clk),
    .rst(rst),
    .inCmd(inCmd),
    .i_addr(i_addr),
    .i_inst(i_inst),
    .o_inst(o_inst)
);

task reset;
    rst = 1;
    #5 rst = 0;
    #5;
    $display("%010t | %03d | %04h", $time, 0, o_inst);
endtask;

task inCommand(bit[7:0] i_w_addr, bit [15:0] i_cmd);
    i_addr = i_w_addr;
    i_inst = i_cmd[15:8];
    #10;
    i_inst = i_cmd[7:0];
    #10;
endtask;

initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_IM .IM);
    reset;
    inCommand(0, 16'hABCD);
    inCommand(1, 16'h0101);
    inCommand(2, 16'h2424);
    inCommand(3, 16'h4242);
    inCommand(4, 16'hFFFF);
    inCommand(5, 16'hAAAA);
    for(int i = 0; i < 6; ++i) begin
        i_addr = i;
        $display("%010t | %03d | %04h", $time, i, o_inst);
        #10;
    end
    $finish;
end


endmodule