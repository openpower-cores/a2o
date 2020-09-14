
# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Set the project name
set _xil_proj_name_ "a2o_bd"

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
  set _xil_proj_name_ $::user_project_name
}

variable script_file
set script_file "create_project.tcl"

# Help information for this script
proc print_help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--project_name <name>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
  puts "\[--project_name <name>\] Create project with the specified name. Default"
  puts "                       name is the name of the project from where this"
  puts "                       script was generated.\n"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir"   { incr i; set origin_dir [lindex $::argv $i] }
      "--project_name" { incr i; set _xil_proj_name_ [lindex $::argv $i] }
      "--help"         { print_help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"

# Create project
create_project -force ${_xil_proj_name_} ./${_xil_proj_name_} -part xcvu3p-ffvc1517-2-e

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "default_lib" -value "work" -objects $obj
set_property -name "dsa.accelerator_binary_content" -value "bitstream" -objects $obj
set_property -name "dsa.accelerator_binary_format" -value "xclbin2" -objects $obj
set_property -name "dsa.description" -value "Vivado generated DSA" -objects $obj
set_property -name "dsa.dr_bd_base_address" -value "0" -objects $obj
set_property -name "dsa.emu_dir" -value "emu" -objects $obj
set_property -name "dsa.flash_interface_type" -value "bpix16" -objects $obj
set_property -name "dsa.flash_offset_address" -value "0" -objects $obj
set_property -name "dsa.flash_size" -value "1024" -objects $obj
set_property -name "dsa.host_architecture" -value "x86_64" -objects $obj
set_property -name "dsa.host_interface" -value "pcie" -objects $obj
set_property -name "dsa.num_compute_units" -value "60" -objects $obj
set_property -name "dsa.platform_state" -value "pre_synth" -objects $obj
set_property -name "dsa.vendor" -value "xilinx" -objects $obj
set_property -name "dsa.version" -value "0.0" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$origin_dir/../ip_cache" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "part" -value "xcvu3p-ffvc1517-2-e" -objects $obj
set_property -name "sim.central_dir" -value "$proj_dir/${_xil_proj_name_}.ip_user_files" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "source_mgmt_mode" -value "DisplayOnly" -objects $obj
set_property -name "webtalk.activehdl_export_sim" -value "73" -objects $obj
set_property -name "webtalk.ies_export_sim" -value "73" -objects $obj
set_property -name "webtalk.modelsim_export_sim" -value "73" -objects $obj
set_property -name "webtalk.questa_export_sim" -value "73" -objects $obj
set_property -name "webtalk.riviera_export_sim" -value "73" -objects $obj
set_property -name "webtalk.vcs_export_sim" -value "73" -objects $obj
set_property -name "webtalk.xsim_export_sim" -value "73" -objects $obj
set_property -name "webtalk.xsim_launch_sim" -value "95" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC XPM_FIFO XPM_MEMORY" -objects $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize "$origin_dir/../ip_repo"]" $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
# Set 'sources_1' fileset file properties for remote files
# None

# Set 'sources_1' fileset file properties for local files
# None

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property -name "top" -value "a2o_bd" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/xdc/main_pinout.xdc"]"
set file_added [add_files -norecurse -fileset $obj [list $file]]
set file "$origin_dir/xdc/main_pinout.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj
set_property -name "library" -value "work" -objects $file_obj

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/xdc/main_spi.xdc"]"
set file_added [add_files -norecurse -fileset $obj [list $file]]
set file "$origin_dir/xdc/main_spi.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj
set_property -name "library" -value "work" -objects $file_obj

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/xdc/main_timing.xdc"]"
set file_added [add_files -norecurse -fileset $obj [list $file]]
set file "$origin_dir/xdc/main_timing.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj
set_property -name "library" -value "work" -objects $file_obj

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/xdc/main_extras.xdc"]"
set file_added [add_files -norecurse -fileset $obj [list $file]]
set file "$origin_dir/xdc/main_extras.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj
set_property -name "library" -value "work" -objects $file_obj

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]
set_property -name "target_constrs_file" -value "[file normalize "$origin_dir/xdc/main_extras.xdc"]" -objects $obj
set_property -name "target_part" -value "xcvu3p-ffvc1517-2-e" -objects $obj
set_property -name "target_ucf" -value "[file normalize "$origin_dir/xdc/main_extras.xdc"]" -objects $obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property -name "incremental" -value "0" -objects $obj
set_property -name "nl.mode" -value "funcsim" -objects $obj
set_property -name "sim_mode" -value "post-synthesis" -objects $obj
set_property -name "top" -value "a2o_bd" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj
set_property -name "xsim.simulate.log_all_signals" -value "1" -objects $obj
set_property -name "xsim.simulate.runtime" -value "40000ns" -objects $obj

# Set 'utils_1' fileset object
set obj [get_filesets utils_1]
# Empty (no sources present)

# Set 'utils_1' fileset properties
set obj [get_filesets utils_1]


# Adding sources referenced in BDs, if not already added


