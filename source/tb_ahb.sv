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
  reg [31:0] tb_hwdata;
  reg tb_hwrite;
  reg tb_enable;
  reg [1:0] tb_mem_ba;
  reg [11:0] tb_mem_addr;
  reg tb_hreadyout;
  reg [31:0] tb_hrdata;
  reg [31:0] tb_mem_wdata;
  reg tb_w_en;
  reg tb_r_en;
  
  ahb DUT (
    .HCLK(tb_clk),
    .HRESETn(tb_n_rst),
    .HREADYIN(tb_hreadyin),
    .HSEL(tb_hsel),
    .HADDR(tb_haddr),
    .BUSYn(tb_busyn),
    .HRDATA_R(tb_hrdata_r),
    .HWDATA(tb_hwdata),
    .HWRITE(tb_hwrite),
    
    .ENABLE(tb_enable),
    .MEM_BA(tb_mem_ba),
    .MEM_ADDR(tb_mem_addr),
    .HREADYOUT(tb_hreadyout),
    .HRESP(tb_hresp),
    .HRDATA(tb_hrdata),
    .MEM_WDATA(tb_mem_wdata),
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
    tb_hwdata = '0;
    
    // Test enable
    @(posedge tb_clk);
    tb_hreadyin = 1;
    tb_hsel = 1;

    @(negedge tb_clk);
    assert (tb_enable == 1'b1)
      $info("Enable PASSED");
    else 
      $error("Enable FAILED");
    
    // Test disable
    @(posedge tb_clk);
    tb_hreadyin = 0;
    tb_hsel = 1;

    @(negedge tb_clk);
    assert (tb_enable == 1'b0)
      $info("Disable PASSED");
    else 
      $error("Disable FAILED");
    
    @(posedge tb_clk);
    tb_hreadyin = 1;
    tb_hsel = 0;

    @(negedge tb_clk);
    assert (tb_enable == 1'b0)
      $info("Disable PASSED");
    else 
      $error("Disable FAILED");
    
    // Test Address handling
    @(posedge tb_clk);
    tb_haddr = '1;
    
    @(negedge tb_clk);
    assert (tb_mem_addr == 12'b111111111111 && tb_mem_ba == 2'b11)
      $info("Address Decoder 1 PASSED");
    else 
      $error("Address Decoder 1 FAILED");
    
    @(posedge tb_clk)
    tb_haddr = 14'b01110100111010;
    @(negedge tb_clk);
    assert (tb_mem_addr == 12'b110100111010 && tb_mem_ba == 2'b01)
      $info("Address Decoder 2 PASSED");
    else 
      $error("Address Decoder 2 FAILED");
    
    
    // Test HREADYOUT handling
    @(posedge tb_clk);
    tb_busyn = 1'b1;
    
    @(negedge tb_clk);
    assert (tb_hreadyout == 1'b1)
      $info("Status Logic PASSED");
    else
      $error("Status Logic FAILED");
    
    // Test read data handling
    @(posedge tb_clk);
    tb_hrdata_r = '1;
    
    @(negedge tb_clk);
    assert (tb_hrdata == 32'hFFFFFFFF)
      $info("Data READ Logic PASSED");
    else
      $error("Data READ Logic FAILED");
      
    // Test write data handling
    @(posedge tb_clk);
    tb_hwdata = '1;
    
    @(negedge tb_clk);
    assert (tb_mem_wdata == 32'hFFFFFFFF)
      $info("Data WRITE Logic PASSED");
    else
      $error("Data WRITE Logic FAILED");
    
    // Test write enable
    @(posedge tb_clk);
    tb_hreadyin = 1;
    tb_hsel = 1;
    tb_hwrite = 1;
    
    @(negedge tb_clk);
    assert (tb_w_en == 1 && tb_r_en == 0)
      $info("Write Enable PASSED");
    else
      $error("Write Enable FAILED");
    
    // Test ready enable
    @(posedge tb_clk);
    tb_hreadyin = 1;
    tb_hsel = 1;
    tb_hwrite = 0;
    
    @(negedge tb_clk);
    assert (tb_w_en == 0 && tb_r_en == 1)
      $info("Read Enable PASSED");
    else 
      $error("Read Enable FAILED");
      
    
  end
  
endmodule