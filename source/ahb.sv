// $Id: $
// File name:   ahb.sv
// Created:     11/16/2014
// Author:      Allen Chien
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: AHB-Lite interface

module ahb (
  input wire H_CLK,
  input wire HRESETn,
  input wire HREADYIN,
  input wire HSEL,
  input wire [31:0] HADDR,
  input wire BUSYn,
  input wire [31:0] HRDATA_R,
  input wire HWRITE,
  output wire ENABLE,
  output wire [11:0] MEM_ADDR,
  output wire HREADYOUT,
  output wire [31:0] HRDATA,
  output wire W_EN,
  output wire R_EN
);
wire i_enable;
assign ENABLE = i_enable;

assign i_enable = HREADYIN & HSEL;
assign MEM_ADDR[11:0] = HADDR[11:0];
assign HREADYOUT = BUSYn;

assign W_EN = HWRITE & i_enable;
assign R_EN = (~HWRITE) & i_enable;

assign HRDATA = HRDATA_R;

endmodule
