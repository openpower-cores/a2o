## Directory Structure

```
src/verilog/trilib
src/verilog/work
src/vhdl
```

```
build
   bd (project)
   ip_cache (empty until project built)
   ip_repo (empty until IP built/copied)
   ip_user (IP macros to be built)
   tcl (build scripts)
```

```
fpga
   tcl 
```

```
doc
   core user guide, etc.
```


## Build Process

### IP

IP is created in ip_user and copied to ip_repo for use in top level bd.

See build/ip_user/xxx/readme.md.

Core:

```
a2o_core
```

Core-AXI:
```
a2l2_axi
```

Simple card components:

```
a2o_axi_reg 
a2o_dbug
```

Help Vivado attach to VIO correctly:

```
reverserator_3
reverserator_4
reverserator_64
```

### Project

See build/bd/readme.md.

1. create project
2. synth/implement

