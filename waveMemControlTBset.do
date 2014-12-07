onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Test Bench}
add wave -noupdate -expand -group {Test Bench Control} /tb_memcontrol/tb_hclk
add wave -noupdate -expand -group {Test Bench Control} /tb_memcontrol/tb_nrst
add wave -noupdate -expand -group {Test Bench Control} /tb_memcontrol/tb_rollover_flag
add wave -noupdate -group {TB Status/Control} /tb_memcontrol/tb_target_ba
add wave -noupdate -group {TB Status/Control} /tb_memcontrol/tb_target_addr
add wave -noupdate -group {TB Status/Control} /tb_memcontrol/tb_enable
add wave -noupdate -group {TB Status/Control} /tb_memcontrol/tb_BUSYn
add wave -noupdate -group {TB Status/Control} /tb_memcontrol/tb_w_en
add wave -noupdate -group {TB Status/Control} /tb_memcontrol/tb_r_en
add wave -noupdate -group {TB Cache} /tb_memcontrol/tb_c_addr_o
add wave -noupdate -group {TB Cache} /tb_memcontrol/tb_c_addr_en
add wave -noupdate -group {TB Cache} /tb_memcontrol/tb_c_addr_i
add wave -noupdate -group {TB Cache} /tb_memcontrol/tb_c_w_en
add wave -noupdate -group {TB Cache} /tb_memcontrol/tb_c_w_addr
add wave -noupdate -group {TB Cache} /tb_memcontrol/tb_c_r_en
add wave -noupdate -group {TB Cache} /tb_memcontrol/tb_c_r_addr
add wave -noupdate -group {TB SDRAM} /tb_memcontrol/tb_mem_ba
add wave -noupdate -group {TB SDRAM} /tb_memcontrol/tb_mem_addr
add wave -noupdate -group {TB SDRAM} /tb_memcontrol/tb_mem_cke
add wave -noupdate -group {TB SDRAM} /tb_memcontrol/tb_mem_CSn
add wave -noupdate -group {TB SDRAM} /tb_memcontrol/tb_mem_RASn
add wave -noupdate -group {TB SDRAM} /tb_memcontrol/tb_mem_CASn
add wave -noupdate -group {TB SDRAM} /tb_memcontrol/tb_mem_WEn
add wave -noupdate -group {TB Timer} /tb_memcontrol/tb_tim_clear
add wave -noupdate -group {TB Timer} /tb_memcontrol/tb_tim_EN
add wave -noupdate -group {TB Timer} /tb_memcontrol/tb_tim_ro_value
add wave -noupdate -divider Controller
add wave -noupdate /tb_memcontrol/DUT/BUSYn
add wave -noupdate -expand -group Enternal /tb_memcontrol/DUT/state
add wave -noupdate -expand -group Enternal /tb_memcontrol/DUT/offset
add wave -noupdate -expand -group Cache /tb_memcontrol/DUT/c_addr_i
add wave -noupdate -expand -group Cache /tb_memcontrol/DUT/c_w_addr
add wave -noupdate -expand -group Cache /tb_memcontrol/DUT/c_r_addr
add wave -noupdate -expand -group Cache /tb_memcontrol/DUT/c_addr_en
add wave -noupdate -expand -group Cache /tb_memcontrol/DUT/c_w_en
add wave -noupdate -expand -group Cache /tb_memcontrol/DUT/c_r_en
add wave -noupdate -expand -group SDRAM /tb_memcontrol/DUT/mem_ba
add wave -noupdate -expand -group SDRAM /tb_memcontrol/DUT/mem_addr
add wave -noupdate -expand -group SDRAM /tb_memcontrol/DUT/mem_cke
add wave -noupdate -expand -group SDRAM /tb_memcontrol/DUT/mem_CSn
add wave -noupdate -expand -group SDRAM /tb_memcontrol/DUT/mem_RASn
add wave -noupdate -expand -group SDRAM /tb_memcontrol/DUT/mem_CASn
add wave -noupdate -expand -group SDRAM /tb_memcontrol/DUT/mem_WEn
add wave -noupdate -expand -group Timer /tb_memcontrol/DUT/tim_ro_value
add wave -noupdate -expand -group Timer /tb_memcontrol/DUT/tim_clear
add wave -noupdate -expand -group Timer /tb_memcontrol/DUT/tim_EN
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {779264 ps}
