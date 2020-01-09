#设置Search路径变量
set ADDITIONAL_SEARCH_PATH      "./libs  ./rtl  ./scripts.  ./netlist  ./report  ./work ./icc"
#设置Target库变量
set TARGET_LIBRARY_FILES        ./libs/db/sc7_ch018ic_base_rvt_ss_typ_max_1p62v_125c.db
#设置Symbol库变量
set SYMBOL_LIBRARY_FILES        ./libs/sdb/sc7_ch018ic_base_rvt.sdb
#设置Milkyway库变量
set MY_MW_LIB                   ./icc/ecc_top_mv
#设置Milkyway参考库变量
set MW_REFERENCE_LIB_DIRS       {./libs/milkyway/1P6M/sc7_ch018ic_base_rvt}
#设置Technology file变量
set TECH_FILE                   ./libs/milkyway/1P6M/sc7_tech.tf
#设置Tluplus file变量
set TLUPLUS_MAX_FILE            ./libs/synopsys_tluplus/1P6M/wst.tluplus
#设置Tluplus file变量
set TLUPLUS_MIN_FILE            ./libs/synopsys_tluplus/1P6M/bst.tluplus
#设置Map file变量
set TLUPLUS_MAP_FILE            ./libs/synopsys_tluplus/1P6M/tluplus.map

set verilog_file                ./netlist/ecc_top_pre_lay.v
set sdc_file                    ./netlist/ecc_top.sdc
set map_file                    ./libs/milkyway/1P6M/stream_out_layer_map
set def_file                    ./netlist/pin_constraints.def

set top_design                  ecc_top
#设置Search路径
set_app_var search_path             "$search_path  $ADDITIONAL_SEARCH_PATH"
#设置Target库
set_app_var target_library          $TARGET_LIBRARY_FILES
#设置Link库($ADDL_LINK_LIBRARY_FILES 如果没有可以删除)
set_app_var link_library            "*  $target_library"
#设置Symbol库
set_app_var symbol_library          $SYMBOL_LIBRARY_FILES
#设置Milkyway库
set_app_var mw_design_library       $MY_MW_LIB
#设置Milkyway参考库
set_app_var mw_reference_library    $MW_REFERENCE_LIB_DIRS
#输出设置
get_app_var -list -only_changed_vars *

set MIN_ROUTING_LAYER  "METAL1"

set MAX_ROUTING_LAYER  "METAL6"