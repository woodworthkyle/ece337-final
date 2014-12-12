// $Id: $
// File name:   tb_sdram
// Created:     12/4/2014
// Author:      Kyle Woodworth
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Testbench for SDRAM wrapper module

`timescale 1ns / 10ps

module tb_sdram();
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
  reg tb_write;
  reg [3:0] tb_dqm;
  int tb_refresh_count;
  
  // Output test signals
  
  // Custom structs/enums/unions
  
  // ENUM for test stages
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
    READ_RAND_GT8,
    
    REFRESH,
    STAGE_DONE
  } TestStages;
  
  // ENUM for SDRAM op codes
  typedef enum {
    CMD_INHIBIT,
    NOP,
    ACTIVE,
    AUTO_REFRESH,
    LMR,
    PRECHARGE,
    READ,
    WRITE,
    BURST_TERM
  } OpCode;
  
  OpCode tb_opcode;
  TestStages tb_stage;
  
  // Clock generations
	always begin : CLK_GEN
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2);
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2);
    tb_refresh_count++;
    if(tb_refresh_count == 750) begin
      tb_refresh_count = 0;
    end
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
	  .write(tb_write),
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
    tb_dqm = 4'h0;
    tb_write = 1'b1;
    sendOpCode(CMD_INHIBIT);
    
    //
	  // Power on reset
	  //
	  @(posedge tb_clk);
	  tb_stage = POR;
	  tb_rstn = 1'b0;
	  tb_cke = 1'b0;
	  sendOpCode(CMD_INHIBIT);
	  
	  //
	  // Initialize SDRAM
	  //
	  @(posedge tb_clk);
	  tb_stage = INIT_SDRAM;
	  tb_rstn = 1'b1;
	  
	  // Wait 100 us while asserting CKE and sending NOP/COMMAND INHIBIT
	  waitCycles(2500);
	  # tCKS;
	  tb_cke = 1'b1;
	  # tCKH;
	  sendOpCode(NOP);
	  waitCycles(2500);
	  
	  // Send PRECHARGE ALL op code
	  # tCMH;
	  sendOpCode(PRECHARGE);
	  
	  // Wait tRP
	  sendOpCodeImmediate(NOP);
	  # tRP;
	  # (tCMS + tCMH);
	  
	  // Send AUTO REFRESH op code
	  sendOpCode(AUTO_REFRESH);
	  
	  // Wait tRFC
	  sendOpCodeImmediate(NOP);
	  # tRFC;
	  # (tCMS + tCMH);
	  
	  // Send AUTO REFRESH op code
	  sendOpCode(AUTO_REFRESH);
	  
	  // WAIT tRFC
	  sendOpCodeImmediate(NOP);
	  # tRFC;
	  # (tCMS + tCMH);
	  
	  // Send LMR and appropriate settings throug tb_addr
	  // Write Burst Mode = single location access
	  // Operating Mode = standard operation
	  // CAS Latency = 1
	  // Burst TYpe = Sequential
	  // Burst Length = 8
	  tb_addr = 12'b001000010011;
	  tb_ba = 2'b00;
	  sendOpCode(LMR);
	  
	  // Wait tMRD
	  sendOpCodeImmediate(NOP);
	  # tMRD
	  
	  
	  //
	  // Single write
	  //
	  @(negedge tb_clk);
	  tb_stage = WRITE_SIMPLE;
	  writeSimple(32'hFF88FFAA, 2'b00, 12'h000);
	  
	  //
	  // Single read
	  //
	  @(negedge tb_clk);
	  tb_stage = READ_SIMPLE;
	  readSimple(2'b00, 12'h000);
	  
	  //
	  // Sequential write <= 8 words
	  //
	  @(negedge tb_clk);
	  tb_stage = WRITE_SEQ_LTE8;
	  writeSeqLTE8(5, 2'b00, 12'h001);
	  
	  //
	  // Sequential read <= 8 words
	  //
	  @(negedge tb_clk);
	  tb_stage = READ_SEQ_LTE8;
	  readSeqLTE8(5, 2'b00, 12'h001);
	  
	  @(negedge tb_clk);
	  tb_stage = STAGE_DONE;
	  
	  /*
	  //
	  // Sequential write > 8 words
	  //
	  @(negedge tb_clk);
	  tb_stage = WRITE_SEQ_GT8;
	  
	  //
	  // Sequential read > 8 words
	  //
	  @(negedge tb_clk);
	  tb_stage = READ_SEQ_GT8;
	  
	  //
	  // Random write <= 8 words
	  //
	  @(negedge tb_clk);
	  tb_stage = WRITE_RAND_LTE8;
	  
	  //
	  // Random read <= 8 words
	  //
	  @(negedge tb_clk);
	  tb_stage = READ_RAND_LTE8;
	  
	  //
	  // Random write > 8 words
	  //
	  @(negedge tb_clk);
	  tb_stage = WRITE_RAND_GT8;
	  
	  //
	  // Rand read > 8 words
	  //
	  @(negedge tb_clk);
	  tb_stage = READ_RAND_GT8;
	  */
	  
	end
	
	// Continuous test execution
	always @(posedge tb_clk) begin
	
	end
	
	// Tasks and functions
	task waitCycles(int unsigned x);
	  for(int i = 0; i < x; i++)
	    @(posedge tb_clk);
  endtask: waitCycles
  
  task sendOpCode(OpCode op);
    sendOpCodeImmediate(op);
    # tCMS;
	  @(posedge tb_clk);
	  # tCMH;
  endtask
  
  task sendOpCodeImmediate(OpCode op);
    case(op)
      CMD_INHIBIT: begin
        tb_csn = 1'b1;
        tb_rasn = 1'b1;
        tb_casn = 1'b1;
        tb_wen = 1'b1;
      end
      NOP: begin
        tb_csn = 1'b0;
        tb_rasn = 1'b1;
        tb_casn = 1'b1;
        tb_wen = 1'b1;
      end
      ACTIVE: begin
        tb_csn = 1'b0;
        tb_rasn = 1'b0;
        tb_casn = 1'b1;
        tb_wen = 1'b1;
      end
      AUTO_REFRESH: begin
        tb_csn = 1'b0;
        tb_rasn = 1'b0;
        tb_casn = 1'b0;
        tb_wen = 1'b1;
      end
      LMR: begin
        tb_csn = 1'b0;
        tb_rasn = 1'b0;
        tb_casn = 1'b0;
        tb_wen = 1'b0;
      end
      PRECHARGE: begin
        tb_csn = 1'b0;
        tb_rasn = 1'b0;
        tb_casn = 1'b1;
        tb_wen = 1'b0;
        tb_addr[10] = 1'b1;
      end
      READ: begin
        tb_csn = 1'b0;
        tb_rasn = 1'b1;
        tb_casn = 1'b0;
        tb_wen = 1'b1;
        tb_write = 1'b0;
      end
      WRITE: begin
        tb_csn = 1'b0;
        tb_rasn = 1'b1;
        tb_casn = 1'b0;
        tb_wen = 1'b0;
        tb_write = 1'b1;
      end
      BURST_TERM: begin
        tb_csn = 1'b0;
        tb_rasn = 1'b1;
        tb_casn = 1'b1;
        tb_wen = 1'b0;
      end
      default: begin
        tb_csn = 1'b0;
        tb_rasn = 1'b1;
        tb_casn = 1'b1;
        tb_wen = 1'b1;
        tb_write = 1'b1;
      end
    endcase
    tb_opcode = op;
  endtask
  
  
  
  task writeSimple(input [31:0] data, input [1:0] ba, input [11:0] addr);
    rwPrep(ba, addr);
    writeSDRAM(data);
	  rwEnd();
  endtask
  
  task writeSDRAM(input [31:0] data);
    setDATA(data);
    sendOpCode(WRITE);
  endtask
  
  task readSimple(input [1:0] ba, input [11:0] addr);
    rwPrep(ba, addr);
    readSDRAM();
    //sendOpCodeImmediate(NOP);
    //waitCycles(CL);
    //@(negedge tb_clk);
	  rwEnd();
  endtask
  
  task readSDRAM();
    @(negedge tb_clk);
    sendOpCode(READ);
  endtask
  
  task rwPrep(input [1:0] ba, input [11:0] addr);
    setBA(ba);
    setADDR(addr, 0);
    sendOpCode(ACTIVE);
    sendOpCodeImmediate(NOP);
    # tRCD;
  endtask
  
  task rwEnd();
    sendOpCode(BURST_TERM);
	  sendOpCodeImmediate(NOP);
    sendOpCode(PRECHARGE);
    sendOpCodeImmediate(NOP);
    # tRP;
  endtask
  
  task writeSeqLTE8(int size, input [1:0] ba, input [11:0] start_addr);
    rwPrep(ba, start_addr);
    for (int i = 0; i < size; i++) begin
      setADDR(start_addr + i[11:0], 0);
      writeSDRAM(i[31:0]*3);
    end
    rwEnd();
  endtask
  
  task readSeqLTE8(int size, input [1:0] ba, input [11:0] start_addr);
    rwPrep(ba, start_addr);
    readSDRAM();
    sendOpCodeImmediate(NOP);
    waitCycles(size-1);
    # tAH;
    rwEnd();
    
  endtask
  
  
  task setDATA(input [31:0] data);
    # tDS;
    tb_dqi = data;
    # tDH;
  endtask
  
  task setBA(input [1:0] ba);
    # tAS;
    tb_ba = ba;
    # tAH;
  endtask
  
  task setADDR(input [11:0] addr, int wc);
    # tAS;
    tb_addr = addr;
    waitCycles(wc);
    # tAH;
  endtask
  
  
endmodule