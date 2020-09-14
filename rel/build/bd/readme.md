# create/build project

```
$VIVADO -mode tcl -source create_project.tcl

$VIVADO a2o_bd/a2o_bd.xpr

>run synthesis

source ./ila.tcl ;# to update ila_0, or set up debug manually

source ./impl.tcl
```

```
a2o_bd_routed_v0.dcp
a2o_bd_synth_v0.dcp

utilization_route_design_v0.rpt
timing_routed_summary_v0.rpt
timing_bus_skew_v0.rpt
qor_suggestions_v0.rpt

a2o_bd_v0.bin
a2o_bd_v0.bit
a2o_bd_v0.ltx
a2o_bd_v0_primary.bin
a2o_bd_v0_primary.prm
a2o_bd_v0_secondary.bin
a2o_bd_v0_secondary.prm
```
