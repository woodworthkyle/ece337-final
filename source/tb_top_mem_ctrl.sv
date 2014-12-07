// $Id: $
// File name:   tb_top_mem_ctrl.sv
// Created:     12/7/2014
// Author:      Kyle Woodworth
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Test bench for top level memory controller.

`timescale 1ns / 10ps

module tb_top_mem_ctrl();
  // Parameters for CL = 1 and model -6
	parameter CLK_PERIOD				= 20;
	parameter CL = 1; // Clock latency
	parameter tRP = 18.0;
	parameter tCMH = 1.0;
	parameter tCMS = 1.5;
	parameter tRFC = 60.0;
	parameter tCKH = 1.0;
	parameter tCKS = 1.5;
	parameter tMRD = 2.0*CLK_PERIOD;
	parameter tAH = 1.0;
	parameter tAS = 1.5;
	parameter tRCD = 18.0;
	parameter tDH = 1.0;
	parameter tDS = 1.5;
	parameter tWR = 12.0;
	
	//
  // Input test signals
  //
  // AHB Signals
  reg tb_HCLK;
  reg tb_HRESETn;
  reg [31:0] tb_HADDR;
  reg [2:0] tb_HBURST;
  reg [3:0] tb_HPROT;
  reg [2:0] tb_HSIZE;
  reg [1:0] tb_HTRANS;
  reg [31:0] tb_HWDATA;
  reg tb_HWRITE;
  reg tb_HREADYIN;
  reg tb_HSEL;
  reg [31:0] tb_HRDATA;
  reg tb_HRESP;
  reg tb_HREADYOUT;
  
  // SDRAM Signals
  reg [31:0] tb_MEM_RDATA;
  reg [31:0] tb_MEM_WDATA;
  reg [11:0] tb_MEM_ADDR;
  reg [1:0] tb_MEM_BA;
  reg tb_MEM_CKE;
  reg tb_MEM_CSn;
  reg tb_MEM_RASn;
  reg tb_MEM_CASn;
  reg tb_MEM_WEn;
  reg [3:0] tb_MEM_DQM;
  reg tb_MEM_WRITE;
  int tb_refresh_count;
  reg tb_refresh;
  
  // Output test signals
  wire tb_MEM_CLK;
  
  // Custom structs/enums/unions
  
  // ENUM for test stages
  typedef enum {
    INIT_VARIABLES,
    POR,
    INIT_SDRAM,
    WRITE,
    READ,
    
    REFRESH
  } TestStages;
  
  TestStages tb_stage;
  
  // Clock generations
	always begin : CLK_GEN
		tb_HCLK = 1'b0;
		#(CLK_PERIOD / 2);
		tb_HCLK = 1'b1;
		#(CLK_PERIOD / 2);
    tb_refresh_count++;
    if(tb_refresh_count == 750) begin
      tb_refresh = 1'b1;
      tb_refresh_count = 0;
    end
	end
	
	/*
	always @(tb_refresh) begin
	  tb_refresh = 1'b0;
	end
  */
  
  // Create DUTs
	top_mem_ctrl MEM_CTRL
	(
	 // AHB-Lite Interface signals
    .HCLK(tb_HCLK),
    .HRESETn(tb_HRESETn),
    .HADDR(tb_HADDR),
    .HBURST(tb_HBURST),
    .HPROT(tb_HPROT),
    .HSIZE(tb_HSIZE),
    .HTRANS(tb_HTRANS),
    .HWDATA(tb_HWDATA),
    .HWRITE(tb_HWRITE),
    .HREADYIN(tb_HREADYIN),
    .HSEL(tb_HSEL),
    .HRDATA(tb_HRDATA),
    .HRESP(tb_HRESP),
    .HREADYOUT(tb_HREADYOUT),
    
    // SDRAM Interface signals
    .MEM_RDATA(tb_MEM_RDATA),
    .MEM_WDATA(tb_MEM_WDATA),
    .MEM_ADDR(tb_MEM_ADDR),
    .MEM_BA(tb_MEM_BA),
    .MEM_CLK(tb_MEM_CLK),
    .MEM_CKE(tb_MEM_CKE),
    .MEM_CSn(tb_MEM_CSn),
    .MEM_RASn(tb_MEM_RASn),
    .MEM_CASn(tb_MEM_CASn),
    .MEM_WEn(tb_MEM_WEn),
    .MEM_DQM(tb_MEM_DQM)
	);
	
	sdram DUT_SDRAM
	(
	  .DQi(tb_MEM_WDATA),
	  .ADDR(tb_MEM_ADDR),
	  .BA(tb_MEM_BA),
	  .CLK(tb_HCLK),
	  .CKE(tb_MEM_CKE),
	  .CSn(tb_MEM_CSn),
	  .RASn(tb_MEM_RASn),
	  .CASn(tb_MEM_CASn),
	  .WEn(tb_MEM_WEn),
	  .write(tb_MEM_WRITE),
	  .DQM(tb_MEM_DQM),
	  .DQo(tb_MEM_RDATA)
	);
	
  // Begin test execution
  initial begin
    // Initial values
    tb_stage = INIT_VARIABLES;
    tb_refresh = 1'b0;
    tb_MEM_WRITE = 1'b1;
    tb_HRESETn = 1'b0;
    tb_HADDR = 32'h00000000;
    tb_HBURST = 3'b000;
    tb_HPROT = 4'b0000;
    tb_HSIZE = 3'b000;
    tb_HTRANS = 2'b00;
    tb_HWDATA = 32'h00000000;
    tb_HWRITE = 1'b0;
    tb_HREADYIN = 1'b1;
    tb_HSEL = 1'b1;
    
    // POR
    @(negedge tb_HCLK);
    tb_stage = POR;
    tb_HRESETn = 1'b0;
    
    // Wait for SDRAM initialization
    @(negedge tb_HCLK);
    tb_stage = INIT_SDRAM;
    tb_HRESETn = 1'b1;
    waitCycles(2501);
    waitCycles(1);
    waitCycles(2501);
    waitCycles(15);
    
    // Write sequential 20 words
    @(negedge tb_HCLK);
    tb_stage = WRITE;
    writeSimple();
    
    // Read 5 words in middle of write (10-15)
    // - First read should be miss
    // - Second to fifth read should be hit
    @(negedge tb_HCLK);
    tb_stage = READ;
    
    
    // Read from 0 to 10
    // - First and 8th read should be miss
    @(negedge tb_HCLK);
    tb_stage = READ;
    
    @(posedge tb_refresh);
    tb_stage = REFRESH;
    
  end
  
  // Tasks and functions
	task waitCycles(int unsigned x);
	  for(int i = 0; i < x; i++)
	    @(posedge tb_HCLK);
  endtask: waitCycles
  
  task writeSimple();
    for (int lcv = 0; lcv < 20; lcv++) begin
      while(!tb_HREADYOUT) begin
        waitCycles(1);
      end
      //@(posedge tb_HREADYOUT);
      // Send data
      tb_HADDR = lcv;
      // Send address
      tb_HWDATA = lcv;
      // Enable write
      tb_HWRITE = 1'b1;
      // 
      tb_HREADYIN = 1'b1;
      tb_HSEL = 1'b1;
      waitCycles(1);
    end
    
    /*
    // wait for bus to be ready
    @(posedge tb_HREADYOUT);
    // Send data
    tb_HADDR = addr;
    // Send address
    tb_HWDATA = data;
    // Enable write
    tb_HWRITE = 1'b1;
	  */
  endtask
  
  
endmodule