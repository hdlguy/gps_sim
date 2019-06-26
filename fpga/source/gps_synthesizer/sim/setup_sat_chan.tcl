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
upgrade_ip -quiet  [get_ips *]
generate_target {all} [get_ips *]

# Read in the hdl source.
read_verilog -sv ../doppler_nco.sv
read_verilog -sv ../sat_chan.sv
read_verilog -sv ../sat_chan_tb.sv

close_project

#########################



