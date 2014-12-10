#add wave *
#add wave -position insertpoint sim:/tb_sdram/DUT_SDRAM/*
#add wave -position insertpoint sim:/tb_sdram/DUT_SDRAM/SDRAM_MICRON/*
#add wave -position insertpoint sim:/tb_top_mem_ctrl/MEM_CTRL/MEM_CONTROLLER/*
#add wave -position insertpoint sim:/tb_top_mem_ctrl/MEM_CTRL/INIT_REFRESH_TIMER/*
#add wave -position insertpoint sim:/tb_top_mem_ctrl/MEM_CTRL/*
#add wave -position insertpoint sim:/tb_top_mem_ctrl/MEM_CTRL/AHB_SLAVE/*
#add wave -position insertpoint sim:/tb_top_mem_ctrl/MEM_CTRL/CACHE/*

#add wave -noupdate -divider {Test Bench}
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_stage
##add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/MEM_CTRL/MEM_CONTROLLER/state
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_HCLK
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_HRESETn
#add wave -noupdate -expand -group {Test Bench Control} -radix decimal /tb_top_mem_ctrl/tb_HADDR
#add wave -noupdate -expand -group {Test Bench Control} -radix decimal /tb_top_mem_ctrl/tb_HWDATA
#add wave -noupdate -expand -group {Test Bench Control} -radix decimal /tb_top_mem_ctrl/tb_HRDATA
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_HWRITE
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_HSEL
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_HREADYIN
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_HREADYOUT
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_op
#add wave -noupdate -expand -group {Test Bench Control} -radix decimal /tb_top_mem_ctrl/tb_MEM_RDATA
#add wave -noupdate -expand -group {Test Bench Control} -radix decimal /tb_top_mem_ctrl/tb_MEM_WDATA
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_MEM_BA
#add wave -noupdate -expand -group {Test Bench Control} -radix decimal /tb_top_mem_ctrl/tb_MEM_ADDR
#add wave -noupdate -expand -group {Test Bench Control} -radix binary /tb_top_mem_ctrl/tb_MEM_CLK
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_MEM_CKE
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_MEM_CSn
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_MEM_RASn
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_MEM_CASn
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_MEM_WEn
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_MEM_DQM
#add wave -noupdate -expand -group {Test Bench Control} /tb_top_mem_ctrl/tb_refresh_count

# AHB test bench
add wave -noupdate -expand -group {Test Bench Control} /tb_ahb/tb_clk
add wave -noupdate -expand -group {Test Bench Control} /tb_ahb/tb_busyn
add wave -noupdate -expand -group {Test Bench Control} /tb_ahb/tb_hreadyout
add wave -noupdate -expand -group {Test Bench Control} /tb_ahb/tb_hreadyin
add wave -noupdate -expand -group {Test Bench Control} /tb_ahb/tb_hsel
add wave -noupdate -expand -group {Test Bench Control} /tb_ahb/tb_enable
add wave -noupdate -expand -group {Test Bench Control} /tb_ahb/tb_hwrite
add wave -noupdate -expand -group {Test Bench Control} /tb_ahb/tb_r_en
add wave -noupdate -expand -group {Test Bench Control} /tb_ahb/tb_w_en
add wave -noupdate -expand -group {Test Bench Control} -radix hexadecimal /tb_ahb/tb_haddr
add wave -noupdate -expand -group {Test Bench Control} -radix hexadecimal /tb_ahb/tb_mem_addr
add wave -noupdate -expand -group {Test Bench Control} -radix hexadecimal /tb_ahb/tb_mem_ba
add wave -noupdate -expand -group {Test Bench Control} -radix decimal /tb_ahb/tb_hrdata_r
add wave -noupdate -expand -group {Test Bench Control} -radix decimal /tb_ahb/tb_hrdata
add wave -noupdate -expand -group {Test Bench Control} -radix decimal /tb_ahb/tb_hwdata
add wave -noupdate -expand -group {Test Bench Control} -radix decimal /tb_ahb/tb_mem_wdata

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4999978052 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 195
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {779264 ps}


# Top level run
#run 104000 ns

# AHB run
run 120 ns

