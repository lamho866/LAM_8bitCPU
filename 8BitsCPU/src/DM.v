module DM(
    input                   clk,
    input                   rst,
    input                   DM_w_en,
    input                   DM_r_en,
    input       [7:0]    addr,
    input       [7:0]    DM_w_data,
    output      [7:0]    o_DM_data
); 

integer i;
parameter DM_deep = 256;
reg [15:0] data_mem [DM_deep - 1:0];

always @(posedge clk or posedge rst) begin
    if(rst) begin
        for(i = 0; i < DM_deep; i = i + 1)
            data_mem[i] <= 0;
    end else if(DM_w_en) begin
        data_mem[addr] <= DM_w_data;
    end
end

assign o_DM_data = (DM_r_en)? data_mem[addr] : 0;

endmodule
 