# Proc to create BD a2o_bd
proc cr_bd_a2o_bd { parentCell } {

  # CHANGE DESIGN NAME HERE
  set design_name a2o_bd

  common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
  user.org:user:a2l2_axi:1.0\
  user.org:user:a2o_axi_reg:1.0\
  user.org:user:a2o_dbug:1.0\
  xilinx.com:ip:axi_bram_ctrl:4.1\
  xilinx.com:ip:axi_protocol_checker:2.0\
  xilinx.com:ip:blk_mem_gen:8.4\
  user.org:user:c_wrapper:1.0\
  xilinx.com:ip:clk_wiz:6.0\
  xilinx.com:ip:jtag_axi:1.2\
  xilinx.com:ip:proc_sys_reset:5.0\
  user.org:user:reverserator_3:1.0\
  user.org:user:reverserator_4:1.0\
  user.org:user:reverserator_64:1.0\
  xilinx.com:ip:smartconnect:1.0\
  xilinx.com:ip:system_ila:1.1\
  xilinx.com:ip:vio:3.0\
  xilinx.com:ip:xlconstant:1.1\
  "

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

  }

  if { $bCheckIPsPassed != 1 } {
    common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
    return 3
  }

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set clk_in1_n_0 [ create_bd_port -dir I -type clk clk_in1_n_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {300000000} \
 ] $clk_in1_n_0
  set clk_in1_p_0 [ create_bd_port -dir I -type clk clk_in1_p_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {300000000} \
 ] $clk_in1_p_0

  # Create instance: a2l2_axi_0, and set properties
  set a2l2_axi_0 [ create_bd_cell -type ip -vlnv user.org:user:a2l2_axi:1.0 a2l2_axi_0 ]
  set_property -dict [ list \
   CONFIG.ld_queue_size {8} \
   CONFIG.st_queue_size {32} \
   CONFIG.threads {2} \
 ] $a2l2_axi_0

  # Create instance: a2o_axi_reg_0, and set properties
  set a2o_axi_reg_0 [ create_bd_cell -type ip -vlnv user.org:user:a2o_axi_reg:1.0 a2o_axi_reg_0 ]

  # Create instance: a2o_dbug_0, and set properties
  set a2o_dbug_0 [ create_bd_cell -type ip -vlnv user.org:user:a2o_dbug:1.0 a2o_dbug_0 ]

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property -dict [ list \
   CONFIG.SINGLE_PORT_BRAM {1} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
 ] $axi_bram_ctrl_0

  # Create instance: axi_bram_ctrl_1, and set properties
  set axi_bram_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_1 ]
  set_property -dict [ list \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_1

  # Create instance: axi_protocol_checker_0, and set properties
  set axi_protocol_checker_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_checker:2.0 axi_protocol_checker_0 ]
  set_property -dict [ list \
   CONFIG.ARUSER_WIDTH {4} \
   CONFIG.AWUSER_WIDTH {4} \
   CONFIG.BUSER_WIDTH {4} \
   CONFIG.ENABLE_CONTROL {1} \
   CONFIG.ENABLE_MARK_DEBUG {0} \
   CONFIG.HAS_SYSTEM_RESET {1} \
   CONFIG.ID_WIDTH {4} \
   CONFIG.MAX_RD_BURSTS {8} \
   CONFIG.MAX_WR_BURSTS {32} \
   CONFIG.RUSER_WIDTH {4} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_WIDTH {4} \
 ] $axi_protocol_checker_0

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.Byte_Size {8} \
   CONFIG.Coe_File {no_coe_file_loaded} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {true} \
   CONFIG.Fill_Remaining_Memory_Locations {false} \
   CONFIG.Load_Init_File {false} \
   CONFIG.Memory_Type {Single_Port_RAM} \
   CONFIG.PRIM_type_to_Implement {URAM} \
   CONFIG.Port_A_Write_Rate {50} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Use_Byte_Write_Enable {true} \
   CONFIG.Use_RSTA_Pin {true} \
   CONFIG.use_bram_block {BRAM_Controller} \
 ] $blk_mem_gen_0

  # Create instance: blk_mem_gen_1, and set properties
  set blk_mem_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_1 ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.Byte_Size {8} \
   CONFIG.Coe_File {no_coe_file_loaded} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {true} \
   CONFIG.Enable_B {Always_Enabled} \
   CONFIG.Load_Init_File {false} \
   CONFIG.Memory_Type {Single_Port_RAM} \
   CONFIG.PRIM_type_to_Implement {URAM} \
   CONFIG.Port_A_Write_Rate {50} \
   CONFIG.Port_B_Clock {0} \
   CONFIG.Port_B_Enable_Rate {0} \
   CONFIG.Port_B_Write_Rate {0} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Use_Byte_Write_Enable {true} \
   CONFIG.Use_RSTA_Pin {true} \
   CONFIG.Use_RSTB_Pin {false} \
   CONFIG.use_bram_block {BRAM_Controller} \
 ] $blk_mem_gen_1

  # Create instance: c_wrapper_0, and set properties
  set c_wrapper_0 [ create_bd_cell -type ip -vlnv user.org:user:c_wrapper:1.0 c_wrapper_0 ]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.AUTO_PRIMITIVE {MMCM} \
   CONFIG.CLKIN1_JITTER_PS {33.330000000000005} \
   CONFIG.CLKOUT1_DRIVES {Buffer} \
   CONFIG.CLKOUT1_JITTER {116.415} \
   CONFIG.CLKOUT1_PHASE_ERROR {77.836} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.000} \
   CONFIG.CLKOUT2_DRIVES {Buffer} \
   CONFIG.CLKOUT2_JITTER {101.475} \
   CONFIG.CLKOUT2_PHASE_ERROR {77.836} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {100.000} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_DRIVES {Buffer} \
   CONFIG.CLKOUT3_JITTER {88.577} \
   CONFIG.CLKOUT3_PHASE_ERROR {77.836} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {200.000} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLKOUT4_DRIVES {Buffer} \
   CONFIG.CLKOUT5_DRIVES {Buffer} \
   CONFIG.CLKOUT6_DRIVES {Buffer} \
   CONFIG.CLKOUT7_DRIVES {Buffer} \
   CONFIG.CLK_OUT1_PORT {clk} \
   CONFIG.CLK_OUT2_PORT {clk2x} \
   CONFIG.CLK_OUT3_PORT {clk4x} \
   CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
   CONFIG.MMCM_BANDWIDTH {OPTIMIZED} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {4.000} \
   CONFIG.MMCM_CLKIN1_PERIOD {3.333} \
   CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {24.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {12} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {6} \
   CONFIG.MMCM_COMPENSATION {AUTO} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {3} \
   CONFIG.PRIMITIVE {MMCM} \
   CONFIG.PRIM_IN_FREQ {300.000} \
   CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
   CONFIG.USE_LOCKED {true} \
   CONFIG.USE_RESET {false} \
 ] $clk_wiz_0

  # Create instance: jtag_axi_0, and set properties
  set jtag_axi_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:jtag_axi:1.2 jtag_axi_0 ]

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]
  set_property -dict [ list \
   CONFIG.C_AUX_RESET_HIGH {0} \
   CONFIG.C_AUX_RST_WIDTH {1} \
   CONFIG.C_EXT_RST_WIDTH {4} \
 ] $proc_sys_reset_0

  # Create instance: reverserator_3_0, and set properties
  set reverserator_3_0 [ create_bd_cell -type ip -vlnv user.org:user:reverserator_3:1.0 reverserator_3_0 ]

  # Create instance: reverserator_3_1, and set properties
  set reverserator_3_1 [ create_bd_cell -type ip -vlnv user.org:user:reverserator_3:1.0 reverserator_3_1 ]

  # Create instance: reverserator_3_2, and set properties
  set reverserator_3_2 [ create_bd_cell -type ip -vlnv user.org:user:reverserator_3:1.0 reverserator_3_2 ]

  # Create instance: reverserator_4_0, and set properties
  set reverserator_4_0 [ create_bd_cell -type ip -vlnv user.org:user:reverserator_4:1.0 reverserator_4_0 ]

  # Create instance: reverserator_4_1, and set properties
  set reverserator_4_1 [ create_bd_cell -type ip -vlnv user.org:user:reverserator_4:1.0 reverserator_4_1 ]

  # Create instance: reverserator_4_2, and set properties
  set reverserator_4_2 [ create_bd_cell -type ip -vlnv user.org:user:reverserator_4:1.0 reverserator_4_2 ]

  # Create instance: reverserator_4_3, and set properties
  set reverserator_4_3 [ create_bd_cell -type ip -vlnv user.org:user:reverserator_4:1.0 reverserator_4_3 ]

  # Create instance: reverserator_64_0, and set properties
  set reverserator_64_0 [ create_bd_cell -type ip -vlnv user.org:user:reverserator_64:1.0 reverserator_64_0 ]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {5} \
   CONFIG.NUM_SI {2} \
 ] $smartconnect_0

  # Create instance: system_ila_0, and set properties
  set system_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_0 ]
  set_property -dict [ list \
   CONFIG.ALL_PROBE_SAME_MU_CNT {2} \
   CONFIG.C_ADV_TRIGGER {true} \
   CONFIG.C_BRAM_CNT {48} \
   CONFIG.C_DATA_DEPTH {8192} \
   CONFIG.C_EN_STRG_QUAL {1} \
   CONFIG.C_INPUT_PIPE_STAGES {3} \
   CONFIG.C_PROBE0_MU_CNT {2} \
   CONFIG.C_SLOT_0_MAX_RD_BURSTS {8} \
   CONFIG.C_SLOT_0_MAX_WR_BURSTS {32} \
   CONFIG.C_TRIGIN_EN {true} \
   CONFIG.C_TRIGOUT_EN {true} \
 ] $system_ila_0

  # Create instance: system_ila_1, and set properties
  set system_ila_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_1 ]
  set_property -dict [ list \
   CONFIG.ALL_PROBE_SAME_MU {true} \
   CONFIG.ALL_PROBE_SAME_MU_CNT {4} \
   CONFIG.C_BRAM_CNT {9} \
   CONFIG.C_DATA_DEPTH {2048} \
   CONFIG.C_EN_STRG_QUAL {1} \
   CONFIG.C_MON_TYPE {NATIVE} \
   CONFIG.C_NUM_OF_PROBES {2} \
   CONFIG.C_PROBE0_MU_CNT {4} \
   CONFIG.C_PROBE0_WIDTH {160} \
   CONFIG.C_PROBE1_MU_CNT {4} \
   CONFIG.C_PROBE_WIDTH_PROPAGATION {MANUAL} \
   CONFIG.C_TRIGOUT_EN {true} \
 ] $system_ila_1

  # Create instance: vio_0, and set properties
  set vio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_0 ]
  set_property -dict [ list \
   CONFIG.C_NUM_PROBE_IN {6} \
   CONFIG.C_NUM_PROBE_OUT {7} \
   CONFIG.C_PROBE_OUT1_INIT_VAL {0x1} \
   CONFIG.C_PROBE_OUT2_WIDTH {4} \
   CONFIG.C_PROBE_OUT3_WIDTH {6} \
   CONFIG.C_PROBE_OUT4_WIDTH {64} \
 ] $vio_0

  # Create instance: vio_1, and set properties
  set vio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_1 ]
  set_property -dict [ list \
   CONFIG.C_NUM_PROBE_IN {5} \
   CONFIG.C_NUM_PROBE_OUT {19} \
   CONFIG.C_PROBE_OUT0_INIT_VAL {0xf} \
   CONFIG.C_PROBE_OUT0_WIDTH {4} \
   CONFIG.C_PROBE_OUT12_WIDTH {4} \
   CONFIG.C_PROBE_OUT13_WIDTH {4} \
   CONFIG.C_PROBE_OUT15_WIDTH {4} \
   CONFIG.C_PROBE_OUT17_INIT_VAL {0xf} \
   CONFIG.C_PROBE_OUT17_WIDTH {4} \
   CONFIG.C_PROBE_OUT18_INIT_VAL {0xf} \
   CONFIG.C_PROBE_OUT18_WIDTH {4} \
   CONFIG.C_PROBE_OUT1_INIT_VAL {0x1} \
   CONFIG.C_PROBE_OUT2_WIDTH {1} \
   CONFIG.C_PROBE_OUT3_WIDTH {8} \
   CONFIG.C_PROBE_OUT4_WIDTH {4} \
   CONFIG.C_PROBE_OUT6_WIDTH {4} \
   CONFIG.C_PROBE_OUT7_WIDTH {4} \
   CONFIG.C_PROBE_OUT8_WIDTH {4} \
   CONFIG.C_PROBE_OUT9_INIT_VAL {0x1} \
 ] $vio_1

  # Create instance: vio_2, and set properties
  set vio_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_2 ]
  set_property -dict [ list \
   CONFIG.C_NUM_PROBE_IN {5} \
   CONFIG.C_NUM_PROBE_OUT {0} \
   CONFIG.C_PROBE_OUT1_INIT_VAL {0x1} \
   CONFIG.C_PROBE_OUT2_WIDTH {4} \
   CONFIG.C_PROBE_OUT3_WIDTH {6} \
   CONFIG.C_PROBE_OUT4_WIDTH {64} \
 ] $vio_2

  # Create instance: vio_3, and set properties
  set vio_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_3 ]
  set_property -dict [ list \
   CONFIG.C_NUM_PROBE_IN {2} \
   CONFIG.C_NUM_PROBE_OUT {2} \
   CONFIG.C_PROBE_IN2_WIDTH {3} \
   CONFIG.C_PROBE_IN3_WIDTH {4} \
   CONFIG.C_PROBE_OUT0_WIDTH {32} \
   CONFIG.C_PROBE_OUT1_INIT_VAL {0x1} \
   CONFIG.C_PROBE_OUT1_WIDTH {2} \
   CONFIG.C_PROBE_OUT2_WIDTH {4} \
   CONFIG.C_PROBE_OUT3_WIDTH {6} \
   CONFIG.C_PROBE_OUT4_WIDTH {64} \
 ] $vio_3

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {2} \
 ] $xlconstant_1

  # Create instance: xlconstant_2, and set properties
  set xlconstant_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_2 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {32} \
 ] $xlconstant_2

  # Create instance: xlconstant_3, and set properties
  set xlconstant_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_3 ]

  # Create instance: xlconstant_4, and set properties
  set xlconstant_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_4 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_4

  # Create interface connections
  connect_bd_intf_net -intf_net a2l2_axi_0_m00_axi [get_bd_intf_pins a2l2_axi_0/m00_axi] [get_bd_intf_pins smartconnect_0/S00_AXI]
