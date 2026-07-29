gui_open_window Wave
gui_sg_create DCM1_group
gui_list_add_group -id Wave.1 {DCM1_group}
gui_sg_addsignal -group DCM1_group {DCM1_tb.test_phase}
gui_set_radix -radix {ascii} -signals {DCM1_tb.test_phase}
gui_sg_addsignal -group DCM1_group {{Input_clocks}} -divider
gui_sg_addsignal -group DCM1_group {DCM1_tb.CLK_IN1}
gui_sg_addsignal -group DCM1_group {{Output_clocks}} -divider
gui_sg_addsignal -group DCM1_group {DCM1_tb.dut.clk}
gui_list_expand -id Wave.1 DCM1_tb.dut.clk
gui_sg_addsignal -group DCM1_group {{Counters}} -divider
gui_sg_addsignal -group DCM1_group {DCM1_tb.COUNT}
gui_sg_addsignal -group DCM1_group {DCM1_tb.dut.counter}
gui_list_expand -id Wave.1 DCM1_tb.dut.counter
gui_zoom -window Wave.1 -full
