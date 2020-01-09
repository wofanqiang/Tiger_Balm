reset_design

#************************************
#*************clock******************
#************************************
create_clock -period 5.4 -waveform {0 2.7} -name sys_clk [get_ports clk]
set_ideal_network [get_ports clk]
set_dont_touch_network [get_clocks sys_clk]
set_fix_hold [get_clocks sys_clk]
set_clock_uncertainty -setup 0.2 [get_clocks sys_clk]
set_clock_uncertainty -hold 0.2 [get_clocks sys_clk]
set_clock_latency -max 1 [get_clocks sys_clk]
set_clock_transition -max 0.3 [get_clocks sys_clk]


create_clock -period 40 -waveform {0 20} -name spi_clk [get_ports sclk]
set_ideal_network [get_ports sclk]
set_dont_touch_network [get_clocks spi_clk]
set_fix_hold [get_clocks spi_clk]
set_clock_uncertainty -setup 0.2 [get_clocks spi_clk]
set_clock_uncertainty -hold 0.2 [get_clocks spi_clk]
set_clock_latency -max 1 [get_clocks spi_clk]
set_clock_transition -max 0.3 [get_clocks spi_clk]

set_false_path -from [get_clocks sys_clk] -to [get_clocks spi_clk]
set_false_path -from [get_clocks spi_clk] -to [get_clocks sys_clk]


#************************************
#*************input******************
#************************************
set_input_delay -max 16 -clock spi_clk [get_ports "nss mosi"]
set_input_delay -min 12 -clock spi_clk [get_ports "nss mosi"]
#set_drive [expr 0.288001] [all_inputs]


#************************************
#*************output*****************
#************************************
set_output_delay -max 3.8 -clock sys_clk [get_ports "ecc_idle wait_data data_valid trnd"]
set_output_delay -min 1.6 -clock sys_clk [get_ports "ecc_idle wait_data data_valid trnd"]
set_output_delay -max 16 -clock spi_clk [get_ports miso]
set_output_delay -min 12 -clock spi_clk [get_ports miso]
#set_load [expr $MAX_LOAD*5] [all_outputs]
#set_load [expr 0.06132] [all_outputs]


#************************************
#***************reset****************
#************************************
#set_ideal_network [get_ports rst]
#set_dont_touch_network [get_ports rst]
set_false_path -from rst


#************************************
#**************wire******************
#************************************
#set_wire_load_model -name smic18_wl10 -library slow
set auto_wire_load_selection true
#set_wire_load_mode  top
#set_wire_load_mode   enclosed
#set_wire_load_model -name ""
#set_operating_conditions WORST

#************************************
#**************area******************
#************************************
#set_max_area 0
#set_max_fanout 50 [get_designs *]


