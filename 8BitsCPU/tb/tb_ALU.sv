
`include "Golden_ALU.svh"
`timescale 1ns/1ps

module tb_ALU;

logic [7:0]    r0_data;
logic [7:0]    r1_data;
logic [6:0]    ALU_OP;
logic          B_PCSrc;
logic [7:0]    o_data;

Golden_ALU golden_ALU;
int ErrorCnt = 0;

ALU ALU (
    .r0_data(r0_data),
    .r1_data(r1_data),
    .ALU_OP(ALU_OP),
    .B_PCSrc(B_PCSrc),
    .o_data(o_data)
);


function Checker_ScoreBoard();
    if(o_data != golden_ALU.o_data(ALU_OP, r0_data, r1_data)) begin
        $error("o_data Wrong");
        ErrorCnt = ErrorCnt + 1;
    end
    
    if(B_PCSrc != golden_ALU.B_PCSrc(ALU_OP, r0_data, r1_data)) begin
        $error("B_PCSrc Wrong");
        ErrorCnt = ErrorCnt + 1;
    end
endfunction;

task ALU_OP_CMD_Random(int round);
    for(int i = 0; i < round; ++i) begin
        ALU_OP = $urandom_range(7'hFF, 0);
        r0_data = $urandom_range(8'hFF, 0);
        r1_data = $urandom_range(8'hFF, 0);
        #10;
        Checker_ScoreBoard();
    end
endtask //ALU_OP

task ALU_OP_CMD_Test(bit [6:0] ALU_OP_CMD);
    ALU_OP = ALU_OP_CMD;
    r0_data = $urandom_range(8'hFF, 0);
    r1_data = $urandom_range(8'hFF, 0);
    #10;
    Checker_ScoreBoard();
endtask //ALU_OP

bit [6:0] ALU_CMD;
task ALU_test();
    ErrorCnt = 0;
    ALU_CMD = 0;
    for(int i = 0; i < 128; i = i + 1) begin
        ALU_OP_CMD_Test(ALU_CMD);
    end
    $display("ErrorCnr: %d", ErrorCnt);
endtask

initial begin
    golden_ALU = new();
    ALU_test();
    ALU_OP_CMD_Random(5000);
    // $monitor("Time = %t, ALU_OP = %b, r0 = %h, r1 = %h, o_data = %h, B_PCSrc=%b", $time, ALU_OP, r0_data, r1_data, o_data, B_PCSrc);
end

endmodule
