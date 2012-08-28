module uapp_top(
input    wire        i_clk,
input    wire        i_rst,
input    wire        i_rx_data,
output   wire        o_tx_data,
output   wire        app_wdf_wren,
output   wire [255:0]app_wdf_data,
output   wire        app_wdf_end,
output   wire [26:0] app_addr,
output   wire [2:0]  app_cmd,
output   wire        app_en,
input    wire        app_rdy,
input    wire        app_wdf_rdy,
input    wire[255:0] app_rd_data,
input    wire        app_rd_data_end,
input    wire        app_rd_data_valid,
output   wire        o_clk_100
);

wire [7:0] w_uart_tx_data;
wire [7:0] w_uart_rx_data;
wire       w_uart_tx_en;
wire       w_uart_rx_valid;
wire       clk_100;
wire [255:0] w_ddr_data;
wire       w_ddr_rd_data_valid;
wire       w_config_buff_full;
wire       w_rst;
wire       w_icap_en;
wire       w_uart_tx_buffer_full;
wire       icap_clk;
wire       w_config_clk;
reg        state;
assign o_clk_100 = icap_clk;

always @(posedge i_clk)
begin
    if(i_rst)
	     state <= 1'b0;
	 else
    begin
	     if(w_config_clk)
		      state <= ~state;
    end	 
end

dma_top dmap_top(
 .i_clk(i_clk),
 .i_rst(i_rst),
 .i_data(w_uart_rx_data),
 .i_data_valid(w_uart_rx_valid),
 .o_data(w_uart_tx_data),
 .o_data_valid(w_uart_tx_en),
 .o_ddr_data(w_ddr_data),
 .o_ddr_rd_data_valid(w_ddr_rd_data_valid),
 .i_config_buff_full(w_config_buff_full),
 .app_wdf_wren(app_wdf_wren),
 .app_wdf_data(app_wdf_data),
 .app_wdf_end(app_wdf_end),
 .app_addr(app_addr),
 .app_cmd(app_cmd),
 .app_en(app_en),
 .app_rdy(app_rdy),
 .app_wdf_rdy(app_wdf_rdy),
 .app_rd_data(app_rd_data),
 .app_rd_data_end(app_rd_data_end),
 .app_rd_data_valid(app_rd_data_valid),
 .o_rst(w_rst),
 .i_icap_en(w_icap_en),
 .i_uart_tx_buffer_full(w_uart_tx_buffer_full),
 .o_config_clk(w_config_clk)
);


icap_controller icap_cntrller(
 .i_clk_200(i_clk),
 .i_clk(icap_clk),
 .i_rst(w_rst),
 .i_ddr_data(w_ddr_data),
 .i_ddr_data_valid(w_ddr_rd_data_valid),
 .o_config_buff_full(w_config_buff_full),
 .o_icap_en(w_icap_en)
);

uart_top uart_top(
 .clk(i_clk),
 .i_rst(i_rst),
 .i_rx_data(i_rx_data),
 .o_tx_data(o_tx_data),
 .i_uart_tx_en(w_uart_tx_en),
 .i_uart_tx_data(w_uart_tx_data),
 .o_uart_rx_data(w_uart_rx_data),
 .o_uart_rx_data_valid(w_uart_rx_valid),
 .o_uart_tx_buffer_full(w_uart_tx_buffer_full)
);

clocks clock_gen
 (
  .CLKIN(i_clk),
  .RST(i_rst),
  .STATE(state),
  .SRDY(),
  .CLK0OUT(),
  .CLK1OUT(icap_clk),
  .SSTEP(w_config_clk)
 );

endmodule
