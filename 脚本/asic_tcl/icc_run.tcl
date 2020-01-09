source ./scripts/icc_setup.tcl

create_mw_lib -technology $TECH_FILE -mw_reference_library $MW_REFERENCE_LIB_DIRS -bus_naming_style {[%d]} -open $MY_MW_LIB
set_tlu_plus_files -max_tluplus $TLUPLUS_MAX_FILE  -min_tluplus $TLUPLUS_MIN_FILE  -tech2itf_map $TLUPLUS_MAP_FILE
import_designs $verilog_file -format verilog -top $top_design
#check_library

check_tlu_plus_files
list_libs
link

read_pin_pad_physical_constraints $def_file

create_floorplan -core_aspect_ratio 1 -core_utilization 0.6 -left_io2core 10 -bottom_io2core 10 -right_io2core 10 -top_io2core 10

add_end_cap -respect_keepout -respect_blockage -lib_cell FILLCAP4_A7TR

save_mw_cel -as ecc_top_setup

derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}

check_mv_design -power_nets

save_mw_cel -as ecc_top_prepg

create_rectangular_rings  -nets  {VSS VDD}  -left_segment_width 3 -right_segment_width 3 -bottom_segment_width 3 -top_segment_width 3 -top_offset 3 -bottom_offset 3
create_power_straps  -direction vertical  -start_at 10 -num_placement_strap 999 -increment_x_or_y 50 -nets  {VDD VSS}  -layer  METAL4  -width 1 -pitch_within_group 25

derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}

read_sdc $sdc_file
check_timing
report_timing_requirements
report_disable_timing
report_case_analysis
report_clock 
##source $ctrl_file
save_mw_cel -as ecc_top_floorplanned


preroute_standard_cells-nets {VDD VSS} \

      -connect horizontal \

      -fill_empty_rows \

      -port_filter_mode off \

      -cell_master_filter_mode off \

      -cell_instance_filter_mode off \

      -voltage_area_filter_mode off \

      -route_type {P/G Std. Cell Pin Conn}

place_opt 
redirect -tee place_opt.timing {report_timing}
report_congestion -grc_based -by_layer  -routing_stage global
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
preroute_standard_cells -connect horizontal  -port_filter_mode off -cell_master_filter_mode off -cell_instance_filter_mode off -voltage_area_filter_mode off -route_type {P/G Std. Cell Pin Conn}
verify_pg_nets
preroute_standard_cells -connect horizontal  -remove_floating_pieces
save_mw_cel -as ecc_top_placed   

remove_clock_uncertainty [all_clocks] 
set_fix_hold [all_clocks] 
compile_clock_tree  -clock_trees {sys_clk} -sync_phase rise
compile_clock_tree  -clock_trees {spi_clk} -sync_phase rise
report_clock_tree  -clock_trees {sys_clk} -operating_condition max
report_clock_tree  -clock_trees {spi_clk} -operating_condition max
clock_opt 

redirect -tee clock_opt.timing {report_timing}      
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
save_mw_cel -as ecc_top_cts    
##source $ctrl_file
set_ignored_layers -max_routing_layer $MAX_ROUTING_LAYER
route_opt
report_timing -nosplit
report_timing -delay min  
report_design -physical
save_mw_cel -as ecc_top_routed
verify_zrt_route
verify_lvs
extract_rc


#Performs  postroute  optimization to fix setup, hold, or logical design rule constraint violations, reduce crosstalk,  or  reduce leakage  power.  
#       The selected optimization is referred to as the focal metric.
focal_opt -drc_nets all -effort high 
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
derive_pg_connection -power_net {VDD} -ground_net {VSS} -tie
verify_zrt_route
verify_lvs
extract_rc
#
report_constraint -all_violators

#By default, the tool adds the filler cells in the order that you specify, so specify them from the largest to smallest. To insert
#the filler cells in random order, use the -randomize option.
insert_stdcell_filler  -cell_with_metal "FILLCAP4_A7TR FILLCAP16_A7TR FILLCAP32_A7TR FILLCAP64_A7TR FILLCAP8_A7TR"  -connect_to_power VDD -connect_to_ground gnd  -ignore_soft_placement_blockage

# -routing_space route_space Specifies the space between normal routing wires  and  the  fill
# metal.   This value is multiplied by the minSpacing of the metal layer.  The default is 1.0.
insert_metal_filler -routing_space 2 -timing_driven -from_metal 1 -to_metal 5     
extract_rc

define_name_rules myrule -case_insensitive 
change_names -rules myrule -hierarchy
write_parasitics
write_sdf -version 2.1 adc_digital.sdf
write_verilog -no_core_filler_cells -no_tap_cells -pg -diode_ports adc_digital.v
set_write_stream_options -map_layer $map_file  -child_depth 10   -output_filling {fill} -output_pin {text} -output_net {text}
save_mw_cel -as digital
write_stream -format gds -lib_name $MY_MW_LIB -cells {digital } adc_digital.gds
#
