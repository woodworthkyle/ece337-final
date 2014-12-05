// $Id: $
// File name:   sdram
// Created:     12/4/2014
// Author:      Kyle Woodworth
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: SDRAM wrapper module

module sdram
  #(
    parameter DATA_BITS = 32,
    parameter ADDR_BITS = 12
  )
  (
    input [DATA_BITS - 1:0] DQi,
    input [ADDR_BITS - 1:0] ADDR,
    input [1:0] BA,
    input CLK,
    input CKE,
    input CSn,
    input RASn,
    input CASn,
    input WEn,
    input [3:0] DQM,
    output [DATA_BITS - 1:0] DQo
  );
  
  wire [DATA_BITS - 1:0] DQ;
  assign DQ = (WEn == 1'b0)?(DQi):(DQo);
  
  mt48lc4m32b2 SDRAM_MICRON
  (
    .Dq(DQ),
    .Addr(ADDR),
    .Ba(BA),
    .Clk(CLK),
    .Cke(CKE),
    .Cs_n(CSn),
    .Ras_n(RASn),
    .Cas_n(CASn),
    .We_n(WEn),
    .Dqm(DQM)
  );
  
endmodule