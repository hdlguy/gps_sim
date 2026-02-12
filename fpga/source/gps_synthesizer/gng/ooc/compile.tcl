
close_project -quiet

open_project proj.xpr
update_compile_order -fileset sources_1

reset_run synth_1
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]
launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -jobs 4
wait_on_run impl_1

open_run impl_1
write_checkpoint -force ./results/post_route.dcp
report_timing_summary -file ./results/post_route_timing_summary.rpt
report_utilization -file ./results/post_route_utilization.rpt
close_project






