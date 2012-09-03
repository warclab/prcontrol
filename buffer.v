module buffer(
input    wire          i_clk,
input    wire [1:0]    i_wr_addr,
input    wire [1:0]    i_rd_addr,
input    wire          i_wr_en,
input    wire [46:0]   i_wr_data,
output   wire [46:0]   o_rd_data
);

reg [46:0] mem [0:3];

assign o_rd_data  =  mem[i_rd_addr];

always @(posedge i_clk)
begin
    if(i_wr_en)
	    mem[i_wr_addr]    <=    i_wr_data;
end

endmodule
