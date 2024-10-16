`timescale 1ns/1ps
    logic               clk;
    logic               rst;
    logic               RF_w_en;
    logic      [2:0]    r_addr_0;
    logic      [2:0]    r_addr_1;
    logic      [2:0]    w_addr;
    logic      [7:0]    w_data;
    logic      [7:0]    o_r_data_0;
    logic      [7:0]    o_r_data_1;

    int RF_Val[8];
    logic finalRes;
    
    module tb_rf;
    RF uut(
        clk,
        rst,
        RF_w_en,
        r_addr_0,
        r_addr_1,
        w_addr,
        w_data,
        o_r_data_0,
        o_r_data_1
    );

    initial clk = 1;
    always #5 clk = ~clk;

    task checkIsSame;
        finalRes = 1;
        for(int i = 0; i < 8; ++i) begin
            r_addr_0 = i;
            r_addr_1 = i;
            if(o_r_data_0 != RF_Val[i] || o_r_data_1 != RF_Val[i])
                finalRes = 0;
            #10;
        end
        $display("isVal: %0b", finalRes);
    endtask

    task resetCheck;
        $display("reset task");

        for(int i = 0; i < 8; ++i)
            RF_Val[i] = 0;
        rst = 1;
        #5 rst = 0;
        #5;
        // for(int i = 0; i < 8; ++i) begin
        //     #10;
        //     r_addr_0 = i;
        //     r_addr_1 = i;
        //     $display("r_addr_0 : %0d | result_val: %0b", r_addr_0, o_r_data_0 == 8'h00);
        //     $display("r_addr_1 : %0d | result_val: %0b", r_addr_1, o_r_data_1 == 8'h00);
        // end
        checkIsSame;
        $display("End reset task\n");
    endtask

    task randWR(int roundNum);
        $display("randWR task");
        
        for(int i = 0; i < 8; ++i)
            RF_Val[i] = 0;

        for(int i = 0; i < roundNum; ++i) begin
            RF_w_en = $random()%2;
            w_addr = $random()%8;
            w_data = $random()%256;
            // r_addr_0 = w_addr;

            if(RF_w_en && w_addr != 0)
                RF_Val[w_addr] = w_data;
            // #10;
            // $display("RF_w_en: %0b | w_addr: %0d | w_data: %03d | result_val: %0b", RF_w_en, w_addr, w_data, o_r_data_0 == RF_Val[w_addr]);
            // RF_w_en = 0;
            #10;
        end

        checkIsSame;
        $display("End randWR task\n");
    endtask

    initial begin
        resetCheck;
        randWR(150);
        resetCheck;
        randWR(1000);
        $finish;
    end
    
endmodule
