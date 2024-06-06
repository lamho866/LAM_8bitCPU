module RF(
    input                   clk,
    input                   rst,
    input                   RF_w_en,
    input       [2:0]    r_addr_0,
    input       [2:0]    r_addr_1,
    input       [2:0]    w_addr,
    input       [7:0]    w_data,
    output      [7:0]    o_r_data_0,
    output      [7:0]    o_r_data_1
); 

integer i;

parameter RF_Deep = 8;
reg [15:0] reg_file [RF_Deep - 1:0];

assign o_r_data_0 = reg_file[r_addr_0];
assign o_r_data_1 = reg_file[r_addr_1];

always @(posedge clk or posedge rst) begin
    if(rst) begin
        for(i = 0; i < RF_Deep; i = i + 1)
            reg_file[i] <= 0;
    end else if(RF_w_en && (w_addr != 0)) begin
        reg_file[w_addr] <= w_data;
    end
end

endmodule
