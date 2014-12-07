// $Id: $
// File name:   tb_memcontrol.sv
// Created:     11/6/2014
// Author:      Christopher Pratt
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: TESTBENCH: SDRAM Memory Controller (AHB-Lite interface)

`timescale 1ns / 10ps

module tb_memcontrol();
  
  //System Clock Generation 
  //50 MHz 
  localparam CLK_PERIOD = 20;
  reg tb_hclk;
  
	always
	begin
		tb_hclk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_hclk = 1'b1;   
		#(CLK_PERIOD/2.0);
	end  
  
  reg tb_nrst;
  reg tb_rollover_flag;
  reg [1:0] tb_target_ba;
  reg [11:0]tb_target_addr;
  reg tb_enable;
  reg tb_w_en;
  reg tb_r_en;
  reg [11:0]tb_c_addr_o;
  reg tb_c_addr_en;
  reg [11:0]tb_c_addr_i;
  reg tb_c_w_en;
  reg [2:0]tb_c_w_addr;
  reg tb_c_r_en;
  reg [2:0]tb_c_r_addr;
  reg tb_BUSYn;
  reg [1:0] tb_mem_ba;
  reg [11:0]tb_mem_addr;
  reg tb_mem_cke;
  reg tb_mem_CSn;
  reg tb_mem_RASn;
  reg tb_mem_CASn;
  reg tb_mem_WEn;
  reg tb_tim_clear;
  reg tb_tim_EN;
  reg [11:0]tb_tim_ro_value;
  
  memcontrol DUT(
    .hclk(tb_hclk),
    .nrst(tb_nrst),
    .target_ba(tb_target_ba),
    .target_addr(tb_target_addr),
    .enable(tb_enable),
    .w_en(tb_w_en),
    .r_en(tb_r_en),
    .c_addr_o(tb_c_addr_o),
    .rollover_flag(tb_rollover_flag),
    .c_addr_en(tb_c_addr_en),
    .c_addr_i(tb_c_addr_i),
    .c_w_en(tb_c_w_en),
    .c_w_addr(tb_c_w_addr),
    .c_r_en(tb_c_r_en),
    .c_r_addr(tb_c_r_addr),
    .BUSYn(tb_BUSYn),
    .mem_ba(tb_mem_ba),
    .mem_addr(tb_mem_addr),
    .mem_cke(tb_mem_cke),
    .mem_CSn(tb_mem_CSn),
    .mem_RASn(tb_mem_RASn),
    .mem_CASn(tb_mem_CASn),
    .mem_WEn(tb_mem_WEn),
    .tim_clear(tb_tim_clear),
    .tim_EN(tb_tim_EN),
    .tim_ro_value(tb_tim_ro_value)
  );
  
  initial
  begin    
  // Test Initialization
  // Input initialization for stability
  tb_rollover_flag = 1'b0;
  tb_target_ba = 2'b00;
  tb_target_addr = 12'b000000000000;
  tb_enable = 1'b1;                     
  tb_w_en = 1'b0;
  tb_r_en = 1'b0;
  tb_c_addr_o = 12'b000000000000;
  
  // Reset to known state
  tb_nrst = 1'b0;
  #(20);
  tb_nrst = 1'b1;
  
  // Rollover timer simulation
  // Rollover flag for INIT_WAIT1 state
  #(50000);
  tb_rollover_flag = 1'b1;
  #(20);
  tb_rollover_flag = 1'b0;
  // Rollover flag for INIT_WAIT2 state
  #(50000);
  tb_rollover_flag = 1'b1;
  #(20);
  tb_rollover_flag = 1'b0;
  // Rollover flag for INIT_WAIT4 
  // (after INIT_PRE_C, INIT_WAIT3, AND INIT_AUTO_R1) state
  #(100);
  tb_rollover_flag = 1'b1;
  #(20);
  tb_rollover_flag = 1'b0;
  // Rollover flag for INIT_WAIT5 (after INIT_AUTO_R2) state
  #(60);
  tb_rollover_flag = 1'b1;
  #(20);
  tb_rollover_flag = 1'b0;
  
  // Avtive Idle State
  // Start Normal Operation Simulation
  // Test Write
  @(posedge tb_BUSYn);
  #(40);
  tb_target_addr = 12'b101000001111;
  tb_w_en = 1'b1;
  #(30);
  tb_w_en = 1'b0;
  
  // Test Read - Miss 
  @(posedge tb_BUSYn);
  #(40);
  tb_target_addr = 12'b101011001001;
  tb_r_en = 1'b1;
  #(30);
  tb_r_en = 1'b0;

  // Test Read - hit   
  @(posedge tb_BUSYn);
  #(40);
  tb_c_addr_o = 12'b101011000110;
  tb_target_addr = 12'b101011001001;
  tb_r_en = 1'b1;
  #(30);
  tb_r_en = 1'b0;
  
  end
  
endmodule
           
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
     
