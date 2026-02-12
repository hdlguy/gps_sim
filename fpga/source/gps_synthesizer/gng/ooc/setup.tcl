# This script sets up a Vivado project with all ip references resolved.
close_project -quiet
file delete -force proj.xpr *.os *.jou *.log proj.srcs proj.cache proj.runs
#
create_project -force proj 
#set_property part xc7a50tftg256-1 [current_project]
#set_property part xc7z020clg484-1 [current_project]
#set_property board_part em.avnet.com:microzed_7020:part0:1.2 [current_project]
set_property board_part em.avnet.com:ultrazed_eg_iocc_production:part0:1.0 [current_project]
set_property target_language verilog [current_project]
set_property default_lib work [current_project]
load_features ipintegrator

#set_property  ip_repo_paths ../../../../hls/complex_conv/csynth/solution1/impl/ip [current_project]
#update_ip_catalog

#read_ip ../../delay_line/delay_bram/delay_bram.xci
#upgrade_ip -quiet  [get_ips *]
#generate_target {all} [get_ips *]

read_verilog -sv ../rtl/gng_coef.v  
read_verilog -sv ../rtl/gng_ctg.v  
read_verilog -sv ../rtl/gng_interp.v  
read_verilog -sv ../rtl/gng_lzd.v  
read_verilog -sv ../rtl/gng_smul_16_18_sadd_37.v  
read_verilog -sv ../rtl/gng_smul_16_18.v  
read_verilog -sv ../rtl/gng.v

read_xdc ./top.xdc

#read_xdc ../source/artix_top_late.xdc
#set_property used_in_synthesis false [get_files  ../../source/artix_top_late.xdc]

close_project