connect_bd_intf_net -intf_net [get_bd_intf_nets a2l2_axi_0_m00_axi] [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins system_ila_0/SLOT_0_AXI]
connect_bd_intf_net -intf_net [get_bd_intf_nets a2l2_axi_0_m00_axi] [get_bd_intf_pins axi_protocol_checker_0/PC_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_3_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTA]
  connect_bd_intf_net -intf_net jtag_axi_0_M_AXI [get_bd_intf_pins jtag_axi_0/M_AXI] [get_bd_intf_pins smartconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins a2o_axi_reg_0/s00_axi] [get_bd_intf_pins smartconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins a2o_axi_reg_0/s_axi_intr] [get_bd_intf_pins smartconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins smartconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins axi_bram_ctrl_1/S_AXI] [get_bd_intf_pins smartconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins axi_protocol_checker_0/S_AXI] [get_bd_intf_pins smartconnect_0/M04_AXI]

  # Create port connections
  connect_bd_net -net Net2 [get_bd_pins a2o_dbug_0/trigger_in] [get_bd_pins system_ila_1/TRIG_OUT_trig] [get_bd_pins vio_1/probe_in1]
  connect_bd_net -net a2l2_axi_0_an_ac_reld_core_tag [get_bd_pins a2l2_axi_0/an_ac_reld_core_tag] [get_bd_pins c_wrapper_0/an_ac_reld_core_tag]
  connect_bd_net -net a2l2_axi_0_an_ac_reld_crit_qw [get_bd_pins a2l2_axi_0/an_ac_reld_crit_qw] [get_bd_pins c_wrapper_0/an_ac_reld_crit_qw]
  connect_bd_net -net a2l2_axi_0_an_ac_reld_data [get_bd_pins a2l2_axi_0/an_ac_reld_data] [get_bd_pins c_wrapper_0/an_ac_reld_data]
  connect_bd_net -net a2l2_axi_0_an_ac_reld_data_coming [get_bd_pins a2l2_axi_0/an_ac_reld_data_coming] [get_bd_pins c_wrapper_0/an_ac_reld_data_coming]
  connect_bd_net -net a2l2_axi_0_an_ac_reld_data_vld [get_bd_pins a2l2_axi_0/an_ac_reld_data_vld] [get_bd_pins c_wrapper_0/an_ac_reld_data_vld]
  connect_bd_net -net a2l2_axi_0_an_ac_reld_ecc_err [get_bd_pins a2l2_axi_0/an_ac_reld_ecc_err] [get_bd_pins c_wrapper_0/an_ac_reld_ecc_err]
  connect_bd_net -net a2l2_axi_0_an_ac_reld_ecc_err_ue [get_bd_pins a2l2_axi_0/an_ac_reld_ecc_err_ue] [get_bd_pins c_wrapper_0/an_ac_reld_ecc_err_ue]
  connect_bd_net -net a2l2_axi_0_an_ac_reld_l1_dump [get_bd_pins a2l2_axi_0/an_ac_reld_l1_dump] [get_bd_pins c_wrapper_0/an_ac_reld_l1_dump]
  connect_bd_net -net a2l2_axi_0_an_ac_reld_qw [get_bd_pins a2l2_axi_0/an_ac_reld_qw] [get_bd_pins c_wrapper_0/an_ac_reld_qw]
  connect_bd_net -net a2l2_axi_0_an_ac_req_ld_pop [get_bd_pins a2l2_axi_0/an_ac_req_ld_pop] [get_bd_pins c_wrapper_0/an_ac_req_ld_pop]
  connect_bd_net -net a2l2_axi_0_an_ac_req_st_gather [get_bd_pins a2l2_axi_0/an_ac_req_st_gather] [get_bd_pins c_wrapper_0/an_ac_req_st_gather]
  connect_bd_net -net a2l2_axi_0_an_ac_req_st_pop [get_bd_pins a2l2_axi_0/an_ac_req_st_pop] [get_bd_pins c_wrapper_0/an_ac_req_st_pop]
  connect_bd_net -net a2l2_axi_0_an_ac_reservation_vld [get_bd_pins a2l2_axi_0/an_ac_reservation_vld] [get_bd_pins c_wrapper_0/an_ac_reservation_vld]
  connect_bd_net -net a2l2_axi_0_an_ac_stcx_complete [get_bd_pins a2l2_axi_0/an_ac_stcx_complete] [get_bd_pins c_wrapper_0/an_ac_stcx_complete]
  connect_bd_net -net a2l2_axi_0_an_ac_stcx_pass [get_bd_pins a2l2_axi_0/an_ac_stcx_pass] [get_bd_pins c_wrapper_0/an_ac_stcx_pass]
  connect_bd_net -net a2l2_axi_0_an_ac_sync_ack [get_bd_pins a2l2_axi_0/an_ac_sync_ack] [get_bd_pins c_wrapper_0/an_ac_sync_ack]
  connect_bd_net -net a2l2_axi_0_err [get_bd_pins a2l2_axi_0/err] [get_bd_pins reverserator_4_2/innnie]
  connect_bd_net -net a2o_axi_reg_0_irq [get_bd_pins a2o_axi_reg_0/irq] [get_bd_pins vio_3/probe_in0]
  connect_bd_net -net a2o_axi_reg_0_reg_out_00 [get_bd_pins a2o_axi_reg_0/reg_out_00] [get_bd_pins vio_3/probe_in1]
  connect_bd_net -net a2o_dbug_0_cch_out [get_bd_pins a2o_dbug_0/cch_out] [get_bd_pins vio_0/probe_in4]
  connect_bd_net -net a2o_dbug_0_dch_out [get_bd_pins a2o_dbug_0/dch_out] [get_bd_pins vio_0/probe_in5]
  connect_bd_net -net a2o_dbug_0_err [get_bd_pins a2o_dbug_0/err] [get_bd_pins vio_0/probe_in1]
  connect_bd_net -net a2o_dbug_0_rsp_data [get_bd_pins a2o_dbug_0/rsp_data] [get_bd_pins reverserator_64_0/parkavenue]
  connect_bd_net -net a2o_dbug_0_rsp_valid [get_bd_pins a2o_dbug_0/rsp_valid] [get_bd_pins vio_0/probe_in0]
  connect_bd_net -net a2o_dbug_0_threadstop_out [get_bd_pins a2o_dbug_0/threadstop_out] [get_bd_pins c_wrapper_0/an_ac_pm_thread_stop]
  connect_bd_net -net a2o_dbug_0_trigger_ack_out [get_bd_pins a2o_dbug_0/trigger_ack_out] [get_bd_pins vio_0/probe_in3]
  connect_bd_net -net a2o_dbug_0_trigger_out [get_bd_pins a2o_dbug_0/trigger_out] [get_bd_pins system_ila_0/TRIG_IN_trig]
  connect_bd_net -net a2o_reset_0_reset [get_bd_pins a2l2_axi_0/reset_n] [get_bd_pins a2o_axi_reg_0/s00_axi_aresetn] [get_bd_pins a2o_axi_reg_0/s_axi_intr_aresetn] [get_bd_pins a2o_dbug_0/reset_n] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins axi_protocol_checker_0/aresetn] [get_bd_pins jtag_axi_0/aresetn] [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins smartconnect_0/aresetn] [get_bd_pins system_ila_0/resetn]
  connect_bd_net -net axi_protocol_checker_0_pc_asserted [get_bd_pins axi_protocol_checker_0/pc_asserted] [get_bd_pins system_ila_1/probe1] [get_bd_pins vio_1/probe_in0]
  connect_bd_net -net axi_protocol_checker_0_pc_status [get_bd_pins axi_protocol_checker_0/pc_status] [get_bd_pins system_ila_1/probe0]
  connect_bd_net -net c_wrapper_0_ac_an_checkstop [get_bd_pins c_wrapper_0/ac_an_checkstop] [get_bd_pins reverserator_3_1/outdoor]
  connect_bd_net -net c_wrapper_0_ac_an_debug_trigger [get_bd_pins c_wrapper_0/ac_an_debug_trigger] [get_bd_pins reverserator_4_3/innnie]
  connect_bd_net -net c_wrapper_0_ac_an_local_checkstop [get_bd_pins c_wrapper_0/ac_an_local_checkstop] [get_bd_pins reverserator_3_2/outdoor]
  connect_bd_net -net c_wrapper_0_ac_an_machine_check [get_bd_pins c_wrapper_0/ac_an_machine_check] [get_bd_pins reverserator_4_0/innnie]
  connect_bd_net -net c_wrapper_0_ac_an_pm_thread_running [get_bd_pins c_wrapper_0/ac_an_pm_thread_running] [get_bd_pins reverserator_4_1/innnie]
  connect_bd_net -net c_wrapper_0_ac_an_recov_err [get_bd_pins c_wrapper_0/ac_an_recov_err] [get_bd_pins reverserator_3_0/outdoor]
  connect_bd_net -net c_wrapper_0_ac_an_req [get_bd_pins a2l2_axi_0/ac_an_req] [get_bd_pins c_wrapper_0/ac_an_req]
  connect_bd_net -net c_wrapper_0_ac_an_req_endian [get_bd_pins a2l2_axi_0/ac_an_req_endian] [get_bd_pins c_wrapper_0/ac_an_req_endian]
  connect_bd_net -net c_wrapper_0_ac_an_req_ld_core_tag [get_bd_pins a2l2_axi_0/ac_an_req_ld_core_tag] [get_bd_pins c_wrapper_0/ac_an_req_ld_core_tag]
  connect_bd_net -net c_wrapper_0_ac_an_req_ld_xfr_len [get_bd_pins a2l2_axi_0/ac_an_req_ld_xfr_len] [get_bd_pins c_wrapper_0/ac_an_req_ld_xfr_len]
  connect_bd_net -net c_wrapper_0_ac_an_req_pwr_token [get_bd_pins a2l2_axi_0/ac_an_req_pwr_token] [get_bd_pins c_wrapper_0/ac_an_req_pwr_token]
  connect_bd_net -net c_wrapper_0_ac_an_req_ra [get_bd_pins a2l2_axi_0/ac_an_req_ra] [get_bd_pins c_wrapper_0/ac_an_req_ra]
  connect_bd_net -net c_wrapper_0_ac_an_req_thread [get_bd_pins a2l2_axi_0/ac_an_req_thread] [get_bd_pins c_wrapper_0/ac_an_req_thread]
  connect_bd_net -net c_wrapper_0_ac_an_req_ttype [get_bd_pins a2l2_axi_0/ac_an_req_ttype] [get_bd_pins c_wrapper_0/ac_an_req_ttype]
  connect_bd_net -net c_wrapper_0_ac_an_req_user_defined [get_bd_pins a2l2_axi_0/ac_an_req_user_defined] [get_bd_pins c_wrapper_0/ac_an_req_user_defined]
  connect_bd_net -net c_wrapper_0_ac_an_req_wimg_g [get_bd_pins a2l2_axi_0/ac_an_req_wimg_g] [get_bd_pins c_wrapper_0/ac_an_req_wimg_g]
  connect_bd_net -net c_wrapper_0_ac_an_req_wimg_i [get_bd_pins a2l2_axi_0/ac_an_req_wimg_i] [get_bd_pins c_wrapper_0/ac_an_req_wimg_i]
  connect_bd_net -net c_wrapper_0_ac_an_req_wimg_m [get_bd_pins a2l2_axi_0/ac_an_req_wimg_m] [get_bd_pins c_wrapper_0/ac_an_req_wimg_m]
  connect_bd_net -net c_wrapper_0_ac_an_req_wimg_w [get_bd_pins a2l2_axi_0/ac_an_req_wimg_w] [get_bd_pins c_wrapper_0/ac_an_req_wimg_w]
  connect_bd_net -net c_wrapper_0_ac_an_st_byte_enbl [get_bd_pins a2l2_axi_0/ac_an_st_byte_enbl] [get_bd_pins c_wrapper_0/ac_an_st_byte_enbl]
  connect_bd_net -net c_wrapper_0_ac_an_st_data [get_bd_pins a2l2_axi_0/ac_an_st_data] [get_bd_pins c_wrapper_0/ac_an_st_data]
  connect_bd_net -net c_wrapper_0_ac_an_st_data_pwr_token [get_bd_pins a2l2_axi_0/ac_an_st_data_pwr_token] [get_bd_pins c_wrapper_0/ac_an_st_data_pwr_token]
  connect_bd_net -net clk_in1_n_0_1 [get_bd_ports clk_in1_n_0] [get_bd_pins clk_wiz_0/clk_in1_n]
  connect_bd_net -net clk_in1_p_0_1 [get_bd_ports clk_in1_p_0] [get_bd_pins clk_wiz_0/clk_in1_p]
  connect_bd_net -net clk_wiz_0_clk [get_bd_pins a2l2_axi_0/clk] [get_bd_pins a2o_axi_reg_0/s00_axi_aclk] [get_bd_pins a2o_axi_reg_0/s_axi_intr_aclk] [get_bd_pins a2o_dbug_0/clk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins axi_protocol_checker_0/aclk] [get_bd_pins c_wrapper_0/clk] [get_bd_pins clk_wiz_0/clk] [get_bd_pins jtag_axi_0/aclk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins smartconnect_0/aclk] [get_bd_pins system_ila_0/clk] [get_bd_pins system_ila_1/clk] [get_bd_pins vio_0/clk] [get_bd_pins vio_1/clk] [get_bd_pins vio_2/clk] [get_bd_pins vio_3/clk]
  connect_bd_net -net clk_wiz_0_clk2x [get_bd_pins c_wrapper_0/clk2x] [get_bd_pins clk_wiz_0/clk2x]
  connect_bd_net -net clk_wiz_0_clk4x [get_bd_pins c_wrapper_0/clk4x] [get_bd_pins clk_wiz_0/clk4x]
  connect_bd_net -net clk_wiz_0_locked [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_0/dcm_locked]
  connect_bd_net -net proc_sys_reset_0_mb_reset [get_bd_pins c_wrapper_0/reset] [get_bd_pins proc_sys_reset_0/mb_reset]
  connect_bd_net -net reverserator_3_0_inndoor [get_bd_pins reverserator_3_0/inndoor] [get_bd_pins vio_2/probe_in1]
  connect_bd_net -net reverserator_3_1_inndoor [get_bd_pins reverserator_3_1/inndoor] [get_bd_pins vio_2/probe_in2]
  connect_bd_net -net reverserator_3_2_inndoor [get_bd_pins reverserator_3_2/inndoor] [get_bd_pins vio_2/probe_in3]
  connect_bd_net -net reverserator_4_0_outtie [get_bd_pins reverserator_4_0/outtie] [get_bd_pins vio_2/probe_in0]
  connect_bd_net -net reverserator_4_1_outtie [get_bd_pins reverserator_4_1/outtie] [get_bd_pins vio_1/probe_in2]
  connect_bd_net -net reverserator_4_2_outtie [get_bd_pins reverserator_4_2/outtie] [get_bd_pins vio_2/probe_in4]
  connect_bd_net -net reverserator_4_3_outtie [get_bd_pins reverserator_4_3/outtie] [get_bd_pins vio_1/probe_in4]
  connect_bd_net -net reverserator_64_0_skidrowwww [get_bd_pins reverserator_64_0/skidrowwww] [get_bd_pins vio_0/probe_in2]
  connect_bd_net -net vio_0_probe_out0 [get_bd_pins a2o_dbug_0/req_valid] [get_bd_pins vio_0/probe_out0]
  connect_bd_net -net vio_0_probe_out1 [get_bd_pins a2o_dbug_0/req_rw] [get_bd_pins vio_0/probe_out1]
  connect_bd_net -net vio_0_probe_out2 [get_bd_pins a2o_dbug_0/req_id] [get_bd_pins vio_0/probe_out2]
  connect_bd_net -net vio_0_probe_out3 [get_bd_pins a2o_dbug_0/req_addr] [get_bd_pins vio_0/probe_out3]
  connect_bd_net -net vio_0_probe_out4 [get_bd_pins a2o_dbug_0/req_wr_data] [get_bd_pins vio_0/probe_out4]
  connect_bd_net -net vio_0_probe_out5 [get_bd_pins a2o_dbug_0/dch_in] [get_bd_pins vio_0/probe_out5]
  connect_bd_net -net vio_0_probe_out6 [get_bd_pins a2o_dbug_0/cch_in] [get_bd_pins vio_0/probe_out6]
  connect_bd_net -net vio_1_probe_out0 [get_bd_pins a2o_dbug_0/threadstop_in] [get_bd_pins vio_1/probe_out0]
  connect_bd_net -net vio_1_probe_out1 [get_bd_pins proc_sys_reset_0/aux_reset_in] [get_bd_pins vio_1/probe_out1]
  connect_bd_net -net vio_1_probe_out2 [get_bd_pins system_ila_1/TRIG_OUT_ack] [get_bd_pins vio_1/probe_out2]
  connect_bd_net -net vio_1_probe_out3 [get_bd_pins c_wrapper_0/an_ac_coreid] [get_bd_pins vio_1/probe_out3]
  connect_bd_net -net vio_1_probe_out4 [get_bd_pins c_wrapper_0/an_ac_external_mchk] [get_bd_pins vio_1/probe_out4]
  connect_bd_net -net vio_1_probe_out5 [get_bd_pins vio_1/probe_in3] [get_bd_pins vio_1/probe_out5]
  connect_bd_net -net vio_1_probe_out6 [get_bd_pins c_wrapper_0/an_ac_crit_interrupt] [get_bd_pins vio_1/probe_out6]
  connect_bd_net -net vio_1_probe_out7 [get_bd_pins c_wrapper_0/an_ac_ext_interrupt] [get_bd_pins vio_1/probe_out7]
  connect_bd_net -net vio_1_probe_out8 [get_bd_pins c_wrapper_0/an_ac_perf_interrupt] [get_bd_pins vio_1/probe_out8]
  connect_bd_net -net vio_1_probe_out9 [get_bd_pins c_wrapper_0/an_ac_tb_update_enable] [get_bd_pins vio_1/probe_out9]
  connect_bd_net -net vio_1_probe_out10 [get_bd_pins c_wrapper_0/an_ac_tb_update_pulse] [get_bd_pins vio_1/probe_out10]
  connect_bd_net -net vio_1_probe_out11 [get_bd_pins c_wrapper_0/an_ac_flh2l2_gate] [get_bd_pins vio_1/probe_out11]
  connect_bd_net -net vio_1_probe_out12 [get_bd_pins c_wrapper_0/an_ac_hang_pulse] [get_bd_pins vio_1/probe_out12]
  #wtf connect_bd_net -net vio_1_probe_out13 [get_bd_pins c_wrapper_0/ac_an_debug_trigger] [get_bd_pins vio_1/probe_out13]
  connect_bd_net -net vio_1_probe_out14 [get_bd_pins a2o_dbug_0/trigger_ack_enable] [get_bd_pins vio_1/probe_out14]
  connect_bd_net -net vio_1_probe_out15 [get_bd_pins a2o_dbug_0/trigger_threadstop] [get_bd_pins vio_1/probe_out15]
  connect_bd_net -net vio_1_probe_out16 [get_bd_pins c_wrapper_0/an_ac_debug_stop] [get_bd_pins vio_1/probe_out16]
  connect_bd_net -net vio_1_probe_out17 [get_bd_pins a2l2_axi_0/axi_loads_max] [get_bd_pins vio_1/probe_out17]
  connect_bd_net -net vio_1_probe_out18 [get_bd_pins a2l2_axi_0/axi_stores_max] [get_bd_pins vio_1/probe_out18]
  connect_bd_net -net vio_3_probe_out0 [get_bd_pins a2o_axi_reg_0/reg_in_00] [get_bd_pins vio_3/probe_out0]
  connect_bd_net -net vio_3_probe_out1 [get_bd_pins a2o_axi_reg_0/reg_cmd_00] [get_bd_pins vio_3/probe_out1]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins a2o_axi_reg_0/reg_cmd_01] [get_bd_pins a2o_axi_reg_0/reg_cmd_02] [get_bd_pins a2o_axi_reg_0/reg_cmd_03] [get_bd_pins a2o_axi_reg_0/reg_cmd_04] [get_bd_pins a2o_axi_reg_0/reg_cmd_05] [get_bd_pins a2o_axi_reg_0/reg_cmd_06] [get_bd_pins a2o_axi_reg_0/reg_cmd_07] [get_bd_pins a2o_axi_reg_0/reg_cmd_08] [get_bd_pins a2o_axi_reg_0/reg_cmd_09] [get_bd_pins a2o_axi_reg_0/reg_cmd_0A] [get_bd_pins a2o_axi_reg_0/reg_cmd_0B] [get_bd_pins a2o_axi_reg_0/reg_cmd_0C] [get_bd_pins a2o_axi_reg_0/reg_cmd_0D] [get_bd_pins a2o_axi_reg_0/reg_cmd_0E] [get_bd_pins a2o_axi_reg_0/reg_cmd_0F] [get_bd_pins xlconstant_1/dout]
  connect_bd_net -net xlconstant_2_dout [get_bd_pins a2o_axi_reg_0/reg_in_01] [get_bd_pins a2o_axi_reg_0/reg_in_02] [get_bd_pins a2o_axi_reg_0/reg_in_03] [get_bd_pins a2o_axi_reg_0/reg_in_04] [get_bd_pins a2o_axi_reg_0/reg_in_05] [get_bd_pins a2o_axi_reg_0/reg_in_06] [get_bd_pins a2o_axi_reg_0/reg_in_07] [get_bd_pins a2o_axi_reg_0/reg_in_08] [get_bd_pins a2o_axi_reg_0/reg_in_09] [get_bd_pins a2o_axi_reg_0/reg_in_0A] [get_bd_pins a2o_axi_reg_0/reg_in_0B] [get_bd_pins a2o_axi_reg_0/reg_in_0C] [get_bd_pins a2o_axi_reg_0/reg_in_0D] [get_bd_pins a2o_axi_reg_0/reg_in_0E] [get_bd_pins a2o_axi_reg_0/reg_in_0F] [get_bd_pins xlconstant_2/dout]
  connect_bd_net -net xlconstant_3_dout [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins xlconstant_3/dout]
  connect_bd_net -net xlconstant_4_dout [get_bd_pins proc_sys_reset_0/mb_debug_sys_rst] [get_bd_pins xlconstant_4/dout]

  # Create address segments
  create_bd_addr_seg -range 0x00001000 -offset 0xFFFFF000 [get_bd_addr_spaces a2l2_axi_0/m00_axi] [get_bd_addr_segs a2o_axi_reg_0/s00_axi/reg0] SEG_a2o_axi_reg_0_reg0
  create_bd_addr_seg -range 0x00001000 -offset 0xFFFFE000 [get_bd_addr_spaces a2l2_axi_0/m00_axi] [get_bd_addr_segs a2o_axi_reg_0/s_axi_intr/reg0] SEG_a2o_axi_reg_0_reg01
  create_bd_addr_seg -range 0x00040000 -offset 0x00000000 [get_bd_addr_spaces a2l2_axi_0/m00_axi] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00100000 -offset 0x10000000 [get_bd_addr_spaces a2l2_axi_0/m00_axi] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_3_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0xFE000000 [get_bd_addr_spaces a2l2_axi_0/m00_axi] [get_bd_addr_segs axi_protocol_checker_0/S_AXI/Reg] SEG_axi_protocol_checker_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0xFFFFF000 [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs a2o_axi_reg_0/s00_axi/reg0] SEG_a2o_axi_reg_0_reg0
  create_bd_addr_seg -range 0x00001000 -offset 0xFFFFE000 [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs a2o_axi_reg_0/s_axi_intr/reg0] SEG_a2o_axi_reg_0_reg04
  create_bd_addr_seg -range 0x00040000 -offset 0x00000000 [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00100000 -offset 0x10000000 [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0xFE000000 [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs axi_protocol_checker_0/S_AXI/Reg] SEG_axi_protocol_checker_0_Reg

  # Customize
  set_property SCREENSIZE {10 10} [get_bd_cells /reverserator_3_0]
  set_property SCREENSIZE {10 10} [get_bd_cells /reverserator_3_1]
  set_property SCREENSIZE {10 10} [get_bd_cells /reverserator_3_2]  
  set_property SCREENSIZE {10 10} [get_bd_cells /reverserator_4_0]
  set_property SCREENSIZE {10 10} [get_bd_cells /reverserator_4_1]
  set_property SCREENSIZE {10 10} [get_bd_cells /reverserator_4_2]  
  set_property SCREENSIZE {10 10} [get_bd_cells /reverserator_4_3]
  set_property SCREENSIZE {10 10} [get_bd_cells /reverserator_64_0]
  set_property SCREENSIZE {10 10} [get_bd_cells /xlconstant_1]
  set_property SCREENSIZE {10 10} [get_bd_cells /xlconstant_2]
  set_property SCREENSIZE {10 10} [get_bd_cells /xlconstant_4]
  set_property SCREENSIZE {10 10} [get_bd_cells /xlconstant_3]

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.0.19  2019-03-26 bk=1.5019 VDI=41 GEI=35 GUI=JA:9.0 TLS
#  -string -flagsOSRD
preplace port clk_in1_n_0 -pg 1 -lvl 0 -x -10 -y 1610 -defaultsOSRD
preplace port clk_in1_p_0 -pg 1 -lvl 0 -x -10 -y 1630 -defaultsOSRD
preplace inst a2l2_axi_0 -pg 1 -lvl 8 -x 3730 -y 1090 -defaultsOSRD
preplace inst a2o_axi_reg_0 -pg 1 -lvl 10 -x 4700 -y 390 -defaultsOSRD
preplace inst a2o_dbug_0 -pg 1 -lvl 3 -x 990 -y 1350 -defaultsOSRD
preplace inst axi_bram_ctrl_0 -pg 1 -lvl 10 -x 4700 -y 880 -defaultsOSRD
preplace inst axi_bram_ctrl_1 -pg 1 -lvl 10 -x 4700 -y 1020 -defaultsOSRD
preplace inst axi_protocol_checker_0 -pg 1 -lvl 10 -x 4700 -y 1630 -defaultsOSRD
preplace inst blk_mem_gen_0 -pg 1 -lvl 11 -x 5020 -y 940 -defaultsOSRD
preplace inst blk_mem_gen_1 -pg 1 -lvl 11 -x 5020 -y 1080 -defaultsOSRD
preplace inst c_wrapper_0 -pg 1 -lvl 4 -x 1750 -y 1320 -defaultsOSRD
preplace inst clk_wiz_0 -pg 1 -lvl 1 -x 170 -y 1610 -defaultsOSRD
preplace inst jtag_axi_0 -pg 1 -lvl 8 -x 3730 -y 1480 -defaultsOSRD
preplace inst proc_sys_reset_0 -pg 1 -lvl 7 -x 3220 -y 1640 -defaultsOSRD
preplace inst reverserator_3_0 -pg 1 -lvl 10 -x 4700 -y 1780 -defaultsOSRD -resize 83 88
preplace inst reverserator_3_1 -pg 1 -lvl 10 -x 4700 -y 1370 -defaultsOSRD -resize 83 88
preplace inst reverserator_3_2 -pg 1 -lvl 10 -x 4700 -y 1480 -defaultsOSRD -resize 83 88
preplace inst reverserator_4_0 -pg 1 -lvl 10 -x 4700 -y 1260 -defaultsOSRD -resize 83 88
preplace inst reverserator_4_1 -pg 1 -lvl 5 -x 2360 -y 1220 -defaultsOSRD -resize 83 88
preplace inst reverserator_4_2 -pg 1 -lvl 10 -x 4700 -y 1150 -defaultsOSRD -resize 83 88
preplace inst reverserator_64_0 -pg 1 -lvl 1 -x 170 -y 1410 -defaultsOSRD -resize 83 88
preplace inst smartconnect_0 -pg 1 -lvl 9 -x 4260 -y 1040 -defaultsOSRD
preplace inst system_ila_0 -pg 1 -lvl 9 -x 4260 -y 1500 -defaultsOSRD
preplace inst system_ila_1 -pg 1 -lvl 2 -x 570 -y 1720 -defaultsOSRD
preplace inst vio_0 -pg 1 -lvl 2 -x 570 -y 1410 -defaultsOSRD
preplace inst vio_1 -pg 1 -lvl 6 -x 2720 -y 2050 -defaultsOSRD
preplace inst vio_2 -pg 1 -lvl 11 -x 5020 -y 1470 -defaultsOSRD
preplace inst vio_3 -pg 1 -lvl 9 -x 4260 -y 650 -defaultsOSRD
preplace inst xlconstant_1 -pg 1 -lvl 9 -x 4260 -y 110 -defaultsOSRD -resize 83 88
preplace inst xlconstant_2 -pg 1 -lvl 9 -x 4260 -y 800 -defaultsOSRD -resize 83 88
preplace inst xlconstant_3 -pg 1 -lvl 6 -x 2720 -y 1590 -defaultsOSRD -resize 83 88
preplace inst xlconstant_4 -pg 1 -lvl 6 -x 2720 -y 1700 -defaultsOSRD -resize 83 88
preplace inst reverserator_4_3 -pg 1 -lvl 5 -x 2360 -y 2130 -defaultsOSRD -resize 83 88
preplace netloc Net2 1 2 4 760 1730 NJ 1730 NJ 1730 2470J
preplace netloc a2l2_axi_0_an_ac_reld_core_tag 1 3 6 1490 1680 2130J 1660 2500J 1470 3020J 1530 3410J 1550 4020
preplace netloc a2l2_axi_0_an_ac_reld_crit_qw 1 3 6 1270 710 NJ 710 NJ 710 NJ 710 NJ 710 4050
preplace netloc a2l2_axi_0_an_ac_reld_data 1 3 6 1390 730 NJ 730 NJ 730 NJ 730 NJ 730 3970
preplace netloc a2l2_axi_0_an_ac_reld_data_coming 1 3 6 1260 690 NJ 690 NJ 690 NJ 690 NJ 690 4020
preplace netloc a2l2_axi_0_an_ac_reld_data_vld 1 3 6 1380 720 NJ 720 NJ 720 NJ 720 NJ 720 4010
preplace netloc a2l2_axi_0_an_ac_reld_ecc_err 1 3 6 1410 770 NJ 770 NJ 770 NJ 770 NJ 770 3950
preplace netloc a2l2_axi_0_an_ac_reld_ecc_err_ue 1 3 6 1330 740 NJ 740 NJ 740 NJ 740 NJ 740 4000
preplace netloc a2l2_axi_0_an_ac_reld_l1_dump 1 3 6 1290 750 NJ 750 NJ 750 NJ 750 NJ 750 4040
preplace netloc a2l2_axi_0_an_ac_reld_qw 1 3 6 1430 780 NJ 780 NJ 780 NJ 780 NJ 780 3960
preplace netloc a2l2_axi_0_an_ac_req_ld_pop 1 3 6 1340 790 NJ 790 NJ 790 NJ 790 NJ 790 3990
preplace netloc a2l2_axi_0_an_ac_req_st_gather 1 3 6 1310 800 NJ 800 NJ 800 NJ 800 NJ 800 4030
preplace netloc a2l2_axi_0_an_ac_req_st_pop 1 3 6 1360 810 NJ 810 NJ 810 NJ 810 NJ 810 3980
preplace netloc a2l2_axi_0_an_ac_reservation_vld 1 3 6 1440 1710 2200J 1410 NJ 1410 NJ 1410 NJ 1410 3950
preplace netloc a2l2_axi_0_an_ac_stcx_complete 1 3 6 1470 2330 NJ 2330 NJ 2330 NJ 2330 NJ 2330 3980
preplace netloc a2l2_axi_0_an_ac_stcx_pass 1 3 6 1460 2350 NJ 2350 NJ 2350 NJ 2350 NJ 2350 3970
preplace netloc a2l2_axi_0_an_ac_sync_ack 1 3 6 1480 2360 NJ 2360 NJ 2360 NJ 2360 NJ 2360 3960
preplace netloc a2l2_axi_0_err 1 8 2 NJ 930 4450J
preplace netloc a2o_axi_reg_0_irq 1 8 3 4100 -20 4410J -50 4880
preplace netloc a2o_axi_reg_0_reg_out_00 1 8 3 4110 -10 4420J -40 4870
preplace netloc a2o_dbug_0_cch_out 1 1 3 350 1530 NJ 1530 1170
preplace netloc a2o_dbug_0_dch_out 1 1 3 360 1540 NJ 1540 1190
preplace netloc a2o_dbug_0_err 1 1 3 340 1550 NJ 1550 1180
preplace netloc a2o_dbug_0_rsp_data 1 0 4 10 1520 290J 1560 NJ 1560 1200
preplace netloc a2o_dbug_0_rsp_valid 1 1 3 320 1570 NJ 1570 1210
preplace netloc a2o_dbug_0_threadstop_out 1 3 1 1250 1120n
preplace netloc a2o_dbug_0_trigger_ack_out 1 1 3 330 1580 NJ 1580 1220
preplace netloc a2o_dbug_0_trigger_out 1 3 6 1230 1690 2210J 1670 2510J 1480 3040J 1510 3420J 1560 4110J
preplace netloc a2o_reset_0_reset 1 2 8 790 1740 NJ 1740 2220J 1680 2520J 1490 3000J 1520 3460 760 4090 730 4510
preplace netloc axi_protocol_checker_0_pc_asserted 1 1 10 360 2020 NJ 2020 NJ 2020 NJ 2020 2520 2320 NJ 2320 NJ 2320 NJ 2320 NJ 2320 4870
preplace netloc axi_protocol_checker_0_pc_status 1 1 10 350 1810 NJ 1810 NJ 1810 NJ 1810 NJ 1810 2970J 1840 NJ 1840 NJ 1840 4420J 1850 4890
preplace netloc c_wrapper_0_ac_an_checkstop 1 4 6 2000J 820 NJ 820 NJ 820 NJ 820 4110J 870 4470J
preplace netloc c_wrapper_0_ac_an_local_checkstop 1 4 6 2140J 1390 NJ 1390 NJ 1390 NJ 1390 NJ 1390 4450J
preplace netloc c_wrapper_0_ac_an_machine_check 1 4 6 1980J 830 NJ 830 NJ 830 NJ 830 4100J 880 4460J
preplace netloc c_wrapper_0_ac_an_pm_thread_running 1 4 1 2010J 1130n
preplace netloc c_wrapper_0_ac_an_recov_err 1 4 6 2020J 840 NJ 840 NJ 840 NJ 840 4060J 890 4430J
preplace netloc c_wrapper_0_ac_an_req 1 4 4 2040 1000 NJ 1000 NJ 1000 NJ
preplace netloc c_wrapper_0_ac_an_req_endian 1 4 4 2110J 1070 2550J 1080 NJ 1080 3410
preplace netloc c_wrapper_0_ac_an_req_ld_core_tag 1 4 4 2080J 1080 2540J 1090 NJ 1090 3420
preplace netloc c_wrapper_0_ac_an_req_ld_xfr_len 1 4 4 2100J 1090 2530J 1100 NJ 1100 3430
preplace netloc c_wrapper_0_ac_an_req_pwr_token 1 4 4 2030 990 NJ 990 NJ 990 3430J
preplace netloc c_wrapper_0_ac_an_req_ra 1 4 4 2050 1100 2520J 1110 NJ 1110 3440J
preplace netloc c_wrapper_0_ac_an_req_thread 1 4 4 2060 1110 2510J 1120 NJ 1120 3500J
preplace netloc c_wrapper_0_ac_an_req_ttype 1 4 4 2070 1120 2500J 1130 NJ 1130 3510J
preplace netloc c_wrapper_0_ac_an_req_user_defined 1 4 4 2150J 1140 2470J 1150 NJ 1150 3510
preplace netloc c_wrapper_0_ac_an_req_wimg_g 1 4 4 2120J 1150 2460J 1160 NJ 1160 N
preplace netloc c_wrapper_0_ac_an_req_wimg_i 1 4 4 2090J 1130 2490J 1140 NJ 1140 3500
preplace netloc c_wrapper_0_ac_an_req_wimg_m 1 4 4 2160J 1350 2520J 1330 NJ 1330 3470
preplace netloc c_wrapper_0_ac_an_req_wimg_w 1 4 4 2130J 1380 2550J 1340 NJ 1340 3480
preplace netloc c_wrapper_0_ac_an_st_byte_enbl 1 4 4 2180J 1360 NJ 1360 NJ 1360 3500
preplace netloc c_wrapper_0_ac_an_st_data 1 4 4 2170J 1340 2540J 1370 NJ 1370 3510
preplace netloc c_wrapper_0_ac_an_st_data_pwr_token 1 4 4 2190J 1370 2530J 1350 NJ 1350 3490
preplace netloc clk_in1_n_0_1 1 0 1 NJ 1610
preplace netloc clk_in1_p_0_1 1 0 1 NJ 1630
preplace netloc clk_wiz_0_clk 1 1 10 310 1290 750 1590 1240 1770 NJ 1770 2460 1460 3030 1470 3450 700 4080 900 4480 1860 4900J
preplace netloc clk_wiz_0_clk2x 1 1 3 280J 1160 NJ 1160 1190
preplace netloc clk_wiz_0_clk4x 1 1 3 300J 1180 750J 1170 1220
preplace netloc clk_wiz_0_locked 1 1 6 NJ 1640 NJ 1640 1180J 1780 NJ 1780 NJ 1780 3040
preplace netloc proc_sys_reset_0_mb_reset 1 3 5 1440 940 NJ 940 NJ 940 NJ 940 3400
preplace netloc reverserator_3_0_inndoor 1 10 1 4910 1460n
preplace netloc reverserator_3_1_inndoor 1 10 1 4870 1370n
preplace netloc reverserator_3_2_inndoor 1 10 1 4860 1480n
preplace netloc reverserator_4_0_outtie 1 10 1 4890 1260n
preplace netloc reverserator_4_1_outtie 1 5 1 2490 1220n
preplace netloc reverserator_4_2_outtie 1 10 1 4880 1150n
preplace netloc reverserator_64_0_skidrowwww 1 1 1 NJ 1410
preplace netloc vio_0_probe_out0 1 2 1 N 1350
preplace netloc vio_0_probe_out1 1 2 1 730 1370n
preplace netloc vio_0_probe_out2 1 2 1 740 1370n
preplace netloc vio_0_probe_out3 1 2 1 770 1390n
preplace netloc vio_0_probe_out4 1 2 1 N 1430
preplace netloc vio_0_probe_out5 1 2 1 N 1450
preplace netloc vio_0_probe_out6 1 2 1 N 1470
preplace netloc vio_1_probe_out0 1 2 5 780 1790 NJ 1790 NJ 1790 NJ 1790 2900
preplace netloc vio_1_probe_out1 1 6 1 3000 1640n
preplace netloc vio_1_probe_out2 1 2 5 740 1750 1170J 1800 NJ 1800 NJ 1800 2880
preplace netloc vio_1_probe_out3 1 3 4 1450 950 NJ 950 NJ 950 2950
preplace netloc vio_1_probe_out4 1 3 4 1280 2370 NJ 2370 NJ 2370 2950
preplace netloc vio_1_probe_out5 1 5 2 2550 2290 2900
preplace netloc vio_1_probe_out6 1 3 4 1470 960 NJ 960 NJ 960 2940
preplace netloc vio_1_probe_out7 1 3 4 1350 1750 NJ 1750 2480J 1770 2910
preplace netloc vio_1_probe_out8 1 3 4 1420 1700 NJ 1700 2540J 1510 2930
preplace netloc vio_1_probe_out9 1 3 4 1300 2380 NJ 2380 NJ 2380 2930
preplace netloc vio_1_probe_out10 1 3 4 1450 2310 NJ 2310 NJ 2310 2890
preplace netloc vio_1_probe_out11 1 3 4 1400 2300 NJ 2300 NJ 2300 2880
preplace netloc vio_1_probe_out12 1 3 4 1320 2390 NJ 2390 NJ 2390 2910
preplace netloc vio_1_probe_out14 1 2 5 800 1760 NJ 1760 2240J 1710 2550J 1520 2920
preplace netloc vio_1_probe_out15 1 2 5 810 1720 NJ 1720 2230J 1690 2530J 1500 2960
preplace netloc vio_1_probe_out16 1 3 4 1370 2340 NJ 2340 NJ 2340 2870
preplace netloc vio_1_probe_out17 1 6 2 2980J 970 3410
preplace netloc vio_1_probe_out18 1 6 2 3010J 980 3420
preplace netloc vio_3_probe_out0 1 9 1 4430 380n
preplace netloc vio_3_probe_out1 1 9 1 4420 60n
preplace netloc xlconstant_1_dout 1 9 1 4470 80n
preplace netloc xlconstant_2_dout 1 9 1 4470 400n
preplace netloc xlconstant_3_dout 1 6 1 2970J 1590n
preplace netloc xlconstant_4_dout 1 6 1 2990J 1660n
preplace netloc reverserator_4_3_outtie 1 5 1 2540 2100n
preplace netloc c_wrapper_0_ac_an_debug_trigger 1 4 1 1990 1110n
preplace netloc axi_bram_ctrl_0_BRAM_PORTA 1 10 1 4870J 880n
preplace netloc smartconnect_0_M03_AXI 1 9 1 4500 1000n
preplace netloc smartconnect_0_M02_AXI 1 9 1 4490 860n
preplace netloc jtag_axi_0_M_AXI 1 8 1 4070 1030n
preplace netloc smartconnect_0_M01_AXI 1 9 1 4440 40n
preplace netloc a2l2_axi_0_m00_axi 1 8 2 4060 1400 4410
preplace netloc smartconnect_0_M04_AXI 1 9 1 4420 1080n
preplace netloc smartconnect_0_M00_AXI 1 9 1 4410 20n
preplace netloc axi_bram_ctrl_3_BRAM_PORTA 1 10 1 4880J 1020n
levelinfo -pg 1 -10 170 570 990 1750 2360 2720 3220 3730 4260 4700 5020 5140
pagesize -pg 1 -db -bbox -sgen -150 -60 5140 2430
"
}

  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_a2o_bd()
cr_bd_a2o_bd ""
set_property LIBRARY "work" [get_files a2o_bd.bd ] 
set_property REGISTERED_WITH_MANAGER "1" [get_files a2o_bd.bd ] 
set_property SYNTH_CHECKPOINT_MODE "Hierarchical" [get_files a2o_bd.bd ] 

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -part xcvu3p-ffvc1517-2-e -flow {Vivado Synthesis 2019} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2019" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Synthesis Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'synth_1_synth_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0] "" ] } {
  create_report_config -report_name synth_1_synth_report_utilization_0 -report_type report_utilization:1.0 -steps synth_design -runs synth_1
}
set obj [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0]
if { $obj != "" } {

}
set obj [get_runs synth_1]
set_property -name "part" -value "xcvu3p-ffvc1517-2-e" -objects $obj
set_property -name "strategy" -value "Vivado Synthesis Defaults" -objects $obj
set_property -name "steps.synth_design.args.flatten_hierarchy" -value "none" -objects $obj
set_property -name "steps.synth_design.args.bufg" -value "0" -objects $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -part xcvu3p-ffvc1517-2-e -flow {Vivado Implementation 2019} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2019" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Implementation Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'impl_1_init_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_init_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_init_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps init_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_init_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_opt_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_drc_0] "" ] } {
  create_report_config -report_name impl_1_opt_report_drc_0 -report_type report_drc:1.0 -steps opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_drc_0]
