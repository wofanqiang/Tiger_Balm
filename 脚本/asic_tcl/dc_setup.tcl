set ADDITIONAL_SEARCH_PATH      "./libs  ./rtl  ./scripts.  ./netlist ./dc  ./dc/work"
#设置Target库变量
set TARGET_LIBRARY_FILES        ./libs/db/sc7_ch018ic_base_rvt_ss_typ_max_1p62v_125c.db
#设置Symbol库变量
set SYMBOL_LIBRARY_FILES        ./libs/sdb/sc7_ch018ic_base_rvt.sdb

#设置Search路径
set_app_var search_path             "$search_path  $ADDITIONAL_SEARCH_PATH"
#设置Target库
set_app_var target_library          $TARGET_LIBRARY_FILES
#设置Link库($ADDL_LINK_LIBRARY_FILES 如果没有可以删除)
set_app_var link_library            "*  $target_library"
#设置Symbol库
set_app_var symbol_library          $SYMBOL_LIBRARY_FILES

get_app_var -list -only_changed_vars *



set_host_options -max_cores 16
#************************************
#**********set variables*************
#************************************
#将下面语句中的“top”换成需要综合的顶层模块名
set active_design 	          ecc_top

#source ./scripts/common_setup.tcl

sh mkdir dc
sh mkdir ./dc/report_dc
sh mkdir netlist
sh mkdir ./dc/work

set REPORT_PATH             ./dc/report_dc
set MAPPED_DDC              ./dc/${active_design}_mapped.ddc
set UNMAPPED_DDC            ./dc/${active_design}_unmapped.ddc
set DESIGN_DB	            ./$active_design.db
set DESIGN_SVF	            ./$active_design.svf
set NETLIST_V               ./netlist/${active_design}_pre_lay.v
set SDF                     ./netlist/$active_design.sdf
set SDC                     ./netlist/$active_design.sdc