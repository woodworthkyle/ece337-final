`timescale 1ns / 10ps

module tb_ahb
();

  reg tb_hreadyin,
  reg tb_hsel,
  reg [31:0] tb_haddr,
  reg tb_busyn,
  reg tb_hrdata_r,
  reg tb_hwrite,
  reg tb_enable,
  reg [11:0] tb_mem_addr,
  reg tb_hreadyout,
  reg [31:0] tb_hrdata,
  reg tb_w_en,
  reg tb_r_en
  
  ahb DUT (
    .HREADYIN(tb_readyin)
    .HSEL(tb_hsel),
    .HADDR(tb_haddr),
    .BUSYn(tb_busyn),
    .HRDATA_R(tb_hrdata_r),
    .HWRITE(tb_hwrite),
    .ENABLE(tb_enable),
    .MEM_ADDR(tb_mem_addr),
    .HREADYOUT(tb_hreadyout),
    .HRDATA(tb_hrdata),
    .W_EN(tb_w_en),
    .R_EN(tb_r_en)
  );
    
  
  initial begin
    