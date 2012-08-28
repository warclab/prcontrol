module ddr_controller(
output    reg             app_wdf_wren,
output    reg  [255:0]    app_wdf_data,
output    reg             app_wdf_end,
output    wire [26:0]     app_addr,
output    reg  [2:0]      app_cmd,
output    reg             app_en,
input                     app_rdy,
input                     app_wdf_rdy,
input          [255:0]    app_rd_data,
input                     app_rd_data_end,
input                     app_rd_data_valid,
input                     rst,
input                     clk,

input                     i_load,
input          [26:0]     i_ddr_strt_addr,
input          [511:0]    i_ddr_data,
input                     i_ddr_wr,
output    reg             o_ddr_wr_done,
input                     i_ddr_rd,
output    reg  [255:0]    o_ddr_data,
output    reg             o_ddr_rd_data_valid,
output    reg             o_ddr_rd_done,
input                     i_config_buff_full
);

reg [2:0]  state;
reg [26:0] ddr_wr_addr;
reg [26:0] ddr_rd_addr;
assign app_addr = app_cmd[0] ? ddr_rd_addr : ddr_wr_addr;

parameter idle      = 'd0,
          wr_data1  = 'd1,
          wr_data2  = 'd2,
		  wr_cmd    = 'd3,
		  wait1     = 'd4,
		  rd_cmd    = 'd5,
		  rd_data1  = 'd6,
		  rd_data2  = 'd7;

always @(posedge clk)
begin
    if(rst)
	begin
	    state         <= idle;
		o_ddr_wr_done <= 1'b0;
		app_wdf_wren  <= 1'b0;
		app_wdf_end   <= 1'b0;
		app_en        <= 1'b0;
		o_ddr_rd_done <= 1'b0;
		o_ddr_rd_data_valid <= 1'b0;
	end
	else
	begin
	    case(state)
		    idle:begin
			    o_ddr_rd_data_valid <= 1'b0;
				if(i_load)
				begin
				   ddr_rd_addr <= i_ddr_strt_addr;
					ddr_wr_addr <= i_ddr_strt_addr;
				end
			    else if(i_ddr_wr)
				begin
				   state        <= wr_data1;
					app_wdf_wren <= 1'b1;
					app_wdf_data <= i_ddr_data[255:0];
				end
				else if(i_ddr_rd & ~i_config_buff_full)
				begin
				   state <= rd_cmd;
				end
			end
			wr_data1:begin
			    if(app_wdf_rdy)
				begin
				    app_wdf_data <= i_ddr_data[511:256];    
					state        <= wr_data2;
					app_wdf_end  <= 1'b1;
				end
			end
			wr_data2:begin
				if(app_wdf_rdy)
				begin
				    app_wdf_wren <= 1'b0;
					app_wdf_end  <= 1'b0;
					state        <= wr_cmd;
					app_en       <= 1'b1;
					app_cmd      <= 3'b000;
				end	
			end
			wr_cmd:begin
			    if(app_rdy)
				begin
				    app_en        <= 1'b0;
					o_ddr_wr_done <= 1'b1;
					state         <= wait1;
					ddr_wr_addr   <= ddr_wr_addr + 64;
				end
			end
			wait1:begin
				state         <= idle;
				o_ddr_wr_done <= 1'b0;
				o_ddr_rd_done <= 1'b0;	
				o_ddr_rd_data_valid <= 1'b0;
			end
			rd_cmd:begin
			    if(app_rdy)
				begin
				    app_en        <= 1'b1;
					app_cmd       <= 3'b001;
					state         <= rd_data1;
				end
			end
			rd_data1:begin
			    app_en        <= 1'b0;
				if(app_rd_data_valid)
				begin
				    o_ddr_data            <= app_rd_data;
					state                 <= rd_data2;
					o_ddr_rd_data_valid   <= 1'b1;
				end
				else
				    o_ddr_rd_data_valid   <= 1'b0;
			end
			rd_data2:begin
				if(app_rd_data_valid)
				begin
				    o_ddr_data            <= app_rd_data;
					state                 <= wait1;
					o_ddr_rd_done         <= 1'b1;
					o_ddr_rd_data_valid   <= 1'b1;
					ddr_rd_addr <= ddr_rd_addr + 64;
				end
				else
				    o_ddr_rd_data_valid   <= 1'b0;
			end
		endcase
	end
end

endmodule

