module IM(
    input               clk,
    input               rst,
    input               inCmd,
    input      [7:0]   i_addr,
    input      [7:0]   i_inst,
    output     [15:0]   o_inst
);
parameter IM_BYTE_DEPTH = 256;
integer i;

reg [7:0] inst_mem[0:IM_BYTE_DEPTH - 1];
assign o_inst = (inCmd)? 16'hFFFF : {inst_mem[i_addr], inst_mem[i_addr + 1]};

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for(i = 0; i < IM_BYTE_DEPTH; i = i + 1)
            inst_mem[i] <= 16'hFFFF;
    end else begin
        if(inCmd)
            inst_mem[i_addr] <= i_inst;
    end
end
endmodule

