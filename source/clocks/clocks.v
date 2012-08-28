///////////////////////////////////////////////////////////////////////////////
//    
//    Company:          Xilinx
//    Engineer:         Karl Kurbjun
//    Date:             12/7/2009
//    Design Name:      MMCM DRP
//    Module Name:      top.v
//    Version:          1.0
//    Target Devices:   Virtex 6 Family
//    Tool versions:    L.50 (lin)
//    Description:      This is a basic demonstration of the MMCM_DRP 
//                      connectivity to the MMCM_ADV.
// 
//    Disclaimer:  XILINX IS PROVIDING THIS DESIGN, CODE, OR
//                 INFORMATION "AS IS" SOLELY FOR USE IN DEVELOPING
//                 PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY
//                 PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
//                 ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
//                 APPLICATION OR STANDARD, XILINX IS MAKING NO
//                 REPRESENTATION THAT THIS IMPLEMENTATION IS FREE
//                 FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE
//                 RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY
//                 REQUIRE FOR YOUR IMPLEMENTATION.  XILINX
//                 EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH
//                 RESPECT TO THE ADEQUACY OF THE IMPLEMENTATION,
//                 INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
//                 REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
//                 FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES
//                 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//                 PURPOSE.
// 
//                 (c) Copyright 2009-1010 Xilinx, Inc.
//                 All rights reserved.
// 
///////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module clocks 
   (
      // SSTEP is the input to start a reconfiguration.  It should only be
      // pulsed for one clock cycle.
      input    SSTEP,
      // STATE determines which state the MMCM_ADV will be reconfigured to.  A 
      // value of 0 correlates to state 1, and a value of 1 correlates to state 
      // 2.
      input    STATE,

      // RST will reset the entire reference design including the MMCM_ADV
      input    RST,
      // CLKIN is the input clock that feeds the MMCM_ADV CLKIN as well as the
      // clock for the MMCM_DRP module
      input    CLKIN,

      // SRDY pulses for one clock cycle after the MMCM_ADV is locked and the 
      // MMCM_DRP module is ready to start another re-configuration
      output   SRDY,
      
      // These are the clock outputs from the MMCM_ADV.
      output   CLK0OUT,
      output   CLK1OUT
   );
   
   // These signals are used as direct connections between the MMCM_ADV and the
   // MMCM_DRP.
   wire [15:0]    di;
   wire [6:0]     daddr;
   wire [15:0]    dout;
   wire           den;
   wire           dwe;
   wire           dclk;
   wire           rst_mmcm;
   wire           drdy;
   wire           locked;
   
   // These signals are used for the BUFG's necessary for the design.
   wire           clkin_bufgout;
   
   wire           clkfb_bufgout;
   wire           clkfb_bufgin;
   
   wire           clk0_bufgin;
   wire           clk0_bufgout;
   
   wire           clk1_bufgin;
   wire           clk1_bufgout;
   
   wire           clk2_bufgin;
   wire           clk2_bufgout;
   
   wire           clk3_bufgin;
   wire           clk3_bufgout;
   
   wire           clk4_bufgin;
   wire           clk4_bufgout;
   
   wire           clk5_bufgin;
   wire           clk5_bufgout;
   
   wire           clk6_bufgin;
   wire           clk6_bufgout;

   // Global buffers used in design
   BUFG BUFG_IN (
      .O(clkin_bufgout),
      .I(CLKIN) 
   );
   
   BUFG BUFG_FB (
      .O(clkfb_bufgout),
      .I(clkfb_bufgin) 
   );
   
   BUFG BUFG_CLK0 (
      .O(CLK0OUT),
      .I(clk0_bufgin) 
   );
   
   BUFG BUFG_CLK1 (
      .O(CLK1OUT),
      .I(clk1_bufgin) 
   );
   
   
   // MMCM_ADV that reconfiguration will take place on
   MMCM_ADV #(
      // "HIGH", "LOW" or "OPTIMIZED"
      .BANDWIDTH("OPTIMIZED"), 
      .CLKOUT4_CASCADE      ("FALSE"),
	  
      .DIVCLK_DIVIDE(1), // (1 to 52)
      
      .CLKFBOUT_MULT_F(5), 
      .CLKFBOUT_PHASE(0.0),
      .CLKFBOUT_USE_FINE_PS("FALSE"),

      // Set the clock period (ns) of input clocks
      .CLKIN1_PERIOD(5.000), 
      .REF_JITTER1(0.010),

      // CLKOUT parameters:
      // DIVIDE: (1 to 128)
      // DUTY_CYCLE: (0.01 to 0.99) - This is dependent on the divide value.
      // PHASE: (0.0 to 360.0) - This is dependent on the divide value.
      // USE_FINE_PS: (TRUE or FALSE)

      .CLKOUT0_DIVIDE_F(10), 
      .CLKOUT0_DUTY_CYCLE(0.5), 
      .CLKOUT0_PHASE(0.0), 
      .CLKOUT0_USE_FINE_PS("FALSE"),

      .CLKOUT1_DIVIDE(10), 
      .CLKOUT1_DUTY_CYCLE(0.5), 
      .CLKOUT1_PHASE(0.0),
      .CLKOUT1_USE_FINE_PS("FALSE"),    
      
      // Misc parameters
      .CLOCK_HOLD("FALSE"),
      .COMPENSATION("ZHOLD"),
      .STARTUP_WAIT("FALSE")
   ) mmcm_test_inst (
      .CLKFBOUT(clkfb_bufgin),
      .CLKFBOUTB(),
      
      .CLKFBSTOPPED(),
      .CLKINSTOPPED(),

      // Clock outputs
      .CLKOUT0(clk0_bufgin), 
      .CLKOUT0B(),
      .CLKOUT1(clk1_bufgin),
      .CLKOUT1B(),
	  
      // DRP Ports
      .DO(dout), // (16-bits)
      .DRDY(drdy), 
      .DADDR(daddr), // 5 bits
      .DCLK(dclk), 
      .DEN(den), 
      .DI(di), // 16 bits
      .DWE(dwe), 

      .LOCKED(locked), 
      .CLKFBIN(clkfb_bufgout), 

      // Clock inputs
      .CLKIN1(CLKIN),
      .CLKIN2(),
      .CLKINSEL(1'b1), 

      // Fine phase shifting
      .PSDONE(),
      .PSCLK(1'b0),
      .PSEN(1'b0),
      .PSINCDEC(1'b0),
 
      .PWRDWN(1'b0),
      .RST(rst_mmcm)
   );
   
   // MMCM_DRP instance that will perform the reconfiguration operations
   mmcm_drp #(
      //***********************************************************************
      // State 1 Parameters - These are for the first reconfiguration state.
      //***********************************************************************
      // Set the multiply to 5 with 0 deg phase offset, low bandwidth, input
      // divide of 1
      .S1_CLKFBOUT_MULT(21.0),
      .S1_CLKFBOUT_PHASE(0),
      .S1_BANDWIDTH("LOW"),
      .S1_DIVCLK_DIVIDE(4),
      
      // Set clock out 0 to a divide of 5, 0deg phase offset, 50/50 duty cycle
      .S1_CLKOUT0_DIVIDE(10.5),
      .S1_CLKOUT0_PHASE(00000),
      .S1_CLKOUT0_DUTY(50000),
      
      // Set clock out 1 to a divide of 5, 90deg phase offset, 50/50 duty cycle
      .S1_CLKOUT1_DIVIDE(7),
      .S1_CLKOUT1_PHASE(00000),
      .S1_CLKOUT1_DUTY(50000),
      
      // Set clock out 2 to a divide of 5, 180deg phase offset, 50/50 duty cycle
      .S1_CLKOUT2_DIVIDE(8),
      .S1_CLKOUT2_PHASE(00000),
      .S1_CLKOUT2_DUTY(50000),
      
      // Set clock out 3 to a divide of 5, 270deg phase offset, 50/50 duty cycle
      .S1_CLKOUT3_DIVIDE(7),
      .S1_CLKOUT3_PHASE(00000),
      .S1_CLKOUT3_DUTY(50000),
      
      // Set clock out 4 to a divide of 5, 0deg phase offset, 50/50 duty cycle
      .S1_CLKOUT4_DIVIDE(6),
      .S1_CLKOUT4_PHASE(0),
      .S1_CLKOUT4_DUTY(50000),
      
      // Set clock out 5 to a divide of 6, 0deg phase offset, 50/50 duty cycle
      .S1_CLKOUT5_DIVIDE(5),
      .S1_CLKOUT5_PHASE(0),
      .S1_CLKOUT5_DUTY(50000),
      
      // Set clock out 6 to a divide of 7, 0deg phase offset, 50/50 duty cycle
      .S1_CLKOUT6_DIVIDE(4),
      .S1_CLKOUT6_PHASE(0),
      .S1_CLKOUT6_DUTY(50000),
      
      //***********************************************************************
      // State 2 Parameters - These are for the second reconfiguration state.
      //***********************************************************************
      .S2_CLKFBOUT_MULT(5),
      .S2_CLKFBOUT_PHASE(0),
      .S2_BANDWIDTH("LOW"),
      .S2_DIVCLK_DIVIDE(1),

      // Set clock out 0 to a divide of 8, 0deg phase offset, 50/50 duty cycle
      .S2_CLKOUT0_DIVIDE(8),
      .S2_CLKOUT0_PHASE(0),
      .S2_CLKOUT0_DUTY(50000),
      
      // Set clock out 0 to a divide of 9, 0deg phase offset, 50/50 duty cycle
      .S2_CLKOUT1_DIVIDE(10),
      .S2_CLKOUT1_PHASE(0),
      .S2_CLKOUT1_DUTY(50000),
      
      // Set clock out 0 to a divide of 10, 0deg phase offset, 50/50 duty cycle
      .S2_CLKOUT2_DIVIDE(10),
      .S2_CLKOUT2_PHASE(0),
      .S2_CLKOUT2_DUTY(50000),
      
      // Set clock out 0 to a divide of 11, 0deg phase offset, 50/50 duty cycle
      .S2_CLKOUT3_DIVIDE(11),
      .S2_CLKOUT3_PHASE(0),
      .S2_CLKOUT3_DUTY(50000),
      
      // Set clock out 0 to a divide of 12, 0deg phase offset, 50/50 duty cycle
      .S2_CLKOUT4_DIVIDE(12),
      .S2_CLKOUT4_PHASE(0),
      .S2_CLKOUT4_DUTY(50000),
      
      // Set clock out 0 to a divide of 13, 0deg phase offset, 50/50 duty cycle
      .S2_CLKOUT5_DIVIDE(13),
      .S2_CLKOUT5_PHASE(0),
      .S2_CLKOUT5_DUTY(50000),
      
      // Set clock out 0 to a divide of 14, 0deg phase offset, 50/50 duty cycle
      .S2_CLKOUT6_DIVIDE(14),
      .S2_CLKOUT6_PHASE(0),
      .S2_CLKOUT6_DUTY(50000)
   ) mmcm_drp_inst (
      // Top port connections
      .SADDR(STATE),
      .SEN(SSTEP),
      .RST(RST),
      .SRDY(SRDY),
      
      // Input from IBUFG
      .SCLK(clkin_bufgout),
      
      // Direct connections to the MMCM_ADV
      .DO(dout),
      .DRDY(drdy),
      .LOCKED(locked),
      .DWE(dwe),
      .DEN(den),
      .DADDR(daddr),
      .DI(di),
      .DCLK(dclk),
      .RST_MMCM(rst_mmcm)
   );
endmodule
