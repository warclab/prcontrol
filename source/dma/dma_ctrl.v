module dma_ctrl(
input  wire        i_clk,
input  wire        i_rst,
input  wire [7:0]  i_data,
input  wire        i_data_valid,
output wire [7:0]  o_data,
output wire        o_data_valid,
output wire [26:0] o_ddr_strt_addr,
output wire [511:0]o_ddr_data,
output reg         o_ddr_wr,
input  wire        i_ddr_wr_done,
output reg         o_ddr_rd,
input  wire        i_ddr_rd_done,
output wire        o_rst,
output wire        o_load,
output wire        o_pgrm_icap,
input  wire [19:0] i_icap_clk_cnt,
input  wire [19:0] i_total_clk_cnt,
input  wire        i_uart_tx_buffer_full,
output wire        o_config_clk,
output reg         o_dma_done
);

wire           w_buff_en;
wire           w_srst;
wire           reset;
wire [511:0]   buffer_data;
reg            fifo_rd;
reg  [2:0]     state;
wire           wr_data_rdy;
wire [19:0]    dma_len;
reg  [19:0]    rd_wr_len;
wire [7:0]     buffer_data_cnt;
wire           load_info;
wire           w_pgrm_icap;
reg            last_read_flag;

assign o_ddr_data = buffer_data;
assign reset      = i_rst|w_srst;
assign o_rst      = reset;
assign o_load     = load_info;
assign o_pgrm_icap= w_pgrm_icap;

parameter idle      = 'd0,
          wait_1    = 'd1,
          wr_ddr    = 'd2,
		  read_ddr  = 'd3,
		  check_len = 'd4;

fifo buffer_fifo (
  .i_clk(i_clk), 
  .i_rst(reset), 
  .i_wr_en(w_buff_en & i_data_valid), 
  .i_rd_en(fifo_rd), 
  .i_data(i_data), 
  .o_data(buffer_data), 
  .o_data_rdy(wr_data_rdy),
  .o_data_cnt(buffer_data_cnt)
);


cmd_int cmd_int (
  .i_clk(i_clk), 
  .i_rst(i_rst), 
  .i_data_valid(i_data_valid), 
  .i_data(i_data),  
  .o_buff_en(w_buff_en), 
  .o_data_valid(o_data_valid), 
  .o_data(o_data), 
  .o_srst(w_srst), 
  .o_pgrm_icap(w_pgrm_icap), 
  .o_ddr_strt_addr(o_ddr_strt_addr), 
  .o_trans_len(dma_len),
  .o_load(load_info),
  .i_icap_clk_cnt(i_icap_clk_cnt),
  .i_total_clk_cnt(i_total_clk_cnt),
  .i_uart_tx_buffer_full(i_uart_tx_buffer_full),
  .o_config_clk(o_config_clk)
);


always @(posedge i_clk)
begin
    if(reset)
	begin
		fifo_rd    <= 1'b0;
		state      <= idle;
		o_ddr_rd   <= 1'b0;
		o_ddr_wr   <= 1'b0;
		last_read_flag <= 1'b0;
		o_dma_done <= 1'b0;
	end
	else
	begin
	   case(state)
	        idle:begin
				fifo_rd <= 1'b0;
				last_read_flag <= 1'b0;
				o_dma_done <= 1'b0;
				if(load_info)
				begin
				    rd_wr_len <= dma_len;    
				end
				else if(wr_data_rdy | (rd_wr_len == buffer_data_cnt & rd_wr_len!= 0))
                begin
				    fifo_rd  <= 1'b1;
					state    <= wait_1;
                end						
			    else if(w_pgrm_icap)
			    begin
			        state  <= check_len;
			    end
			end
			wait_1:begin
			    state    <= wr_ddr;
				fifo_rd  <= 1'b0;
			end
			wr_ddr:begin
			    o_ddr_wr  <= 1'b1;
				if(i_ddr_wr_done)
				begin
				    o_ddr_wr  <= 1'b0;
					state     <= idle;
					if(rd_wr_len >= 64)
					    rd_wr_len <= rd_wr_len - 64;
				   else	
                   rd_wr_len <= 0;					
				end
			end
			read_ddr:begin
			    o_ddr_rd <= 1'b1;
				 if(i_ddr_rd_done)
				 begin
				      o_ddr_rd  <= 1'b0;
					  if(last_read_flag)
					  begin
					      state    <= idle;
							o_dma_done <= 1'b1;
					  end		
					  else	  
					      state     <= check_len;
					  if(rd_wr_len >= 64)
					    rd_wr_len <= rd_wr_len - 64;
				     else	
                   rd_wr_len <= 0;
				 end
			end
			check_len:begin
			    if(rd_wr_len <= 64)
				begin
				    last_read_flag <= 1'b1;
				end
				state              <= read_ddr;
			end
	   endcase
	end
end


endmodule