if { $obj != "" } {

}
# Create 'impl_1_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps power_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_place_report_io_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_io_0] "" ] } {
  create_report_config -report_name impl_1_place_report_io_0 -report_type report_io:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_io_0]
if { $obj != "" } {

}
# Create 'impl_1_place_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_utilization_0] "" ] } {
  create_report_config -report_name impl_1_place_report_utilization_0 -report_type report_utilization:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_utilization_0]
if { $obj != "" } {

}
# Create 'impl_1_place_report_control_sets_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_control_sets_0] "" ] } {
  create_report_config -report_name impl_1_place_report_control_sets_0 -report_type report_control_sets:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_control_sets_0]
if { $obj != "" } {
set_property -name "options.verbose" -value "1" -objects $obj

}
# Create 'impl_1_place_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name impl_1_place_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj

}
# Create 'impl_1_place_report_incremental_reuse_1' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_1] "" ] } {
  create_report_config -report_name impl_1_place_report_incremental_reuse_1 -report_type report_incremental_reuse:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_incremental_reuse_1]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj

}
# Create 'impl_1_place_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_place_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps place_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_place_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_post_place_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_post_place_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_post_place_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_place_power_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_post_place_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_route_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_drc_0] "" ] } {
  create_report_config -report_name impl_1_route_report_drc_0 -report_type report_drc:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_drc_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_methodology_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_methodology_0] "" ] } {
  create_report_config -report_name impl_1_route_report_methodology_0 -report_type report_methodology:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_methodology_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_power_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_power_0] "" ] } {
  create_report_config -report_name impl_1_route_report_power_0 -report_type report_power:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_power_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_route_status_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_route_status_0] "" ] } {
  create_report_config -report_name impl_1_route_report_route_status_0 -report_type report_route_status:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_route_status_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_route_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj

}
# Create 'impl_1_route_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name impl_1_route_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_incremental_reuse_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_clock_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_clock_utilization_0] "" ] } {
  create_report_config -report_name impl_1_route_report_clock_utilization_0 -report_type report_clock_utilization:1.0 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_clock_utilization_0]
