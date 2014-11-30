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
    
    // SDRAM Interface signals
    input MEM_RDATA[31:0],
    output MEM_ADDR[11:0],
    output MEM_WDATA[31:0],
    output MEM_CKE,
    output MEM_CSn,
    output MEM_RASn,
    output MEM_CASn,
    output MEM_WEn
    
  );
  
  ahb AHB_SLAVE
  (
    .HREADYIN()
    .HSEL(),
    .HADDR(),
    .BUSYn(),
    .HRDATA_R(),
    .HWRITE(),
    .ENABLE(),
    .MEM_ADDR(),
    .HREADYOUT(),
    .HRDATA(),
    .W_EN(),
    .R_EN()
  );
  
  cache CACHE
  (
    .clk(),
    .n_rst(),
    .addr_enable(),
    .addr_in(),
    .data_in(),
    .write_enable(),
    .write_pointer(),
    .read_enable(),
    .read_pointer(),
    .addr_out(),
    .data_out() 
  );
  
  
  flex_counter TIMER
  (
    
  );
  
  memcontrol MEM_CONTROLLER
  (
    .hclk(),
    .nrst(),
    .mem_addr(),
    .enable(),
    .w_en(),
    .r_en(),
    .c_addr_o(),
    .refresh(),
    .c_addr_en(),
    .c_addr_i(),
    .c_w_en(),
    .c_w_addr(),
    .c_r_en(),
    .c_r_addr(),
    .BUSYn(),
    .mem_addr(),
    .mem_cke(),
    .mem_CSn(),
    .mem_RASn(),
    .mem_CASn(),
    .mem_WEn(),
    .hclk(),
    .tim_RSTn()
  );
  
  
endmodule