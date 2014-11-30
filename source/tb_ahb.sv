`timescale 1ns / 10ps

module tb_ahb
();

  parameter CLK_PERIOD = 10;

  reg tb_clk;
  reg tb_n_rst;
  reg tb_hreadyin;
  reg tb_hsel;
  reg [31:0] tb_haddr;
  reg tb_busyn;
  reg [31:0] tb_hrdata_r;
  reg tb_hwrite;
  reg tb_enable;
  reg [11:0] tb_mem_addr;
  reg tb_hreadyout;
  reg [31:0] tb_hrdata;
  reg tb_w_en;
  reg tb_r_en;
  
  ahb DUT (
    .H_CLK(tb_clk),
    .HRESETn(tb_n_rst),
    .HREADYIN(tb_hreadyin),
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
    
  always
  begin : CLK_GEN
    tb_clk = 1'b0;
    #(CLK_PERIOD / 2);
    tb_clk = 1'b1;
    #(CLK_PERIOD / 2);
  end
  
  initial begin
    tb_n_rst = 0;
    tb_hreadyin = 0;
    tb_hsel = 0;
    tb_haddr = 0;
    tb_busyn = 0;
    tb_hwrite = 0;
    tb_hrdata_r = '0;
    tb_haddr = '0;
    
    @(posedge tb_clk);
    tb_hreadyin = 1;
    tb_hsel = 1;

    @(posedge tb_clk);
    assert (tb_enable == 1'b1)
      $info("Enable PASSED");
    else 
      $error("Enable FAILED");
    
    @(posedge tb_clk);
    tb_haddr = '1;
    
    @(posedge tb_clk);
    assert (tb_mem_addr == 12'b111111111111)
      $info("Address Decoder PASSED");
    else 
      $error("Address Decoder FAILED");
      
    @(posedge tb_clk);
    tb_busyn = 1;
    
    @(posedge tb_clk);
    assert (tb_hreadyout == 1)
      $info("Status Logic PASSED");
    else
      $error("Status Logic FAILED");
      
    @(posedge tb_clk);
    tb_hrdata_r = '1;
    
    @(posedge tb_clk);
    assert (tb_hrdata == 32'hFFFFFFFF)
      $info("Data Out Logic PASSED");
    else
      $error("Data Out Logic FAILED");
      
    @(posedge tb_clk);
    tb_hreadyin = 1;
    tb_hsel = 1;
    tb_hwrite = 1;
    
    @(posedge tb_clk);
    assert (tb_w_en == 1 && tb_r_en == 0)
      $info("Write Enable PASSED");
    else
      $error("Write Enable FAILED");
      
    @(posedge tb_clk);
    tb_hreadyin = 1;
    tb_hsel = 1;
    tb_hwrite = 0;
    
    @(posedge tb_clk);
    assert (tb_w_en == 0 && tb_r_en == 1)
      $info("Read Enable PASSED");
    else 
      $error("Read Enable FAILED");
      
    
  end
  
endmodule