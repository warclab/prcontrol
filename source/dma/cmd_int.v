`define CMOD 'h434D4F44
`define DMOD 'h444D4F44
`define SADR 'h53414452
`define SLEN 'h534C454E
`define SRST 'h53525354
`define PICP 'h50494350
`define RST1 'h52535431
`define RST2 'h52535432
`define SCFQ 'h53434651
`define CINT 'h43494E54
`define NCON 'h4E434F4E

module cmd_int(
input    wire        i_clk,
input    wire        i_rst,
input    wire        i_data_valid,
input    wire [7:0]  i_data,
output   reg         o_buff_en,
output   wire        o_data_valid,
output   wire [7:0]  o_data,
output   reg         o_srst,
output   reg         o_pgrm_icap,
output   wire [26:0] o_ddr_strt_addr,
output   wire [19:0] o_trans_len,
output   reg         o_load,
input    wire  [19:0]i_icap_clk_cnt,
input    wire  [19:0]i_total_clk_cnt,
input    wire        i_uart_tx_buffer_full,
output   reg         o_config_clk 
);

reg  [7:0]  cmd_reg [3:0];
reg  [3:0]  state;
wire [31:0] cmd;
reg  [3:0]  len_reg[0:5];
reg  [3:0]  addr_reg[0:5];
reg  [4:0]  len_cnt;
reg  [7:0]  tx_data;
reg         tx_valid;
reg         buff_wr_en;
reg  [1:0]  buff_wr_addr;
reg  [1:0]  buff_rd_addr;
reg  [7:0]  config_cnter[0:3];
wire [26:0] buff_ddr_strt_addr;
wire [19:0] buff_trans_len;

parameter CMOD = 'd0,
          DMOD = 'd1,
			 SADR = 'd2,
			 SLEN = 'd3,
			 SRST = 'd4,
			 PICP = 'd5,
			 RST1 = 'd6,
			 RST2 = 'd7,
			 SCFQ = 'd8,
			 CINT = 'd9,
			 START = 'd10,
			 NCON = 'd11;
			 
assign cmd              = {cmd_reg[3],cmd_reg[2],cmd_reg[1],cmd_reg[0]};
assign o_data_valid     = (state == DMOD) ? 1'b0: i_data_valid|tx_valid;
assign o_data           = tx_valid ? tx_data : i_data;
assign o_trans_len      = (state == START) ? buff_trans_len : len_reg[0]*100000 + len_reg[1]*10000 + len_reg[2]*1000 + len_reg[3]*100 + len_reg[4]*10 + len_reg[5];
assign o_ddr_strt_addr  = (state == START) ? buff_ddr_strt_addr: addr_reg[0]*100000 + addr_reg[1]*10000 + addr_reg[2]*1000 + addr_reg[3]*100 + addr_reg[4]*10 + addr_reg[5];

//Store each valid byte into a shift register for generating commands.
always @(posedge i_clk)
begin
    if(i_rst)
	begin
	    cmd_reg[0] <= 0;
	    cmd_reg[1] <= 0;
	    cmd_reg[2] <= 0;
	    cmd_reg[3] <= 0;
	end
	else
	begin
	    if(i_data_valid)
		begin
		    cmd_reg[0] <= i_data;
			cmd_reg[1] <= cmd_reg[0];
			cmd_reg[2] <= cmd_reg[1];
			cmd_reg[3] <= cmd_reg[2];
		end
	end
end

//Main state machine
always @(posedge i_clk)
begin
    if(i_rst)
	begin
	    state         <=  CMOD;
		o_buff_en     <=  1'b0;
		len_cnt       <=  0;
		o_srst        <=  1'b0;
		o_pgrm_icap   <=  1'b0;
		o_load        <=  1'b0;
		tx_valid      <=  1'b0;
		o_config_clk  <=  1'b0;
		buff_wr_en    <=  1'b0;
		buff_wr_addr  <=  2'b00;
        config_cnter[0] <= 0;
        config_cnter[1] <= 0;
        config_cnter[2] <= 0;
        config_cnter[3] <= 0;
    end
	else
    begin
	    case(state)
		    CMOD:begin
			    o_buff_en   <= 1'b0;
			    o_srst      <= 1'b0;
		        o_pgrm_icap <= 1'b0;
				o_load      <= 1'b0;
				len_cnt     <= 0;
				tx_valid    <= 1'b0;
			    if(cmd == `DMOD)
				begin
				    state       <= DMOD;
					buff_wr_en  <= 1'b1;
				end
				else if(cmd == `SADR)
				begin
				   state <= SADR;
				end
				else if(cmd == `SLEN)
				begin
				    state <= SLEN;
				end
				else if(cmd == `SRST)
				begin
				    state <= SRST;
				end
				else if(cmd == `PICP)
				begin
				    state <= PICP;
					o_pgrm_icap <= 1'b1;
				end
				else if(cmd == `RST1)
				begin
				    state    <= RST1;
					len_cnt  <= 19;
				end
				else if(cmd == `RST2)
				begin
				    state    <= RST2;
					len_cnt  <= 19;
				end
				else if(cmd == `SCFQ)
				begin
				    state    <= SCFQ;
					 o_config_clk <= 1'b1;
				end
				else if(cmd == `CINT)
				begin
				    state    <=    CINT;
				end
                else if(cmd == `NCON)
                begin
                    state   <= NCON;
                end
			end
			DMOD:begin
			   buff_wr_en   <= 1'b0;
			   if(cmd == `CMOD)
				begin
				    state     <= CMOD;
					 o_buff_en <= 1'b0;
					 buff_wr_addr <= buff_wr_addr + 1;
				end
				o_buff_en <= 1'b1;    
			end
			SADR:begin
			    if(i_data_valid)
				begin
				    addr_reg[len_cnt] <= i_data - 'h30;
					len_cnt <= len_cnt + 1;
					if(len_cnt == 5)
					begin
					    state <= CMOD;
						o_load        <=  1'b1;
					end	
				end
			end
			SLEN:begin
			    if(i_data_valid)
				begin
				    len_reg[len_cnt] <= i_data - 'h30;
					len_cnt <= len_cnt + 1;
					if(len_cnt == 5)
					begin
					    state     <= CMOD;
						o_load    <=  1'b1;
					end	
				end
			end
			SRST:begin
			    if(cmd == `CMOD)
				begin
				    state     <= CMOD;
					o_srst    <= 1'b0;
				end
				else
				    o_srst    <= 1'b1;
			end
			PICP:begin
			    o_pgrm_icap <= 1'b0;
				if(cmd == `CMOD)
				begin
				    state    <= CMOD;
				end	
			end	
            RST1:begin
				if(~i_uart_tx_buffer_full & len_cnt != 31)
				begin
			        tx_data <= i_icap_clk_cnt[len_cnt] + 'h30;
				    len_cnt <= len_cnt - 1;
				    tx_valid <= 1'b1;
				end
                else
				    tx_valid <= 1'b0;
				if(cmd == `CMOD)
				begin
				    state <= CMOD;
				end	
            end	
            RST2:begin
			    if(~i_uart_tx_buffer_full & len_cnt != 31)
				begin
			       tx_data <= i_total_clk_cnt[len_cnt] + 'h30;
				    len_cnt <= len_cnt - 1;
				    tx_valid <= 1'b1;
				end	
				else
				    tx_valid <= 1'b0;
				if(cmd == `CMOD)
				begin
				    state <= CMOD;
				end	
            end
            SCFQ:begin
				if(cmd == `CMOD)
				begin
				    state <= CMOD;
				end	
				o_config_clk <= 1'b0;
            end
            CINT:begin
			    if(i_data_valid)
				begin
				    buff_rd_addr    <=    i_data - 'h30;    
					o_load          <=    1'b1;
					state           <=    START;
				end	
            end
            START:begin
			      o_pgrm_icap         <=    1'b1;
				   o_load              <=    1'b0;
				   state               <=    PICP;
               config_cnter[buff_rd_addr] <= config_cnter[buff_rd_addr] + 1;
            end
            NCON:begin
                if(i_data_valid)
                begin
                    tx_data <= config_cnter[i_data - 'h30] + 'h30;
				        tx_valid <= 1'b1;
				        tx_valid <= 1'b1;
                    state    <= CMOD;
                end
            end			
		endcase
    end
end

buffer addr_len_buffer(
 .i_clk(i_clk),
 .i_wr_addr(buff_wr_addr),
 .i_rd_addr(buff_rd_addr),
 .i_wr_en(buff_wr_en),
 .i_wr_data({o_ddr_strt_addr,o_trans_len}),
 .o_rd_data({buff_ddr_strt_addr,buff_trans_len})
);

endmodule
