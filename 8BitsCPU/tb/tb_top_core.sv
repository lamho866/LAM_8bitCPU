`timescale 1ns/1ps
module tb_top_core;

logic clk;
logic rst;

initial clk = 1'b1;
always #80 clk = !clk;

CPU CPU(
    .clk(clk),
    .rst(rst)
);

initial begin
    rst = 1'b1;
    #1
    rst     = 1'b0;
    #(160*40)
    $finish;
end

endmodule
