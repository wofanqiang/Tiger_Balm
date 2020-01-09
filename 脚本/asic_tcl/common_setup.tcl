#设置Search路径变量
set ADDITIONAL_SEARCH_PATH      "./libs  ./rtl  ./scripts.  ./netlist  ./report  ./work"
#设置Target库变量
set TARGET_LIBRARY_FILES        slow.db
#设置Link库变量
set ADDL_LINK_LIBRARY_FILES     slow.db
#设置Symbol库变量
set SYMBOL_LIBRARY_FILES        tsmc18.sdb
#设置Milkyway库变量
set MY_DESIGN_LIB               ./libs/my_design_lib
#设置Milkyway参考库变量
set MW_REFERENCE_LIB_DIRS       "./libs/mw_libs"
#设置Technology file变量
set TECH_FILE                   ./libs/tech/tsmc18_4lm.tf
#设置Tluplus file变量
set TLUPLUS_MAX_FILE            ./libs/tlup/cb13_6m_max.tluplus
#设置Tluplus file变量
set TLUPLUS_MIN_FILE            ./libs/tlup/cb13_6m_max.tluplus
#设置Map file变量
set MAP_FILE                    ./libs/tlup/cb13_6m.map