// $Id: $
// File name:   cache.sv
// Created:     11/6/2014
// Author:      Christopher Pratt
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Cache for SDRAM memory control (AHB-Lite interface)

module cache(
  input wire clk,
  input wire n_rst,
  input wire addr_enable,
  input wire [11:0]addr_in,
  input wire [31:0]data_in,
  input wire write_enable,
  input wire [2:0]write_pointer,
  input wire read_enable,
  input wire [2:0]read_pointer,
  output wire [11:0]addr_out,
  output wire [31:0]data_out
  );
  
  //Internal definitions
  reg [11:0]address; //Internal address memory register
  
  wire [11:0]nextaddr; //Internal address memory wire
  
  reg [31:0]cache0;  //Internal cache memory registers
  reg [31:0]cache1;  //Internal cache memory registers
  reg [31:0]cache2;  //Internal cache memory registers
  reg [31:0]cache3;  //Internal cache memory registers
  reg [31:0]cache4;  //Internal cache memory registers
  reg [31:0]cache5;  //Internal cache memory registers
  reg [31:0]cache6;  //Internal cache memory registers
  reg [31:0]cache7;  //Internal cache memory registers
  
  wire [31:0]nextcache0;  //Internal cache memory wires
  wire [31:0]nextcache1;  //Internal cache memory wires
  wire [31:0]nextcache2;  //Internal cache memory wires
  wire [31:0]nextcache3;  //Internal cache memory wires
  wire [31:0]nextcache4;  //Internal cache memory wires
  wire [31:0]nextcache5;  //Internal cache memory wires
  wire [31:0]nextcache6;  //Internal cache memory wires
  wire [31:0]nextcache7;  //Internal cache memory wires
  
  
  //////////////ADDRESS BLOCK////////////////////
  
  //Block of memory for address comparison
  always_ff @ (posedge clk,negedge n_rst)
  begin
    
    if(n_rst == 0)
    begin
      address <= 0;
    end
    
    else
    begin
      address <= nextaddr;    
    end
  end
  
  //Output line always equal to internal address
  assign nextaddr = (addr_enable == 1'b1) ? addr_in : address;
  assign addr_out = address;    
  
  ////////////////CACHE BLOCK///////////////////////
  
  //Block of memory for cache
  always_ff @ (posedge clk,negedge n_rst)
  begin
    
    if(n_rst == 0)
    begin
      cache0 <= 0;
      cache1 <= 0;
      cache2 <= 0;
      cache3 <= 0;
      cache4 <= 0;
      cache5 <= 0;
      cache6 <= 0;
      cache7 <= 0;
    end
    
    else
    begin
      cache0 <= nextcache0;
      cache1 <= nextcache1;
      cache2 <= nextcache2;
      cache3 <= nextcache3;
      cache4 <= nextcache4;
      cache5 <= nextcache5;
      cache6 <= nextcache6;
      cache7 <= nextcache7;    
    end
  end
  
  //Input logic selection
  assign nextcache0 = (write_enable == 1'b0) ? cache0 : (write_pointer == 3'b000) ? data_in : cache0;
  assign nextcache1 = (write_enable == 1'b0) ? cache1 : (write_pointer == 3'b001) ? data_in : cache1;
  assign nextcache2 = (write_enable == 1'b0) ? cache2 : (write_pointer == 3'b010) ? data_in : cache2;
  assign nextcache3 = (write_enable == 1'b0) ? cache3 : (write_pointer == 3'b011) ? data_in : cache3;
  assign nextcache4 = (write_enable == 1'b0) ? cache4 : (write_pointer == 3'b100) ? data_in : cache4;
  assign nextcache5 = (write_enable == 1'b0) ? cache5 : (write_pointer == 3'b101) ? data_in : cache5;
  assign nextcache6 = (write_enable == 1'b0) ? cache6 : (write_pointer == 3'b110) ? data_in : cache6;
  assign nextcache7 = (write_enable == 1'b0) ? cache7 : (write_pointer == 3'b111) ? data_in : cache7;
  
  //Output logic selection
  assign data_out = (read_enable == 1'b0)? 0 : 
                    (read_pointer == 3'b000) ? cache0 : 
                    (read_pointer == 3'b001) ? cache1 : 
                    (read_pointer == 3'b010) ? cache2 : 
                    (read_pointer == 3'b011) ? cache3 :
                    (read_pointer == 3'b100) ? cache4 :
                    (read_pointer == 3'b101) ? cache5 :
                    (read_pointer == 3'b110) ? cache6 :
                    (read_pointer == 3'b111) ? cache7 : 0;
  
endmodule
  
      
      
