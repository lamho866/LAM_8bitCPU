`timescale 1ns/1ps
    module tb_RF;

    logic               clk;
    logic               rst;
    logic               RF_w_en;
    logic    [2:0]      i_CPU_RF_addr;
    logic    [2:0]      r_addr_0;
    logic    [2:0]      r_addr_1;
    logic    [2:0]      w_addr;
    logic    [7:0]      w_data;
    logic    [7:0]      o_CPU_RF_data;
    logic    [7:0]      o_r_data_0;
    logic    [7:0]      o_r_data_1;
    
    int ErrorCnt;
    byte RF_Val [7:0];

    RF uut(
        .clk(clk),
        .rst(rst),
        .RF_w_en(RF_w_en),
        .i_CPU_RF_addr(i_CPU_RF_addr),
        .r_addr_0(r_addr_0),
        .r_addr_1(r_addr_1),
        .w_addr(w_addr),
        .w_data(w_data),
        .o_CPU_RF_data(o_CPU_RF_data),
        .o_r_data_0(o_r_data_0),
        .o_r_data_1(o_r_data_1)
    );
    
    initial clk = 1;
    always #5 clk = ~clk;

    function void check_radd0 (bit[2:0] addr);
        r_addr_0 = addr;
        if ($isunknown(o_r_data_0) || $isunknown(RF_Val[r_addr_0])) begin
            $error("Unknown or high-impedance state detected at r_add0[%d]: %08b | %08b", addr, o_r_data_0, RF_Val[r_addr_0]);
            ErrorCnt = ErrorCnt + 1;
        end
        // $display("r_add0[%d] %08b | %08b => %b", addr, o_r_data_0,  RF_Val[r_addr_0], o_r_data_0 != RF_Val[r_addr_0]);
        if(o_r_data_0 != RF_Val[r_addr_0]) begin
            $error("Wrong value r_add0[%d]: %08b | %08b", addr, o_r_data_0,  RF_Val[r_addr_0]);
            ErrorCnt = ErrorCnt + 1;
        end
    endfunction

    function void check_radd1 (bit[2:0] addr);
        r_addr_1 = addr;
        if ($isunknown(o_r_data_1) || $isunknown(RF_Val[r_addr_1])) begin
            $error("Unknown or high-impedance state detected at r_add1[%d]: %08b | %08b", addr, o_r_data_1, RF_Val[r_addr_1]);
            ErrorCnt = ErrorCnt + 1;
        end
        if(o_r_data_1 != RF_Val[r_addr_1]) begin
            $error("Wrong value r_add1[%d]: %08b | %08b", addr,o_r_data_1,  RF_Val[r_addr_1]);
            ErrorCnt = ErrorCnt + 1;
        end
    endfunction

    function void check_CPU_RF (bit[2:0] addr);
        i_CPU_RF_addr = addr;
        if ($isunknown(o_CPU_RF_data) || $isunknown(RF_Val[i_CPU_RF_addr])) begin
            $error("Unknown or high-impedance state detected at i_CPU_RF_addr[%d]: %08b | %08b", addr, o_CPU_RF_data, RF_Val[i_CPU_RF_addr]);
            ErrorCnt = ErrorCnt + 1;
        end
        if(o_CPU_RF_data != RF_Val[i_CPU_RF_addr]) begin
            $error("Wrong value i_CPU_RF_addr[%d]: %08b | %08b", addr, o_CPU_RF_data,  RF_Val[i_CPU_RF_addr]);
            ErrorCnt = ErrorCnt + 1;
        end
    endfunction

    task Checker_Scoreboard();
        for(int i = 0; i < 8; ++i) begin
            check_radd0(i);
            check_radd1(i);
            check_CPU_RF(i);
        end
    endtask;

    function void RF_w(bit [2:0] addr);
        if(RF_w_en && addr != 0) RF_Val[addr] = w_data;
    endfunction;

    task RF_specTest(bit [2:0] addr1, bit [2:0] addr2, bit [2:0] CPU_addr, bit [2:0] write_addr, bit [7:0] write_data , bit isWrite);
        r_addr_0 = addr1;
        r_addr_1 = addr2;
        i_CPU_RF_addr = CPU_addr;
        w_addr = write_addr;
        w_data = write_data;
        RF_w_en = isWrite;
        RF_w(w_addr);
        // print();
        #10;
        // print();
    endtask

    task RF_rw(bit isWrite);
        r_addr_0 = $urandom_range(3'b111, 3'b000);
        r_addr_1 = $urandom_range(3'b111, 3'b000);
        i_CPU_RF_addr = $urandom_range(3'b111, 3'b000);
        w_addr = $urandom_range(3'b111, 3'b000);
        w_data = $urandom_range(8'hFF, 8'h00);
        RF_w_en = isWrite;
        RF_w(w_addr);
        #10;
        Checker_Scoreboard();
    endtask

    task checkRandom(int round);
        for(int i = 0; i < round; ++i) begin
            bit isWrite;
            isWrite = $random()%2;
            RF_rw(isWrite);
        end
    endtask



    task seq_task_rw();
        for(int i = 0; i < 8; ++i)
            RF_rw(1);
        for(int i = 0; i < 8; ++i)
            RF_rw(0);
        
        for(int i = 0; i < 16; ++i) begin
            RF_rw(1);
            RF_rw(0);
        end

        for(int i = 0; i < 8; ++i) begin
            RF_rw(0);
            RF_rw(1);
        end

        for(int i = 0; i < 8; ++i) begin
            RF_rw(1);
            RF_rw(1);
            RF_rw(0);
            RF_rw(0);
        end
    endtask

    task reset();
        rst = 1;
        #5;
        rst = 0;
        #5;
        for(int i = 0; i < 8; ++i)
            RF_Val[i] = 0;
    endtask;

    initial begin
        reset();
        RF_specTest(0, 0, 0, 0, 8'h00, 0);
        RF_specTest(1, 0, 0, 1, 8'hAB, 1);
        RF_specTest(1, 0, 0, 1, 8'hCD, 1);
        RF_specTest(1, 0, 0, 1, 8'hEF, 1);
        // seq_task_rw();
        // reset();
        // checkRandom(5000);
        $display("ErrorCnt:", ErrorCnt);
        $finish;
    end
    
endmodule
