// $Id: $
// File name:   ahb.sv
// Created:     11/16/2014
// Author:      Allen Chien
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: AHB-Lite interface

module ahb (
  input wire H_CLK,           //Clock
  input wire HRESETn,         //nReset
  input wire HREADYIN,        //indicates the previous transfer is complete
  input wire HSEL,            //select the slave
  input wire [31:0] HADDR,    //system address bus
  input wire BUSYn,           //current transfer is in progress
  input wire [31:0] HRDATA_R, //data
  input wire HWRITE,          //write enable
  output wire ENABLE,         //enable signal
  output wire MEM_BA,         //bank address for SDRAM
  output wire [11:0] MEM_ADDR,//address for SDRAM
  output wire HREADYOUT,      //indicates the previous transfer is complete
  output wire [31:0] HRDATA,  //data
  output wire W_EN,           //write enable signal
  output wire R_EN            //read enable signal
);
wire i_enable;
assign ENABLE = i_enable;

assign i_enable = HREADYIN & HSEL;
assign MEM_BA = HADDR[13:12];
assign MEM_ADDR[11:0] = HADDR[11:0];
assign HREADYOUT = BUSYn;

assign W_EN = HWRITE & i_enable;
assign R_EN = (~HWRITE) & i_enable;

assign HRDATA = HRDATA_R;

endmodule
