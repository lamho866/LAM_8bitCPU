`timescale 1ns/1ps
module tb_CPU;

logic               clk;
logic               rst;
logic               isReg;
logic    [ 7:0]     i_inst;
logic    [ 7:0]     i_cpu_addr;
logic    [ 7:0]     o_CPU_data;
logic               o_is_done;
 
string VCD_FILE = "tb_CPU.vcd", cmd;
int fd, cnt;
// always @(posedge clk) $display("$010t | %01b | %02h | %02h", $time, isReg, i_cpu_addr, o_CPU_data);

CPU CPU(
    .clk(clk),
    .rst(rst),
    .isReg(isReg),
    .i_inst(i_inst),
    .i_cpu_addr(i_cpu_addr),
    .o_CPU_data(o_CPU_data),
    .o_is_done(o_is_done)
);

localparam CLK_PERIOD = 80;
initial clk = 1;
always #(CLK_PERIOD/2) clk = ~clk;

task reset;
    i_inst = 0;
    isReg = 0;
    i_cpu_addr = 0;
    rst = 1;
    #(CLK_PERIOD/2) rst = 0;
    #(CLK_PERIOD/2);
endtask

task inCommand(bit[15:0] i_addr, bit [15:0] i_cmd);
 $display("%010t | i_addr: %04h | cmd: %016b", $time,  i_addr, i_cmd);
    i_cpu_addr = i_addr;
    i_inst = i_cmd[15:8];
    #(CLK_PERIOD);
    i_cpu_addr = i_addr + 1;
    i_inst = i_cmd[7:0];
    #(CLK_PERIOD);
endtask

function bit[15:0] string2bin(string s);
    bit [15:0] binValue;
    for(int i = 0; i < 16; i = i+1) begin
        binValue[15-i] = s[i] - "0";
    end
    return binValue;
endfunction

task loadFile (string TV_FILE);
    $display("TV_FILE: ", TV_FILE);
    fd = $fopen(TV_FILE, "r");
    cnt = 0;
    while(!$feof(fd)) begin
        if($fscanf(fd,"%s", cmd)) begin
            // $display("%010t | cnt: %03d | cmd: %s", $time,  cnt, cmd);
            inCommand(cnt, string2bin(cmd));
            cnt = cnt + 2;
        end
        // #(CLK_PERIOD);
    end
    $fclose(fd);
endtask

task showReg();
    isReg = 1;
    for(int i = 0; i < 8; ++i) begin
        i_cpu_addr = i;
        #CLK_PERIOD;
        $display("r%d : %d", i, o_CPU_data);
    end
endtask

task showDM(int st, int ed);
    $display("ShowDM");
    isReg = 0;
    for(int i = st; i < ed; ++i) begin
        i_cpu_addr = i;
        #CLK_PERIOD;
        $display("DM[%03d] : %d", i, o_CPU_data);
    end
endtask

initial begin
    $dumpfile(VCD_FILE);
    $dumpvars(0, tb_CPU .CPU);
    reset;
    #1;
    loadFile("tb_MachCode/ass_machCode.txt");
    // #(cnt *  CLK_PERIOD);
    while(~o_is_done) begin
        // isReg = 1;
        // i_cpu_addr = 3;
        #CLK_PERIOD;
        // $display("r3: %d", o_CPU_data);
    end
    $display("----------------------------------");
    $display("Done: %t, o_is_done Signal:", $time, o_is_done);
    $display("----------------------------------");
    showReg();
    showDM(0, 10);
    $finish;
end

endmodule