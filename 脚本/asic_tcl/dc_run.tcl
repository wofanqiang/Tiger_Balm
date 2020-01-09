source ./scripts/dc_setup.tcl

set_svf  $DESIGN_SVF

#************************************
#***********read design**************
#************************************
analyze -f verilog  { ecc_top.v }

elaborate $active_design

current_design $active_design

redirect -tee -file $REPORT_PATH/link.txt      {link};

write_file -format ddc -hierarchy -output $UNMAPPED_DDC

uniquify

source ./scripts/constraints.tcl

#************************************
#**************compile***************
#************************************
#set_structure  true
set_fix_multiple_port_nets -all -constants -buffer_constants [get_designs *]
#compile_ultra -timing -retime -no_autoungroup
#compile_ultra -retime -timing
compile_ultra

#compile_ultra -timing -retime -incremental

#************************************
#*************report*****************
#************************************
redirect -tee -file $REPORT_PATH/check_design.txt      {check_design                    };
redirect -tee -file $REPORT_PATH/check_timing.txt      {check_timing                    };
redirect -tee -file $REPORT_PATH/report_clock.txt      {report_clock -skew -attr        };
redirect -tee -file $REPORT_PATH/report_port.txt       {report_port -verbose            };
redirect -tee -file $REPORT_PATH/report_constraint.txt {report_constraint -all_violators};
redirect -tee -file $REPORT_PATH/report_timing.txt     {report_timing -max_paths 10  	};
redirect -tee -file $REPORT_PATH/report_area.txt       {report_area                     };
redirect -tee -file $REPORT_PATH/report_qor.txt        {report_qor                      };

#************************************
#**************write*****************
#************************************
set_app_var verilogout_no_tri true
set_app_var verilogout_equation false
change_names -rule verilog -hier

write_file -hierarchy -output $DESIGN_DB
write_file -format ddc -hierarchy -output $MAPPED_DDC
write_file -format verilog -hierarchy -output $NETLIST_V
write_sdf $SDF
write_sdc $SDC
set_svf -off



