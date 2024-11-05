module PC(
    input               clk,
    input               rst,
    input               inCmd,
    input      [7:0]    PC_ADD,
    input               i_is_done,
    output reg [7:0]    o_PC
);

always @(posedge clk or posedge rst) begin
    if(rst)
        o_PC <= 0;
    else if(inCmd)
        o_PC <= 0;
    else if(i_is_done)
        o_PC <= o_PC;
    else
        o_PC <= PC_ADD;
end
endmodule
