// $Id: $
// File name:   tb_top_mem_ctrl.sv
// Created:     12/7/2014
// Author:      Cody Allen, Kyle Woodworth
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
	
	int lcv = 0;
	
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
  int tb_r_goldAddr [0:19];
  int tb_r_sampAddr [0:19];
  int tb_r_goldData [0:19];
  int tb_r_sampData [0:19];
  int tb_w_goldAddr [0:19];
  int tb_w_sampAddr [0:19];
  int tb_w_goldData [0:19];
  int tb_w_sampData [0:19];  
  
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
    readSimple();
    
    // Read from 0 to 10
    // - First and 8th read should be miss
    //@(negedge tb_HCLK);
    //tb_stage = READ;
    
    //@(posedge tb_refresh);
    //tb_stage = REFRESH;
    
  end
  
  // Tasks and functions
	task waitCycles(int unsigned x);
	  for(int i = 0; i < x; i++)
	    @(posedge tb_HCLK);
  endtask: waitCycles
  
  task writeSimple();
    tb_w_goldAddr = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
               11, 12, 13, 14, 15, 16, 17 ,18, 19};
    tb_w_goldData = {7, 24, 92, 2, 99, 24, 47, 32, 6, 22,
                        58, 53, 33, 8, 9, 3, 16, 62, 20, 6};
    for ( lcv = 0; lcv < 20; lcv++) begin
      while(!tb_HREADYOUT) begin
        waitCycles(1);
      end
      // Send address
      tb_HADDR = tb_w_goldAddr[lcv];
      // Send data
      tb_HWDATA = tb_w_goldData[lcv];
      // Enable write
      tb_HWRITE = 1'b1;
      tb_HREADYIN = 1'b1;
      tb_HSEL = 1'b1;
      waitCycles(1);
      #(5);
      tb_w_sampAddr[lcv] = tb_MEM_ADDR;
      tb_w_sampData[lcv] = tb_MEM_WDATA; 
      assert (tb_w_sampAddr[lcv] == tb_w_goldAddr[lcv]) $display ("WRITE Test sample address %d, successful", lcv);
        else $error("WRITE Test sample address %d, unsucessful", lcv);
      assert (tb_w_sampData[lcv] == tb_w_goldData[lcv]) $display ("WRITE Test sample data %d, successful", lcv);
        else $error("WRITE Test sample data %d, unsucessful", lcv);    
    end

  endtask
  
  task readSimple();
    tb_r_goldAddr = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
               21, 22, 23, 24, 25, 26, 27 ,28, 29};
    tb_r_goldData = {7, 24, 92, 2, 99, 24, 47, 32, 6, 22,
                        58, 53, 33, 8, 9, 3, 16, 62, 20, 6};
    // POPULATE CACHE WITH A MISS
    
    // Send address
    tb_HADDR = tb_r_goldAddr[1];
    // Enable read
    tb_HWRITE = 1'b0;
    tb_HREADYIN = 1'b1; 
    tb_HSEL = 1'b1;
    // Wait for bus to be ready
    while(!tb_HREADYOUT) begin
      waitCycles(1);
    end
    waitCycles(3);
    // ...Populating... 
    for (lcv = 1; lcv <= 8; lcv ++) begin
      @(negedge tb_HCLK);
      tb_MEM_RDATA = tb_r_goldData[lcv];
    end
    waitCycles(3);
    lcv = 1;
    tb_r_sampAddr[lcv] = tb_MEM_ADDR;
    tb_r_sampData[lcv] = tb_HRDATA;
    
    assert (tb_r_sampData[lcv] == tb_r_goldData[lcv]) $display ("READ Test sample data %d, successful", lcv);
      else $error("READ Test sample data %d, unsucessful %d != %d", lcv, tb_r_sampData[lcv], tb_r_goldData[lcv]);
    
    // SIMULATE HITS BY READING FROM CACHE
    for ( lcv = 2; lcv <= 8; lcv++) begin
      while(!tb_HREADYOUT) begin
        waitCycles(1);
      end
      // Send address
      tb_HADDR = tb_r_goldAddr[lcv];
      // Enable read
      tb_HWRITE = 1'b0;
      tb_HREADYIN = 1'b1; 
      tb_HSEL = 1'b1;
      waitCycles(1);
      #(5);
      tb_r_sampAddr[lcv] = tb_MEM_ADDR;
      tb_r_sampData[lcv] = tb_HRDATA; 
      assert (tb_r_sampData[lcv] == tb_r_goldData[lcv]) $display ("READ Test sample data %d, successful", lcv);
        else $error("READ Test sample data %d, unsucessful %d != %d", lcv, tb_r_sampData[lcv], tb_r_goldData[lcv]);    
    end

  endtask
  
  
endmodule