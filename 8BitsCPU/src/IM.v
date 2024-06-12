module IM(
    input               clk,
    input               rst,
    input      [ 7:0]   PC_in,
    output     [15:0]   inst
);
parameter IM_DEPTH = 256;

reg [15:0] inst_mem[IM_DEPTH - 1:0];
assign inst = inst_mem[PC_in];
always @(posedge clk or posedge rst) begin
    if (rst) begin
        inst_mem[16'h0000] = 16'b001_11_011_000_00101;
        inst_mem[16'h0001] = 16'b010_01_001_011_001_00;
        inst_mem[16'h0002] = 16'b001_11_010_010_00111;
        inst_mem[16'h0003] = 16'b001_11_001_001_00001;
        inst_mem[16'h0004] = 16'b011_00_100_11111101;
        inst_mem[16'h0005] = 16'b000_00_000_000_001_00;
        inst_mem[16'h0006] = 16'b000_00_000_000_010_00;
        inst_mem[16'h0007] = 16'b000_00_000_000_011_00;
        inst_mem[16'h0008] = 16'b000_00_000_000_000_00;
    end else begin
        
    end
end
endmodule

