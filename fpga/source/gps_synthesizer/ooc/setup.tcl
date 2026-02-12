# This script sets up a Vivado project with all ip references resolved.
close_project -quiet
file delete -force proj.xpr *.os *.jou *.log proj.srcs proj.cache proj.runs
#
create_project -force proj 
set_property board_part em.avnet.com:microzed_7020:part0:1.2 [current_project]
set_property target_language Verilog [current_project]
set_property default_lib work [current_project]

read_ip ../doppler_rom/doppler_rom.xci
read_ip ../ca_rom/ca_rom.xci
read_ip ../bb_ila/bb_ila.xci

upgrade_ip -quiet  [get_ips *]
generate_target {all} [get_ips *]

# Read in the hdl source.
read_verilog -sv ../doppler_nco.sv
read_verilog -sv ../sat_chan.sv

read_verilog -sv ../gng/rtl/gng_coef.v  
read_verilog -sv ../gng/rtl/gng_ctg.v  
read_verilog -sv ../gng/rtl/gng_interp.v  
read_verilog -sv ../gng/rtl/gng_lzd.v  
read_verilog -sv ../gng/rtl/gng_smul_16_18_sadd_37.v  
read_verilog -sv ../gng/rtl/gng_smul_16_18.v  
read_verilog -sv ../gng/rtl/gng.v
read_verilog -sv ../gng/rtl/gng_cmplx.sv

read_verilog -sv ../gps_emulator.sv

read_xdc ./top.xdc

close_project

#########################



