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
	parameter INPUT_FILENAME = "./docs/input.bin";
	parameter MEMDUMP_FILENAME = "./docs/memdump.log";
	parameter addr_bits =      12;
  parameter data_bits =      32;
  parameter col_bits  =       8;
  parameter mem_sizes = 1048575;
	
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
  int tb_goldAddr [0:19];
  int tb_goldData [0:19];
  
  // SDRAM memory
  reg       [data_bits - 1 : 0] Bank0 [0 : mem_sizes];
  reg       [data_bits - 1 : 0] Bank1 [0 : mem_sizes];
  reg       [data_bits - 1 : 0] Bank2 [0 : mem_sizes];
  reg       [data_bits - 1 : 0] Bank3 [0 : mem_sizes];
  
  // Cycle counter
  reg tb_count_enable;
  int tb_count_clk;
  
  // Output test signals
  wire tb_MEM_CLK;
  
  // File handle variables
  integer in_file;
  integer res_file;
  
  //
  // Custom structs/enums/unions
  //
  
  // ENUM for test stages
  typedef enum {
    STAGE_INIT_VARIABLES,
    STAGE_POR,
    STAGE_INIT_SDRAM,
    STAGE_WRITE_SINGLE,
    STAGE_WRITE,
    STAGE_READ_LOAD_CACHE,
    STAGE_READ_HIT,
    STAGE_READ_MISS,
    
    STAGE_IDLE,
    STAGE_REFRESH
  } TestStages;
  TestStages tb_stage;
  
  // ENUM for SDRAM op codes
  typedef enum {
    INHIBIT,
    NOP,
    ACTIVE,
    AUTO_REFRESH,
    LMR,
    PRECHARGE,
    READ,
    WRITE,
    BURST_TERM,
    
    UNKNOWN
  } OpCode;
  OpCode tb_op;
  
  // Command input
  wire [3:0] tb_cmd = {tb_MEM_CSn, tb_MEM_RASn, tb_MEM_CASn, tb_MEM_WEn};
  wire [3:0] CMD_INHIBIT = 4'b1111;
  wire [3:0] CMD_NOP = 4'b0111;
  wire [3:0] CMD_ACTIVE = 4'b0011;
  wire [3:0] CMD_AUTO_REFRESH = 4'b0001;
  wire [3:0] CMD_LMR = 4'b000;
  wire [3:0] CMD_PRECHARGE = 4'b0010;
  wire [3:0] CMD_READ = 4'b0101;
  wire [3:0] CMD_WRITE = 4'b0100;
  wire [3:0] CMD_BURST_TERM = 4'b0110;
  
  
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
	
	always @(tb_cmd) begin
	  case(tb_cmd)
      CMD_INHIBIT: begin
        tb_op = INHIBIT;
      end
      CMD_NOP: begin
        tb_op = NOP;
      end
      CMD_ACTIVE: begin
        tb_op = ACTIVE;
      end
      CMD_AUTO_REFRESH: begin
        tb_op = AUTO_REFRESH;
      end
      CMD_LMR: begin
        tb_op = LMR;
      end
      CMD_PRECHARGE: begin
        tb_op = PRECHARGE;
      end
      CMD_READ: begin
        tb_op = READ;
      end
      CMD_WRITE: begin
        tb_op = WRITE;
      end
      CMD_BURST_TERM: begin
        tb_op = BURST_TERM;
      end
      default: begin
        tb_op = UNKNOWN;
      end
    endcase
	end
	
	always @(posedge tb_HCLK) begin
	  if(tb_count_enable == 1'b1) begin
	    tb_count_clk++;
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
	
	/*
	sdram SDRAM
	(
	  .DQi(tb_MEM_WDATA),
	  .ADDR(tb_MEM_ADDR),
	  .BA(tb_MEM_BA),
	  .CLK(tb_MEM_CLK),
	  .CKE(tb_MEM_CKE),
	  .CSn(tb_MEM_CSn),
	  .RASn(tb_MEM_RASn),
	  .CASn(tb_MEM_CASn),
	  .WEn(tb_MEM_WEn),
	  .write(tb_MEM_WRITE),
	  .DQM(tb_MEM_DQM),
	  .DQo(tb_MEM_RDATA)
	);
	*/
	
  // Begin test execution
  initial begin
    // Initial values
    tb_stage = STAGE_INIT_VARIABLES;
    tb_refresh = 1'b0;
    tb_MEM_WRITE = 1'b1;
    tb_MEM_RDATA = 32'h00000000;
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
    tb_goldAddr = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
                   11, 12, 13, 14, 15, 16, 17 ,18, 19};
    tb_goldData = {7, 24, 92, 2, 99, 24, 47, 32, 6, 22,
                   58, 53, 33, 8, 9, 3, 16, 62, 20, 6};
    tb_count_clk = 0;
    
    // Open the input and output file in binary mode
    in_file = $fopen(INPUT_FILENAME, "rb");
    res_file = $fopen(MEMDUMP_FILENAME, "wb");
    
    // POR
    @(negedge tb_HCLK);
    tb_stage = STAGE_POR;
    tb_HRESETn = 1'b0;
    
    // Wait for SDRAM initialization
    @(negedge tb_HCLK);
    tb_stage = STAGE_INIT_SDRAM;
    tb_HRESETn = 1'b1;
    waitCycles(2501);
    waitCycles(1);
    waitCycles(2501);
    waitCycles(15);
    
    // Write single word
    @(negedge tb_HCLK);
    tb_stage = STAGE_WRITE_SINGLE;
    tb_refresh_count = 0;
    writeSingleCheck(tb_goldAddr[0], tb_goldData[0]);
    
    // Write sequential 20 words
    @(negedge tb_HCLK);
    tb_stage = STAGE_WRITE;
    startClkCounter();
    for(int i = 0; i < 20; i++) begin
      writeCheck(tb_goldAddr[i], tb_goldData[i]);
    end
    $display("Write sequential %d: ", 20);
    stopClkCounter();
    
    //writeSimple();
    
    // Read 5 words in middle of write (10-15)
    // - First read should be miss
    // - Second to fifth read should be hit
    @(negedge tb_HCLK);
    tb_stage = STAGE_READ_LOAD_CACHE;
    startClkCounter();
    $display("Load cache starting at address 11");
    readCheck(tb_goldAddr[11], tb_goldData[11]);
    $display("Load cache cycles: ");
    stopClkCounter();
    
    tb_stage = STAGE_READ_HIT;
    startClkCounter();
    $display("Check cache hit at address 15");
    readCheck(tb_goldAddr[15], tb_goldData[15]);
    $display("Cache hit cycles: ");
    stopClkCounter();
    
    tb_stage = STAGE_READ_MISS;
    startClkCounter();
    $display("Check cache miss at address 2");
    readCheck(tb_goldAddr[2], tb_goldData[2]);
    $display("Cache miss cycles: ");
    stopClkCounter();
    
    // Write file to SDRAM byte by byte
    while(!$feof(in_file)) begin
      $display($fgetc(in_file));
    end
    
    
    // Read file from SDRAM byte by byte
    
    
    @(negedge tb_HCLK);
    // Deselect slave from AHB-Lite
    tb_stage = STAGE_IDLE;
    tb_HSEL = 1'b0;
  end
  
  // Tasks and functions
	task waitCycles(int unsigned x);
	  for(int i = 0; i < x; i++)
	    @(posedge tb_HCLK);
  endtask: waitCycles
  
  task writeSingleCheck(input [31:0] addr, input [31:0] data);
    startClkCounter();
    writeCheck(addr, data);
    $display("Write single: ");
    stopClkCounter();
  endtask
  
  task writeCheck(input [31:0] addr, input [31:0] data);
    // Wait for bus to be ready
    if(tb_HREADYOUT != 1'b1)
      @(posedge tb_HREADYOUT);
    
    // Enable write
    tb_HWRITE = 1'b1;
    tb_HREADYIN = 1'b1;
    tb_HSEL = 1'b1;
    // Send address
    tb_HADDR = addr;
    // Send data
    tb_HWDATA = data;
    
    // Make sure the memory controller tells the AHB-Lite bus that we are busy
    //@(negedge tb_HCLK);
    @(negedge tb_HREADYOUT);
    
    // Check ACTIVE command
    @(negedge tb_HCLK);
    assert(tb_cmd == CMD_ACTIVE)
      $display("Successfully enters ACTIVE");
    else
      $error("Unsuccessful write sequence at ACTIVE");
    
    // Check WRITE command
    @(negedge tb_HCLK);
    assert(tb_cmd == CMD_WRITE)
      $display("Successfully enters WRITE");
    else
      $error("Unsuccessful write sequence at WRITE");
    
    // Check for correct output address
    assert(tb_MEM_BA == tb_HADDR[13:12] && tb_MEM_ADDR == tb_HADDR[11:0])
      $display("Successfully sent correct  BA: %d ADDR: %d", tb_MEM_BA, tb_MEM_ADDR);
    else
      $error("Unsuccessful send BA: %d != %d ADDR: %d != %d", tb_HADDR[13:12], tb_MEM_BA, tb_HADDR[11:0], tb_MEM_ADDR);
    // Check for correct output data
    assert(tb_MEM_WDATA == tb_HWDATA)
      $display("Successfully sent correct  DATA: %d", tb_MEM_WDATA);
    else
      $error("Unsuccessful send DATA: %d != %d", tb_HWDATA, tb_MEM_WDATA);
    
    // Now actually write to SDRAM
    // Row address is tb_MEM_ADDR during the ACTIVE command
    // Col address is tb_MEM_ADDR during the WRITE command
    // Should be sending BA, row address, and column address, and data
    writeSDRAM(tb_MEM_BA, tb_MEM_ADDR, tb_MEM_WDATA);
    
    // Check BURST TERMINATE command
    @(negedge tb_HCLK);
    assert(tb_cmd == CMD_BURST_TERM)
      $display("Successfully enters BURST TERMINATE");
    else
      $error("Unsuccessful write sequence at BURST TERMINATE");
      
    // Check PRECHARGE command
    @(negedge tb_HCLK);
    assert(tb_cmd == CMD_PRECHARGE)
      $display("Successfully enters PRECHARGE");
    else
      $error("Unsuccessful write sequence at PRECHARGE");
  endtask
  
  task readCheck(input [31:0] addr, input [31:0] data);
    // Wait for bus to be ready
    if(tb_HREADYOUT != 1'b1)
      @(posedge tb_HREADYOUT);
    
    // Enable read
    tb_HWRITE = 1'b0;
    tb_HREADYIN = 1'b1;
    tb_HSEL = 1'b1;
    // Send address
    tb_HADDR = addr;
    
    // Make sure the memory controller tells the AHB-Lite bus that we are busy
    //@(negedge tb_HCLK);
    @(negedge tb_HREADYOUT);
    
    // Wait for hit/miss check
    @(negedge tb_HCLK);
    
    // Check ACTIVE command and HIT condition
    @(negedge tb_HCLK);
    if(tb_HREADYOUT == 1'b1) begin
      $display("Cache HIT!");
      return;
    end
    
    assert(tb_cmd == CMD_ACTIVE)
      $display("Successfully enters ACTIVE");
    else
      $error("Unsuccessful read sequence at ACTIVE");
    
    // Check READ command
    @(negedge tb_HCLK);
    assert(tb_cmd == CMD_READ)
      $display("Successfully enters READ");
    else
      $error("Unsuccessful read sequence at READ");
      
    // Make data available
    tb_MEM_RDATA = tb_goldData[addr];
    @(negedge tb_HCLK);
    tb_MEM_RDATA = tb_goldData[addr+1];
    @(negedge tb_HCLK);
    tb_MEM_RDATA = tb_goldData[addr+2];
    @(negedge tb_HCLK);
    tb_MEM_RDATA = tb_goldData[addr+3];
    @(negedge tb_HCLK);
    tb_MEM_RDATA = tb_goldData[addr+4];
    @(negedge tb_HCLK);
    tb_MEM_RDATA = tb_goldData[addr+5];
    @(negedge tb_HCLK);
    tb_MEM_RDATA = tb_goldData[addr+6];
    @(negedge tb_HCLK);
    tb_MEM_RDATA = tb_goldData[addr+7];
    @(negedge tb_HCLK);
    tb_MEM_RDATA = tb_goldData[addr+8];
    
    // Check PRECHARGE command
    @(negedge tb_HCLK);
    assert(tb_cmd == CMD_PRECHARGE)
      $display("Successfully enters PRECHARGE");
    else
      $error("Unsuccessful read sequence at PRECHARGE");
  endtask
  
  task writeSimple();
    
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
  
  task writeSDRAM(input [1:0] ba, input[11:0] addr, input [31:0] data);
    if(ba == 2'b00) Bank0[{addr, addr}] = data;
    if(ba == 2'b01) Bank1[{addr, addr}] = data;
    if(ba == 2'b10) Bank2[{addr, addr}] = data;
    if(ba == 2'b11) Bank3[{addr, addr}] = data;
  endtask
  
  task startClkCounter();
    tb_count_clk = 0;
    tb_count_enable = 1'b1;
  endtask
  
  task stopClkCounter();
    tb_count_enable = 1'b0;
    $display("Counted %d cycles", tb_count_clk);
    tb_count_clk = 0;
  endtask
  
endmodule