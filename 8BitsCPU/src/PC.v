module PC(
    input               clk,
    input               rst,
    input      [7:0]    PC_ADD,
    output reg [7:0]    o_PC
);

always @(posedge clk or posedge rst) begin
    if(rst)
        o_PC <= 0;
    else
        o_PC <= PC_ADD;
end
endmodule
