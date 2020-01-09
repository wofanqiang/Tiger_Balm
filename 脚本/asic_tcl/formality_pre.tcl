set active_design 	            ecc_top
set hdl_file			../rtl/ecc_top.v
set link_lib                 	../libs/db/sc7_ch018ic_base_rvt_ss_typ_max_1p62v_125c.db
set DESIGN_SVF	            	../${active_design}.svf
set NETLIST_V               	../netlist/${active_design}_pre_lay.v

set_svf  ${DESIGN_SVF}

set DATE		[ sh date +%m%d ]
set SESSION		${active_design}_${DATE}

sh rm -rf	${SESSION}.run
sh mkdir	${SESSION}.run


read_db ${link_lib}
###########################read ref files########################################
read_verilog -container r -libname WORK -05 $hdl_file

set_top r:/WORK/${active_design}


###########################read imp files########################################
read_verilog -container i -libname WORK -05 $NETLIST_V

set_top i:/WORK/${active_design}


################################################################################
match
  
report_unmatched_points > ${SESSION}.run/report_unmatched_points.txt
report_matched_points   > ${SESSION}.run/report_matched_points.txt


################################################################################
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r11_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r13_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r15_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r17_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r19_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r21_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r23_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r25_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r27_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r29_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r31_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r33_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r35_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r37_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r39_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r3_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r5_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r7_reg 
#set_dont_verify r:/WORK/ecc_top/u_rand256_u_rng_u0_r9_reg 
################################################################################



set result [verify]
  
report_failing > ${SESSION}.run/report_failing.txt
report_passing > ${SESSION}.run/report_passing.txt
report_aborted > ${SESSION}.run/report_aborted.txt
report_unverified > ${SESSION}.run/report_unverified.txt
  
if { $result == 1 } {
	exit
} else {
	save_session ${SESSION}.run/fail.session -replace
	start_gui
}
