`timescale 1ns/1ps
module tb_PCIM;

logic               clk;
logic               rst;
logic       [ 7:0]  i_cpu_addr;
logic       [ 7:0]  i_inst;

initial clk = 1;
always #5 clk = ~clk;

//PC_OUTPUT
logic [7:0] PC_wire;

//IM_OUTPUT
wire [15:0] IM2DM_inst;

logic inCmd;

localparam init_inCmd = 0, cnt0_isAllOne = 1, cnt1_isAllOne = 2, ed_inst = 3;
reg [1:0] inCmd_fsm, inCmd_nxt_fsm;
reg in_flag;

always @(posedge clk or posedge rst) begin
    if(rst) in_flag <= 0;
    else if(inCmd) in_flag <= ~in_flag;
    else in_flag <= in_flag;
end

assign inCmd = (inCmd_nxt_fsm != ed_inst);

always @(*) begin
    case (inCmd_fsm)
        init_inCmd: inCmd_nxt_fsm <= cnt0_isAllOne;
        cnt0_isAllOne: inCmd_nxt_fsm <= (i_inst == 8'hFF && in_flag == 1)? cnt1_isAllOne : cnt0_isAllOne;
        cnt1_isAllOne: inCmd_nxt_fsm <= (i_inst == 8'hFF && in_flag == 0)? ed_inst : cnt0_isAllOne;
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

//------------------------
wire [7:0] i_ID_addr;
logic [7:0] PC_ADD;
// always @(posedge clk) PC_ADD <= (inCmd)? 0 : PC_wire + 1;
assign PC_ADD = PC_wire + 1;
// assign i_ID_addr = (inCmd)? i_cpu_addr : PC_wire;

assign i_ID_addr = (inCmd)? i_cpu_addr : PC_wire;

PC PC(
    .clk(clk),
    .inCmd(inCmd),
    .PC_ADD(PC_ADD),
    .o_PC(PC_wire)
);

IM IM(
    .clk(clk),
    .rst(rst),
    .in_flag(in_flag),
    .inCmd(inCmd),
    .i_inst(i_inst),
    .i_addr(i_ID_addr),
    .o_inst(IM2DM_inst)
);


task inCommand(bit[7:0] i_addr, bit [15:0] i_cmd);
    i_cpu_addr = i_addr;
    i_inst = i_cmd[15:8];
    #10;
    i_inst = i_cmd[7:0];
    #10;
endtask;

always @(posedge clk) begin
    $display("%010t | %02h | %02h | %0b | %02h | %02h | %04h", $time, PC_ADD, PC_wire, inCmd, i_ID_addr, i_cpu_addr ,IM2DM_inst);
end

// function printMsg();
//     $display("%010t | %02h | %02h | %0b | %02h | %02h | %04h", $time, PC_ADD, PC_wire, inCmd, i_ID_addr, i_cpu_addr ,IM2DM_inst);
// endfunction;

initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_PCIM .IM, tb_PCIM .PC);
    i_cpu_addr = 0;
    i_inst = 0;
    rst = 1;
    #5 rst = 0;
    #5;
    inCommand(0, 16'hABCD);
    inCommand(1, 16'h0101);
    inCommand(2, 16'h2424);
    inCommand(3, 16'h4242);
    // inCommand(4, 16'h00FF);
    // inCommand(5, 16'hFF00);
    // inCommand(6, 16'hABCD);
    inCommand(7, 16'hFFFF);
    inCommand(7, 16'h0000);
    for(int i = 0; i < 20; ++i) begin
        i_cpu_addr = i;
        // printMsg();
        #10;
    end
    
    $finish;

end

endmodule