module icap_controller(
input    wire         i_clk_200,
input    wire         i_clk,
input    wire         i_rst,
input    wire [255:0] i_ddr_data,
input    wire         i_ddr_data_valid,
output   wire         o_config_buff_full,
output   wire         o_icap_en
);

wire [31:0] config_data;
reg         icap_en;
reg         icap_wr;
wire [31:0] dout;
wire        empty;
reg         rd_en;
reg         state;
parameter   idle    = 1'b0,
            rd_buff = 1'b1;

assign config_data = {dout[24],dout[25],dout[26],dout[27],dout[28],dout[29],dout[30],dout[31],dout[16],dout[17],dout[18],dout[19],dout[20],dout[21],dout[22],dout[23],dout[8],dout[9],dout[10],dout[11],dout[12],dout[13],dout[14],dout[15],dout[0],dout[1],dout[2],dout[3],dout[4],dout[5],dout[6],dout[7]};
assign o_icap_en   = icap_en;


always @(posedge i_clk)
begin
    if(i_rst)
	begin
	   rd_en   <= 1'b0;
		icap_en <= 1'b1;
		icap_wr <= 1'b1;
		state   <= idle;
	end
	else
	begin
	    case(state)
		    idle:begin
			    if(~empty)
				begin
				    rd_en  <= 1'b1;
					state  <= rd_buff;
				end
			end
			rd_buff:begin
			    icap_en <= 1'b0;
                icap_wr <= 1'b0;	
                if(empty)	
                begin
				    rd_en   <= 1'b0;   
                    icap_en <= 1'b1;                    
					icap_wr <= 1'b1;
					state   <= idle;
                end				
			end
		endcase
	end
end


config_buffer config_buffer (
  .rst(i_rst), // input rst
  .wr_clk(i_clk_200), // input wr_clk
  .rd_clk(i_clk), // input rd_clk
  .din({i_ddr_data[31:0],i_ddr_data[63:32],i_ddr_data[95:64],i_ddr_data[127:96],i_ddr_data[159:128],i_ddr_data[191:160],i_ddr_data[223:192],i_ddr_data[255:224]}), // input [255 : 0] din
  .wr_en(i_ddr_data_valid), // input wr_en
  .rd_en(rd_en), // input rd_en
  .dout(dout), // output [31 : 0] dout
  .full(full), // output full
  .almost_full(o_config_buff_full), // output almost_full
  .empty(empty) // output empty
);

ICAP_VIRTEX6 #(
   .DEVICE_ID('h4244093),     // Specifies the pre-programmed Device ID value
   .ICAP_WIDTH("X32"),          // Specifies the input and output data width to be used with the
                               // ICAP_VIRTEX6.
   .SIM_CFG_FILE_NAME("NONE")  // Specifies the Raw Bitstream (RBT) file to be parsed by the simulation
                               // model
)
ICAP_VIRTEX6_inst (
   .BUSY(),   // 1-bit output: Busy/Ready output
   .O(),         // 32-bit output: Configuration data output bus
   .CLK(i_clk), // 1-bit input: Clock Input
   .CSB(icap_en),     // 1-bit input: Active-Low ICAP input Enable
   .I(config_data),         // 32-bit input: Configuration data input bus
   .RDWRB(icap_wr)  // 1-bit input: Read/Write Select input
);

endmodule
