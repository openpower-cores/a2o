# ip creator 

set project c_wrapper   ;# also top
set rev "1"
set keep 0              ;# keep project
set xdc ""              ;# set to xdc file if exists
set synth_check 1

proc create_ip {project {keep_project 0} {synth_check 1} {xdc ""} {rev 0.1} } {

   set verilog_dir [file normalize ./verilog] 
   set output_dir .
   set project_dir ./prj

   create_project -force $project $project_dir -part xcvu3p-ffvc1517-2-e

   add_files -norecurse $verilog_dir/trilib
   add_files -norecurse $verilog_dir/work

   update_compile_order -fileset sources_1

   set_property top $project [current_fileset]
   set_property target_language VERILOG [current_project]
   set_property top $project [get_filesets sim_1]
   set_property -name {xsim.compile.xvlog.nosort} -value {false} -objects [get_filesets sim_1]
   set_property simulator_language MIXED [current_project]  
   
   if {$xdc != ""} {
      set xdc_dir [file normalize ./xdc]   
      read_xdc $xdc_dir/$xdc
   }
   
   update_compile_order -fileset sources_1

   if {$synth_check} {
      synth_design -rtl -name elab_for_sanity_check
   }
   
   ipx::package_project -root_dir $output_dir/$project -vendor user.org -library user -taxonomy /UserIP -import_files -set_current false
   ipx::unload_core $output_dir/$project/component.xml
   ipx::edit_ip_in_project -upgrade true -name a2o_edit_project -directory $output_dir/$project $output_dir/$project/component.xml
   update_compile_order -fileset sources_1
   set_property core_revision $rev [ipx::current_core]
   ipx::update_source_project_archive -component [ipx::current_core]
   ipx::create_xgui_files [ipx::current_core]
   ipx::update_checksums [ipx::current_core]
   ipx::save_core [ipx::current_core]
   ipx::move_temp_component_back -component [ipx::current_core]

   if {$keep_project} {
      close_project
      puts "Project built; project dir saved: [file normalize $output_dir/$project_dir]"
   } else {
      close_project -delete
      exec rm -rf $output_dir/$project_dir
      puts "Project built; only IP files kept."
   }

}

create_ip $project $keep $synth_check $xdc $rev
