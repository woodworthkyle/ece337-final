// $Id: $
// File name:   top_mem_ctrl.sv
// Created:     11/30/2014
// Author:      Kyle Woodworth
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Top Level module for the memory controller

module top_mem_ctrl
  (
    // AHB-Lite Interface signals
    input wire HCLK,
    input wire HRESETn,
    input wire [31:0] HADDR,
    input wire [2:0] HBURST,
    input wire [3:0] HPROT,
    input wire [2:0] HSIZE,
    input wire [1:0] HTRANS,
    input wire [31:0] HWDATA,
    input wire HWRITE,
    input wire HREADYIN,
    input wire HSEL,
    output wire [31:0] HRDATA,
    output wire HRESP,
    output wire HREADYOUT,
    
    // SDRAM Interface signals
    input wire [31:0] MEM_RDATA,
    output wire [31:0] MEM_WDATA,
    output wire [11:0] MEM_ADDR,
    output wire [1:0] MEM_BA,
    output wire MEM_CLK,
    output wire MEM_CKE,
    output wire MEM_CSn,
    output wire MEM_RASn,
    output wire MEM_CASn,
    output wire MEM_WEn,
    output wire[3:0] MEM_DQM
    //output MEM_WRITE
    
  );

  // Signal telling the memor controller to enable
  wire MEM_CTRL_ENABLE;
  // Signal telling the memory controller to enter write mode
  wire MEM_CTRL_W_EN;
  // Signal telling the memory controller to enter read mode
  wire MEM_CTRL_R_EN;
  // Signal telling the AHB-Lite interface that we are busy
  wire MEM_CTRL_BUSYn;
  // Address signal for memory controller to use
  wire [11:0] MEM_CTRL_ADDR;
  // Signal telling the memory controller to refresh the SDRAM
  wire MEM_CTRL_REFRESH;
  // Bank address signal for memory controller
  wire [1:0] MEM_CTRL_BA;
  
  // Cache signals
  wire c_addr_en;
  wire [11:0] c_addr_in;
  wire [31:0] c_data_in;
  wire c_w_en;
  wire [2:0] c_w_ptr;
  wire c_r_en;
  wire [2:0] c_r_ptr;
  wire [11:0] c_addr_out;
  wire [31:0] c_data_out;
  
  // Timer signals
  wire tim_clear;
  wire tim_EN;
  wire [11:0] tim_ro_value;
  wire [11:0] tim_out;
  wire rollover_flag;
  
  
  // AHB-Lite Slave interface
  ahb AHB_SLAVE
  (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HREADYIN(HREADYIN),
    .HSEL(HSEL),
    .HADDR(HADDR),
    .BUSYn(MEM_CTRL_BUSYn),
    .HRDATA_R(c_data_out),
    .HWRITE(HWRITE),
    .ENABLE(MEM_CTRL_ENABLE),
    .MEM_BA(MEM_CTRL_BA),
    .MEM_ADDR(MEM_CTRL_ADDR),
    .HREADYOUT(HREADYOUT),
    .HRDATA(HRDATA),
    .W_EN(MEM_CTRL_W_EN),
    .R_EN(MEM_CTRL_R_EN)
  );
  
  // Cache block
  cache CACHE
  (
    .clk(HCLK),
    .n_rst(HRESETn),
    .addr_enable(c_addr_en),
    .addr_in(c_addr_in),
    .data_in(c_data_in),
    .write_enable(c_w_en),
    .write_pointer(c_w_ptr),
    .read_enable(c_r_en),
    .read_pointer(c_r_ptr),
    .addr_out(c_addr_out),
    .data_out(c_data_out) 
  );
  
  // Initialization and refresh counter
  // Initialization needs a 100 us power up time. 100 us at 20 ns clock rate
  // would take 5000 cycles. However, the CKE signal and a NOP command need 
  // to be sent to the SDRAM sometime before the end of the 100 us. Cutting
  // the 5000 cycles down to 2500 cycles allows us to wait 50 us assert CKE 
  // and the NOP command, then wait 50 us for a proper power up. The refresh
  // process needs to be executed either every 64 ms (full refresh) or 15.625 us
  // (single refresh). Obviously 64 ms requires a massive counter, and 15.625 us 
  // will take less cycles that 100 us used for initialization.
  // Summary:
  // We need at least a 12 bit counter
  flex_counter #(12) INIT_REFRESH_TIMER
  (
    .clk(HCLK),
    .n_rst(HRESETn),
    .clear(tim_clear),
    .count_enable(tim_EN),
    .rollover_val(tim_ro_value),
    .count_out(tim_out),
    .rollover_flag(rollover_flag)
  ); 

   
   
  // The memory controller
  memcontrol MEM_CONTROLLER
  (
    .hclk(HCLK),
    .nrst(HRESETn),
    .target_ba(MEM_CTRL_BA),
    .target_addr(MEM_CTRL_ADDR),
    .enable(MEM_CTRL_ENABLE),
    .w_en(MEM_CTRL_W_EN),
    .r_en(MEM_CTRL_R_EN),
    .c_addr_o(c_addr_out),
    .rollover_flag(rollover_flag),
    .c_addr_en(c_addr_en),
    .c_addr_i(c_addr_in),
    .c_w_en(c_w_en),
    .c_w_addr(c_w_ptr),
    .c_r_en(c_r_en),
    .c_r_addr(c_r_ptr),
    .BUSYn(MEM_CTRL_BUSYn),
    .mem_ba(MEM_BA),
    .mem_addr(MEM_ADDR),
    .mem_cke(MEM_CKE),
    .mem_CSn(MEM_CSn),
    .mem_RASn(MEM_RASn),
    .mem_CASn(MEM_CASn),
    .mem_WEn(MEM_WEn),
    //.mem_DQM(),
    //.mem_write(),
    .tim_clear(tim_clear),
    .tim_EN(tim_EN),
    .tim_ro_value(tim_ro_value)
  );
  
endmodule
