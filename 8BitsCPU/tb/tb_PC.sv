`timescale 1ns/1ps
module tb_PC;
    logic clk, rst;
    byte PC_ADD, o_PC, preAdd;
    logic isSame = 1;
    initial clk = 1;
    always #5 clk = ~clk;

    PC uut(
        .clk(clk),
        .rst(rst),
        .PC_ADD(PC_ADD),
        .o_PC(o_PC)
    );


    task resetCheck;
        $display("reset task");
        rst = 1;
        #5 rst = 0;
        #5;
        $display("isVal : %0b", o_PC == 8'h00);
        $display("End reset task\n");
    endtask

    task randWR(int roundNum);
        $display("randWR task");
        isSame = 1;
        for(int i = 0; i < roundNum; ++i) begin
            preAdd = $random()%256;
            PC_ADD = preAdd;
            #10;
            if(o_PC != preAdd)
                isSame = 0;
        end
        $display("isVal : %0b", isSame);
        $display("End randWR task\n");
    endtask

    initial begin
        resetCheck;
        randWR(150);
        $finish;
    end
    
endmodule