if { $obj != "" } {

}
# Create 'impl_1_route_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_bus_skew_0] "" ] } {
  create_report_config -report_name impl_1_route_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps route_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_route_report_bus_skew_0]
if { $obj != "" } {
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
# Create 'impl_1_post_route_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name impl_1_post_route_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_route_phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
# Create 'impl_1_post_route_phys_opt_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_bus_skew_0] "" ] } {
  create_report_config -report_name impl_1_post_route_phys_opt_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps post_route_phys_opt_design -runs impl_1
}
set obj [get_report_configs -of_objects [get_runs impl_1] impl_1_post_route_phys_opt_report_bus_skew_0]
if { $obj != "" } {
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
set obj [get_runs impl_1]
set_property -name "part" -value "xcvu3p-ffvc1517-2-e" -objects $obj
set_property -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -name "steps.opt_design.args.more options" -value "-retarget -propconst -bram_power_opt -debug_log" -objects $obj
set_property -name "steps.place_design.args.directive" -value "Explore" -objects $obj
set_property -name "steps.phys_opt_design.is_enabled" -value "1" -objects $obj
set_property -name "steps.phys_opt_design.args.directive" -value "Explore" -objects $obj
set_property -name "steps.route_design.args.directive" -value "Explore" -objects $obj
set_property -name "steps.post_route_phys_opt_design.is_enabled" -value "1" -objects $obj
set_property -name "steps.post_route_phys_opt_design.args.directive" -value "Explore" -objects $obj
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

puts "INFO: Project created:${_xil_proj_name_}"
# Create 'drc_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "drc_1" ] ] ""]} {
create_dashboard_gadget -name {drc_1} -type drc
}
set obj [get_dashboard_gadgets [ list "drc_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_drc_0" -objects $obj

# Create 'methodology_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "methodology_1" ] ] ""]} {
create_dashboard_gadget -name {methodology_1} -type methodology
}
set obj [get_dashboard_gadgets [ list "methodology_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_methodology_0" -objects $obj

# Create 'power_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "power_1" ] ] ""]} {
create_dashboard_gadget -name {power_1} -type power
}
set obj [get_dashboard_gadgets [ list "power_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_power_0" -objects $obj

# Create 'timing_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "timing_1" ] ] ""]} {
create_dashboard_gadget -name {timing_1} -type timing
}
set obj [get_dashboard_gadgets [ list "timing_1" ] ]
set_property -name "reports" -value "impl_1#impl_1_route_report_timing_summary_0" -objects $obj

# Create 'utilization_1' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "utilization_1" ] ] ""]} {
create_dashboard_gadget -name {utilization_1} -type utilization
}
set obj [get_dashboard_gadgets [ list "utilization_1" ] ]
set_property -name "reports" -value "synth_1#synth_1_synth_report_utilization_0" -objects $obj
set_property -name "run.step" -value "synth_design" -objects $obj
set_property -name "run.type" -value "synthesis" -objects $obj

# Create 'utilization_2' gadget (if not found)
if {[string equal [get_dashboard_gadgets  [ list "utilization_2" ] ] ""]} {
create_dashboard_gadget -name {utilization_2} -type utilization
}
set obj [get_dashboard_gadgets [ list "utilization_2" ] ]
set_property -name "reports" -value "impl_1#impl_1_place_report_utilization_0" -objects $obj

move_dashboard_gadget -name {utilization_1} -row 0 -col 0
move_dashboard_gadget -name {power_1} -row 1 -col 0
move_dashboard_gadget -name {drc_1} -row 2 -col 0
move_dashboard_gadget -name {timing_1} -row 0 -col 1
move_dashboard_gadget -name {utilization_2} -row 1 -col 1
move_dashboard_gadget -name {methodology_1} -row 2 -col 1
