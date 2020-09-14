#synth_design -top a2o_bd -part xcvu3p-ffvc1517-2-e -verbose
#source ila_axi.tcl

# ----------------------------------------------------------------------------------------
#       opt             place             phys_opt          route            phys_opt
# ----------------------------------------------------------------------------------------
# v0   (1)              Explore           Explore           Explore          Explore
# v1   Explore          Explore           Explore           Explore          Explore    
# ----------------------------------------------------------------------------------------
# (1) -retarget -propconst -bram_power_opt
#         
set version v0

# make sure synth is open
open_run synth_1

write_checkpoint -force a2o_synth_${version}.dcp

if {$version == {v0}} {
   opt_design -retarget -propconst -bram_power_opt -debug_log
} elseif {$version == {v1}} {
   opt_design -directive Explore -debug_log
} else {
   opt_design -debug_log
}

place_design -directive Explore
#place_design -directive Explore -no_bufg_opt

phys_opt_design -directive Explore
route_design -directive Explore
phys_opt_design -directive Explore

write_checkpoint -force a2o_routed_${version}.dcp 

report_utilization -file utilization_route_design_${version}.rpt
report_timing_summary -max_paths 100 -file timing_routed_summary_${version}.rpt
report_bus_skew -file timing_bus_skew_${version}.rpt
report_qor_suggestions -file qor_suggestions_${version}.rpt

write_bitstream -force -bin_file a2o_${version}
write_debug_probes -force a2o_${version}
write_cfgmem -force -format BIN -interface SPIx8 -size 256 -loadbit "up 0 a2o_${version}.bit" a2o_${version}

