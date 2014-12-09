add wave *
#add wave -position insertpoint sim:/tb_sdram/DUT_SDRAM/*
#add wave -position insertpoint sim:/tb_sdram/DUT_SDRAM/SDRAM_MICRON/*
#add wave -position insertpoint sim:/tb_top_mem_ctrl/MEM_CTRL/MEM_CONTROLLER/*
#add wave -position insertpoint sim:/tb_top_mem_ctrl/MEM_CTRL/INIT_REFRESH_TIMER/*
#add wave -position insertpoint sim:/tb_top_mem_ctrl/MEM_CTRL/*
#add wave -position insertpoint sim:/tb_top_mem_ctrl/MEM_CTRL/AHB_SLAVE/*
#add wave -position insertpoint sim:/tb_top_mem_ctrl/MEM_CTRL/CACHE/*

run 104000 ns

