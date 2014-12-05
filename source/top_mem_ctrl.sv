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
    input MEM_RDATA[31:0],
    output MEM_ADDR[11:0],
    output MEM_WDATA[31:0],
    output MEM_CKE,
    output MEM_CSn,
    output MEM_RASn,
    output MEM_CASn,
    output MEM_WEn
    
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
  
  // Cache signals
  wire c_addr_en;
  wire c_addr_in;
  wire c_data_in;
  wire c_w_en;
  wire c_w_ptr;
  wire c_r_en;
  wire c_r_ptr;
  wire c_addr_out;
  wire [31:0] c_data_out;
  
  
  // AHB-Lite Slave interface
  ahb AHB_SLAVE
  (
    .HREADYIN(HREADYIN),
    .HSEL(HSEL),
    .HADDR(HADDR),
    .BUSYn(MEM_CTRL_BUSYn),
    .HRDATA_R(c_data_out),
    .HWRITE(HWRITE),
    .ENABLE(MEM_CTRL_ENABLE),
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
    .n_rst(HRSTn),
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
  // the 5000 cyles down to 2500 cycles allows us to wait 50 us assert CKE 
  // and the NOP command, then wait 50 us for a proper power up. The refresh
  // process needs to be executed either every 64 ms (full refresh) or 15.625 us
  // (single refresh). Obviously 64 ms requires a massive counter, and 15.625 us 
  // will take less cycles that 100 us used for initialization.
  // Summary:
  // We need at least a 12 bit counter
  flex_counter INIT_REFRESH_TIMER
  (
    
  ); 

   
   
  // The memory controller
  memcontrol MEM_CONTROLLER
  (
    .hclk(HCLK),
    .nrst(HRSTn),
    .mem_addr(MEM_CTRL_ADDR),
    .enable(MEM_CTRL_ENABLE),
    .w_en(MEM_CTRL_W_EN),
    .r_en(MEM_CTRL_R_EN),
    .c_addr_o(c_addr_out),
    .refresh(MEM_CTRL_REFRESH),
    .c_addr_en(c_addr_en),
    .c_addr_i(c_addr_in),
    .c_w_en(c_w_en),
    .c_w_addr(c_w_ptr),
    .c_r_en(c_r_en),
    .c_r_addr(c_r_ptrs),
    .BUSYn(MEM_CTRL_BUSYn),
    .mem_addr_o(MEM_ADDR),
    .mem_cke(MEM_CKE),
    .mem_CSn(MEM_CSn),
    .mem_RASn(MEM_RASn),
    .mem_CASn(MEM_CASn),
    .mem_WEn(MEM_WEn)
  );
  
  
endmodule
