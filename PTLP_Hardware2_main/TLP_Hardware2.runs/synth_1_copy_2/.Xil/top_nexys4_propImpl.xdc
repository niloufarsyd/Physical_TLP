set_property SRC_FILE_INFO {cfile:D:/projects/TLP_Hardware2/TLP_Hardware2.srcs/constrs_2/imports/nexys4ddr/nexys4ddr.xdc rfile:../../../TLP_Hardware2.srcs/constrs_2/imports/nexys4ddr/nexys4ddr.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:8 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN E3 [get_ports clk]
set_property src_info {type:XDC file:1 line:11 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN C4 [get_ports uart_rx]
set_property src_info {type:XDC file:1 line:12 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN D4 [get_ports uart_tx]
set_property src_info {type:XDC file:1 line:16 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN C12 [get_ports rst]
set_property src_info {type:XDC file:1 line:19 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports puf_done1]
set_property src_info {type:XDC file:1 line:20 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports puf_start1]
set_property src_info {type:XDC file:1 line:21 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports puf_busy]
set_property src_info {type:XDC file:1 line:22 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN H17 [get_ports led0]
set_property src_info {type:XDC file:1 line:24 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN K15 [get_ports led1]
set_property src_info {type:XDC file:1 line:26 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN J13 [get_ports led2]
set_property src_info {type:XDC file:1 line:28 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN N14 [get_ports led3]
set_property src_info {type:XDC file:1 line:30 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN R18 [get_ports led4]
set_property src_info {type:XDC file:1 line:32 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN V17 [get_ports led5]
set_property src_info {type:XDC file:1 line:34 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN U17 [get_ports led6]
set_property src_info {type:XDC file:1 line:36 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN U16 [get_ports led7]
set_property src_info {type:XDC file:1 line:38 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN V16 [get_ports led8]
set_property src_info {type:XDC file:1 line:40 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN T15 [get_ports led9]
set_property src_info {type:XDC file:1 line:42 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN U14 [get_ports led10]
set_property src_info {type:XDC file:1 line:44 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN T16 [get_ports led11]
set_property src_info {type:XDC file:1 line:46 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN V15 [get_ports led12]
set_property src_info {type:XDC file:1 line:86 export:INPUT save:INPUT read:READ} [current_design]
create_pblock pb_RO0
add_cells_to_pblock [get_pblocks pb_RO0] [get_cells -quiet [list u_puf/RODCU_0]]
resize_pblock [get_pblocks pb_RO0] -add {SLICE_X0Y50:SLICE_X1Y82}
set_property src_info {type:XDC file:1 line:91 export:INPUT save:INPUT read:READ} [current_design]
create_pblock pb_RO1
add_cells_to_pblock [get_pblocks pb_RO1] [get_cells -quiet [list u_puf/RODCU_1]]
resize_pblock [get_pblocks pb_RO1] -add {SLICE_X0Y50:SLICE_X1Y82}
set_property src_info {type:XDC file:1 line:96 export:INPUT save:INPUT read:READ} [current_design]
create_pblock pb_RO2
add_cells_to_pblock [get_pblocks pb_RO2] [get_cells -quiet [list u_puf/RODCU_2]]
resize_pblock [get_pblocks pb_RO2] -add {SLICE_X2Y50:SLICE_X3Y82}
set_property src_info {type:XDC file:1 line:101 export:INPUT save:INPUT read:READ} [current_design]
create_pblock pb_RO3
add_cells_to_pblock [get_pblocks pb_RO3] [get_cells -quiet [list u_puf/RODCU_3]]
resize_pblock [get_pblocks pb_RO3] -add {SLICE_X2Y50:SLICE_X3Y82}
set_property src_info {type:XDC file:1 line:106 export:INPUT save:INPUT read:READ} [current_design]
create_pblock pb_RO4
add_cells_to_pblock [get_pblocks pb_RO4] [get_cells -quiet [list u_puf/RODCU_4]]
resize_pblock [get_pblocks pb_RO4] -add {SLICE_X4Y50:SLICE_X5Y82}
set_property src_info {type:XDC file:1 line:111 export:INPUT save:INPUT read:READ} [current_design]
create_pblock pb_RO5
add_cells_to_pblock [get_pblocks pb_RO5] [get_cells -quiet [list u_puf/RODCU_5]]
resize_pblock [get_pblocks pb_RO5] -add {SLICE_X4Y50:SLICE_X5Y82}
set_property src_info {type:XDC file:1 line:116 export:INPUT save:INPUT read:READ} [current_design]
create_pblock pb_RO6
add_cells_to_pblock [get_pblocks pb_RO6] [get_cells -quiet [list u_puf/RODCU_6]]
resize_pblock [get_pblocks pb_RO6] -add {SLICE_X6Y50:SLICE_X7Y82}
set_property src_info {type:XDC file:1 line:121 export:INPUT save:INPUT read:READ} [current_design]
create_pblock pb_RO7
add_cells_to_pblock [get_pblocks pb_RO7] [get_cells -quiet [list u_puf/RODCU_7]]
resize_pblock [get_pblocks pb_RO7] -add {SLICE_X6Y50:SLICE_X7Y82}
set_property src_info {type:XDC file:1 line:126 export:INPUT save:INPUT read:READ} [current_design]
create_pblock pb_RO8
add_cells_to_pblock [get_pblocks pb_RO8] [get_cells -quiet [list u_puf/RODCU_8]]
resize_pblock [get_pblocks pb_RO8] -add {SLICE_X8Y50:SLICE_X9Y82}
set_property src_info {type:XDC file:1 line:131 export:INPUT save:INPUT read:READ} [current_design]
create_pblock pb_RO9
add_cells_to_pblock [get_pblocks pb_RO9] [get_cells -quiet [list u_puf/RODCU_9]]
resize_pblock [get_pblocks pb_RO9] -add {SLICE_X8Y50:SLICE_X9Y82}
