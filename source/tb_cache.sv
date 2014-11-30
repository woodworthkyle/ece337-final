// $Id: $
// File name:   tb_cache.sv
// Created:     11/6/2014
// Author:      Christopher Pratt
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: TESTBENCH: Cache for SDRAM memory control (AHB-Lite interface)

`timescale 1ns / 10ps

module tb_cache();
  
  //System Clock Generation 
  localparam CLK_PERIOD = 6.67;
  
  reg tb_clk;
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end  

  reg tb_n_rst;
  reg tb_addr_enable;
  reg [11:0]tb_addr_in;
  reg [31:0]tb_data_in;
  reg tb_write_enable;
  reg [2:0]tb_write_pointer;
  reg tb_read_enable;
  reg [2:0]tb_read_pointer;
  reg [11:0]tb_addr_out;
  reg [31:0]tb_data_out;
  
  cache DUT(
  .clk(tb_clk),
  .n_rst(tb_n_rst),
  .addr_enable(tb_addr_enable),
  .addr_in(tb_addr_in),
  .data_in(tb_data_in),
  .write_enable(tb_write_enable),
  .write_pointer(tb_write_pointer),
  .read_enable(tb_read_enable),
  .read_pointer(tb_read_pointer),
  .addr_out(tb_addr_out),
  .data_out(tb_data_out) 
  );
  
  initial
  begin
    
    //Reset States
    tb_n_rst         = 0;
    tb_addr_enable   = 0;
    tb_addr_in       = 0;
    tb_data_in       = 0;
    tb_write_enable  = 0;
    tb_write_pointer = 0;
    tb_read_enable   = 0;
    tb_read_pointer  = 0;
    
    //Initial States
    tb_addr_in = 123;
    tb_data_in = 1000;
    
    //Reset	  
	  tb_n_rst = 1'b0;
    #(CLK_PERIOD * 2.25);
    tb_n_rst = 1'b1;    
    
    //Test Address Register
    #(CLK_PERIOD * 2.25);
    tb_addr_enable = 1'b1;
    #(CLK_PERIOD * 2.25);
    tb_addr_enable = 1'b0;
    
    //Test cache load
    #(CLK_PERIOD);
    tb_write_enable = 1'b1;
    #(CLK_PERIOD);
    tb_write_enable = 1'b0;
    #(CLK_PERIOD);
    
    tb_data_in = 2000;
    tb_write_pointer = 1;
    #(CLK_PERIOD);
    tb_write_enable = 1'b1;
    #(CLK_PERIOD);
    tb_write_enable = 1'b0;
    #(CLK_PERIOD);

    tb_data_in = 3000;
    tb_write_pointer = 2;
    #(CLK_PERIOD);
    tb_write_enable = 1'b1;
    #(CLK_PERIOD);
    tb_write_enable = 1'b0;
    #(CLK_PERIOD);
    
    tb_data_in = 4000;
    tb_write_pointer = 3;
    #(CLK_PERIOD);
    tb_write_enable = 1'b1;
    #(CLK_PERIOD);
    tb_write_enable = 1'b0;
    #(CLK_PERIOD);
    
    tb_data_in = 5000;
    tb_write_pointer = 4;
    #(CLK_PERIOD);
    tb_write_enable = 1'b1;
    #(CLK_PERIOD);
    tb_write_enable = 1'b0;
    #(CLK_PERIOD);
    
    tb_data_in = 6000;
    tb_write_pointer = 5;
    #(CLK_PERIOD);
    tb_write_enable = 1'b1;
    #(CLK_PERIOD);
    tb_write_enable = 1'b0;
    #(CLK_PERIOD);
    
    tb_data_in = 7000;
    tb_write_pointer = 6;
    #(CLK_PERIOD);
    tb_write_enable = 1'b1;
    #(CLK_PERIOD);
    tb_write_enable = 1'b0;
    #(CLK_PERIOD);
    
    tb_data_in = 8000;
    tb_write_pointer = 7;
    #(CLK_PERIOD);
    tb_write_enable = 1'b1;
    #(CLK_PERIOD);
    tb_write_enable = 1'b0;
    #(CLK_PERIOD);
    
    //Test cache output
    tb_read_enable = 1'b1;
    #(CLK_PERIOD);
    tb_read_enable = 1'b0;
    #(CLK_PERIOD);
    
    tb_read_pointer = 1;
    #(CLK_PERIOD);
    tb_read_enable = 1'b1;
    #(CLK_PERIOD);
    tb_read_enable = 1'b0;
    #(CLK_PERIOD);
    
    tb_read_pointer = 2;
    #(CLK_PERIOD);
    tb_read_enable = 1'b1;
    #(CLK_PERIOD);
    tb_read_enable = 1'b0;
    #(CLK_PERIOD);
    
    tb_read_pointer = 3;
    #(CLK_PERIOD);
    tb_read_enable = 1'b1;
    #(CLK_PERIOD);
    tb_read_enable = 1'b0;
    #(CLK_PERIOD);
    
    tb_read_pointer = 4;
    #(CLK_PERIOD);
    tb_read_enable = 1'b1;
    #(CLK_PERIOD);
    tb_read_enable = 1'b0;
    #(CLK_PERIOD);
    
    tb_read_pointer = 5;
    #(CLK_PERIOD);
    tb_read_enable = 1'b1;
    #(CLK_PERIOD);
    tb_read_enable = 1'b0;
    #(CLK_PERIOD);
    
    tb_read_pointer = 6;
    #(CLK_PERIOD);
    tb_read_enable = 1'b1;
    #(CLK_PERIOD);
    tb_read_enable = 1'b0;
    #(CLK_PERIOD);
    
    tb_read_pointer = 7;
    #(CLK_PERIOD);
    tb_read_enable = 1'b1;
    #(CLK_PERIOD);
    tb_read_enable = 1'b0;
    #(CLK_PERIOD);
    
  end
endmodule
           
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
     
