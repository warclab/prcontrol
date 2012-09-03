module uart_top(
input  wire       clk,
input  wire       i_rst,
input  wire       i_rx_data,
output wire       o_tx_data,
input  wire       i_uart_tx_en,
input  wire [7:0] i_uart_tx_data,
output reg  [7:0] o_uart_rx_data,
output reg        o_uart_rx_data_valid,
output wire       o_uart_tx_buffer_full
);



integer    counter;
reg        baud_en;
wire       data_present;
wire [7:0] dout;
reg        read;
wire       buffer_full;
reg        state;
wire [7:0] uart_tx_data;


parameter IDLE = 1'b0,
          RX_DATA = 1'b1;
		 
uart_tx u1
  (
  .data_in(i_uart_tx_data),
  .write_buffer(i_uart_tx_en),
  .reset_buffer(i_rst),
  .en_16_x_baud(baud_en),
  .clk(clk),
  .serial_out(o_tx_data),
  .buffer_full(),
  .buffer_half_full(o_uart_tx_buffer_full)
  ); 
  

uart_rx u2
  (
  .serial_in(i_rx_data),
  .read_buffer(read),
  .reset_buffer(i_rst),
  .en_16_x_baud(baud_en),
  .clk(clk),
  .data_out(dout),
  .buffer_data_present(data_present),
  .buffer_full(),
  .buffer_half_full()
  ); 
 
  
always @(posedge clk)
begin
    if(i_rst)
	begin
	    counter <= 0;
		 baud_en <= 1'b0;
	end
    else if(counter == 108)
	begin
	    baud_en <= 1'b1;
		counter <= 0;
   end		 
	else	 
	begin
	    baud_en <= 1'b0;
		counter <= counter + 1;
	end
end
  
always @(posedge clk)
begin
    if(i_rst)
	begin
	    state    <=    IDLE;
		read     <=    1'b0;
	end
	else
	begin
	    case(state)
	    IDLE:begin
			if(data_present)
			begin
			    o_uart_rx_data <=  dout;
				o_uart_rx_data_valid <= 1'b1;
			    read      <=  1'b1;
			    state     <=  RX_DATA;
			end
		end	
		RX_DATA:begin
			read <=    1'b0;
			o_uart_rx_data_valid <= 1'b0;
		    state <=   IDLE;
		end
		endcase
    end
end

endmodule
