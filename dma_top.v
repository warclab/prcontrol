module dma_top(
input  wire        i_clk,
input  wire        i_rst,
input  wire [7:0]  i_data,
input  wire        i_data_valid,
output wire [7:0]  o_data,
output wire        o_data_valid,
output wire[255:0] o_ddr_data,
output wire        o_ddr_rd_data_valid,
output wire        app_wdf_wren,
output wire [255:0]app_wdf_data,
output wire        app_wdf_end,
output wire [26:0] app_addr,
output wire [2:0]  app_cmd,
output wire        app_en,
input  wire        app_rdy,
input  wire        app_wdf_rdy,
input  wire[255:0] app_rd_data,
input  wire        app_rd_data_end,
input  wire        app_rd_data_valid,
input  wire        i_config_buff_full,
output wire        o_rst,
input  wire        i_icap_en,
input  wire        i_uart_tx_buffer_full,
output wire        o_config_clk
);

wire        w_rst;
wire        w_load;
wire [26:0] w_ddr_strt_addr;
wire [511:0]w_ddr_data;
wire        w_ddr_wr;
wire        w_ddr_wr_done;
wire        w_ddr_rd;
wire        w_ddr_rd_done;
wire        w_pgrm_icap;
wire [19:0] w_icap_clk_cnt;
wire [19:0] w_total_clk_cnt;
wire        w_dma_done;

assign o_rst = w_rst;

dma_ctrl dma_ctrl (
  .i_clk(i_clk), 
  .i_rst(i_rst), 
  .i_data(i_data), 
  .i_data_valid(i_data_valid), 
  .o_data(o_data), 
  .o_data_valid(o_data_valid), 
  .o_ddr_strt_addr(w_ddr_strt_addr), 
  .o_ddr_data(w_ddr_data), 
  .o_ddr_wr(w_ddr_wr), 
  .i_ddr_wr_done(w_ddr_wr_done), 
  .o_ddr_rd(w_ddr_rd), 
  .i_ddr_rd_done(w_ddr_rd_done), 
  .o_rst(w_rst), 
  .o_load(w_load),
  .o_pgrm_icap(w_pgrm_icap),
  .i_icap_clk_cnt(w_icap_clk_cnt),
  .i_total_clk_cnt(w_total_clk_cnt),
  .i_uart_tx_buffer_full(i_uart_tx_buffer_full),
  .o_config_clk(o_config_clk),
  .o_dma_done(w_dma_done)
);


ddr_controller ddr_controller (
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
  .rst(w_rst), 
  .clk(i_clk), 
  .i_load(w_load), 
  .i_ddr_strt_addr(w_ddr_strt_addr), 
  .i_ddr_data(w_ddr_data), 
  .i_ddr_wr(w_ddr_wr), 
  .o_ddr_wr_done(w_ddr_wr_done), 
  .i_ddr_rd(w_ddr_rd), 
  .o_ddr_data(o_ddr_data), 
  .o_ddr_rd_data_valid(o_ddr_rd_data_valid), 
  .o_ddr_rd_done(w_ddr_rd_done),
  .i_config_buff_full(i_config_buff_full)
);


statistics statistics(
  .i_clk(i_clk),
  .i_rst(w_rst),
  .i_config_start(w_pgrm_icap),
  .i_cap_en(i_icap_en),
  .i_dma_done(w_dma_done),
  .o_icap_clk_cnt(w_icap_clk_cnt),
  .o_total_clk_cnt(w_total_clk_cnt)
);


endmodule
