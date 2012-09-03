module statistics(
input    wire        i_clk,
input    wire        i_rst,
input    wire        i_config_start,
input    wire        i_cap_en,
input    wire        i_dma_done,
output   reg  [19:0] o_icap_clk_cnt,
output   wire [19:0] o_total_clk_cnt
);

reg  icap_en_rise = 0;
reg  icap_en_sync1 = 0;
reg  icap_en_sync2 = 0;
reg  delayed_i_cap_en = 0;
reg  clock_run; 
reg  icap_en_fall = 0;
reg [18:0] total_clk_cnt;

assign o_total_clk_cnt = total_clk_cnt + o_icap_clk_cnt;

always @(posedge i_clk)
begin
    icap_en_sync1  <=   i_cap_en;     
    icap_en_sync2  <=   icap_en_sync1;
	delayed_i_cap_en <= icap_en_sync2;
	icap_en_rise <=     icap_en_sync2 & ~delayed_i_cap_en;
	icap_en_fall <=     ~icap_en_sync2 & delayed_i_cap_en;
end

always @(posedge i_clk)
begin
    if(i_rst)
	    o_icap_clk_cnt  <=  0;
	else
    begin
	    if(~icap_en_sync2)
		    o_icap_clk_cnt <= o_icap_clk_cnt + 1;
    end	
end

always @(posedge i_clk)
begin
    if(i_rst)
	begin
	    clock_run <= 1'b0;    
	end
	else
	begin
		if(i_config_start)	
		    clock_run <= 1'b1;
		else if(icap_en_fall)
		    clock_run <= 1'b0;
	end
end

always @(posedge i_clk)
begin
    if(i_rst)
	    total_clk_cnt <= 0;
	else
    begin	
        if(clock_run)
		    total_clk_cnt <= total_clk_cnt +1;    
	end		    
end

endmodule
