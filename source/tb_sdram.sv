// $Id: $
// File name:   tb_sdram
// Created:     12/4/2014
// Author:      Kyle Woodworth
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Testbench for SDRAM wrapper module

`timescale 1ns / 10ps

module tb_sdram();
  // Parameters
	parameter CLK_PERIOD				= 10;
	
  // Input test signals
  reg tb_clk;
  reg tb_rstn;
  reg [31:0] tb_dqi;
  reg [31:0] tb_dqo;
  reg [11:0] tb_addr;
  reg [1:0] tb_ba;
  reg tb_cke;
  reg tb_csn;
  reg tb_rasn;
  reg tb_casn;
  reg tb_wen;
  reg [3:0] tb_dqm;
  
  // Output test signals
  
  // Custom structs/enums/unions
  typedef enum {
    INIT_VARIABLES,
    POR,
    INIT_SDRAM,
    WRITE_SIMPLE,
    READ_SIMPLE,
    WRITE_SEQ_LTE8,
    READ_SEQ_LTE8,
    WRITE_SEQ_GT8,
    READ_SEQ_GT8,
    WRITE_RAND_LTE8,
    READ_RAND_LTE8,
    WRITE_RAND_GT8,
    READ_RAND_GT8
    
  } TestStages;
  TestStages tb_stage;
  
  //Clock generations
	always begin : CLK_GEN
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2);
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2);
	end
	
	// Create DUTs
	sdram DUT_SDRAM
	(
	  .DQi(tb_dqi),
	  .ADDR(tb_addr),
	  .BA(tb_ba),
	  .CLK(tb_clk),
	  .CKE(tb_cke),
	  .CSn(tb_csn),
	  .RASn(tb_rasn),
	  .CASn(tb_casn),
	  .WEn(tb_wen),
	  .DQM(tb_dqm),
	  .DQo(tb_dqo)
	);
	
	
	// Begin test execution
	initial begin
	  
	  // Set initial input values
	  tb_stage = INIT_VARIABLES;
	  tb_rstn = 1'b0;
    tb_dqi = 32'h00000000;
    tb_addr = 12'h000;
    tb_ba = 2'b00;
    tb_cke = 1'b0;
    tb_csn = 1'b1;
    tb_rasn = 1'b1;
    tb_casn = 1'b1;
    tb_wen = 1'b1;
    tb_dqm = 4'h0;
    
    
	  // Power on reset
	  @(posedge tb_clk);
	  tb_stage = POR;
	  tb_rstn = 1'b0;
	  
	  // Initialize SDRAM
	  @(posedge tb_clk);
	  tb_stage = INIT_SDRAM;
	  tb_rstn = 1'b1;
	  waitCycles(50);
	  
	  waitCycles(50);
	  
	  
	  // Single write
	  @(posedge tb_clk);
	  tb_stage = WRITE_SIMPLE;
	  
	  // Single read
	  @(posedge tb_clk);
	  tb_stage = READ_SIMPLE;
	  
	  // Sequential write <= 8 words
	  @(posedge tb_clk);
	  tb_stage = WRITE_SEQ_LTE8;
	  
	  // Sequential read <= 8 words
	  @(posedge tb_clk);
	  tb_stage = READ_SEQ_LTE8;
	  
	  // Sequential write > 8 words
	  @(posedge tb_clk);
	  tb_stage = WRITE_SEQ_GT8;
	  
	  // Sequential read > 8 words
	  @(posedge tb_clk);
	  tb_stage = READ_SEQ_GT8;
	  
	  // Random write <= 8 words
	  @(posedge tb_clk);
	  tb_stage = WRITE_RAND_LTE8;
	  
	  // Random read <= 8 words
	  @(posedge tb_clk);
	  tb_stage = READ_RAND_LTE8;
	  
	  // Random write > 8 words
	  @(posedge tb_clk);
	  tb_stage = WRITE_RAND_GT8;
	  
	  // Rand read > 8 words
	  @(posedge tb_clk);
	  tb_stage = READ_RAND_GT8;
	  
	  
	end
	
	// Continuous test execution
	always @(posedge tb_clk) begin
	
	end
	
	// Tasks and functions
	task waitCycles(int unsigned x);
	  for(int i = 0; i < x; i++)
	    @(posedge tb_clk);
  endtask: waitCycles
  
endmodule