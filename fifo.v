module fifo(
input wire         i_clk,
input wire         i_rst,
input wire         i_wr_en,
input wire         i_rd_en,
input wire [7:0]   i_data,
output reg [511:0] o_data,
output wire [7:0]  o_data_cnt, 
output wire        o_data_rdy
);

reg [7:0] mem [0:255];
reg [7:0] wr_addr;
reg [7:0] rd_addr;
reg [7:0] data_count;

assign o_data_rdy = (data_count >= 64) ? 1'b1 : 1'b0;
assign o_data_cnt = data_count;

always @(posedge i_clk)
begin
    if(i_rst)
	begin
	    wr_addr <= 0;
	end
	else
	begin
	    if(i_wr_en)
		begin
		    mem[wr_addr] <= i_data;
			wr_addr      <= wr_addr + 1;
		end	
	end
end


always @(posedge i_clk)
begin
    if(i_rst)
	begin
	    rd_addr <= 0;
	end
	else
	begin
	    if(i_rd_en)
		begin
		    o_data       <= {mem[rd_addr+60],mem[rd_addr+61],mem[rd_addr+62],mem[rd_addr+63],mem[rd_addr+56],mem[rd_addr+57],mem[rd_addr+58],mem[rd_addr+59],mem[rd_addr+52],mem[rd_addr+53],mem[rd_addr+54],mem[rd_addr+55],mem[rd_addr+48],mem[rd_addr+49],mem[rd_addr+50],mem[rd_addr+51],mem[rd_addr+44],mem[rd_addr+45],mem[rd_addr+46],mem[rd_addr+47],mem[rd_addr+40],mem[rd_addr+41],mem[rd_addr+42],mem[rd_addr+43],mem[rd_addr+36],mem[rd_addr+37],mem[rd_addr+38],mem[rd_addr+39],mem[rd_addr+32],mem[rd_addr+33],mem[rd_addr+34],mem[rd_addr+35],mem[rd_addr+28],mem[rd_addr+29],mem[rd_addr+30],mem[rd_addr+31],mem[rd_addr+24],mem[rd_addr+25],mem[rd_addr+26],mem[rd_addr+27],mem[rd_addr+20],mem[rd_addr+21],mem[rd_addr+22],mem[rd_addr+23],mem[rd_addr+16],mem[rd_addr+17],mem[rd_addr+18],mem[rd_addr+19],mem[rd_addr+12],mem[rd_addr+13],mem[rd_addr+14],mem[rd_addr+15],mem[rd_addr+8],mem[rd_addr+9],mem[rd_addr+10],mem[rd_addr+11],mem[rd_addr+4],mem[rd_addr+5],mem[rd_addr+6],mem[rd_addr+7],mem[rd_addr],mem[rd_addr+1],mem[rd_addr+2],mem[rd_addr+3]};
			rd_addr      <= rd_addr + 64;
		end	
	end
end

always @(posedge i_clk)
begin
    if(i_rst)
	begin
	    data_count <= 0;
	end
	else
	begin
	    if(i_wr_en & i_rd_en)
		    data_count <= data_count - 63;
	    else if(i_wr_en)
		    data_count <= data_count + 1;
		else if(i_rd_en)
		begin
		    if(data_count >= 64)
               data_count <= data_count - 64;		
			 else	
			   data_count <= 0;
		end		
	end
end

endmodule
