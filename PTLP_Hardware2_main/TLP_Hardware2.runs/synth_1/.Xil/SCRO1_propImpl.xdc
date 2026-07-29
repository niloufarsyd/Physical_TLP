set_property SRC_FILE_INFO {cfile:D:/projects/TLP_Hardware2/TLP_Hardware2.srcs/constrs_2/new/SCRO1.xdc rfile:../../../TLP_Hardware2.srcs/constrs_2/new/SCRO1.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:1 export:INPUT save:INPUT read:READ} [current_design]
create_pblock ro_group
add_cells_to_pblock [get_pblocks ro_group] [get_cells -quiet [list SCRO_1]]
resize_pblock [get_pblocks ro_group] -add {SLICE_X0Y50:SLICE_X1Y68}
set_property CONTAIN_ROUTING 1 [get_pblocks ro_group]
set_property src_info {type:XDC file:1 line:8 export:INPUT save:INPUT read:READ} [current_design]
create_pblock ro_group2
add_cells_to_pblock [get_pblocks ro_group2] [get_cells -quiet [list SCRO_2]]
resize_pblock [get_pblocks ro_group2] -add {SLICE_X2Y50:SLICE_X3Y68}
set_property CONTAIN_ROUTING 1 [get_pblocks ro_group2]
set_property src_info {type:XDC file:1 line:13 export:INPUT save:INPUT read:READ} [current_design]
create_pblock ro_group3
add_cells_to_pblock [get_pblocks ro_group3] [get_cells -quiet [list SCRO_3]]
resize_pblock [get_pblocks ro_group3] -add {SLICE_X0Y70:SLICE_X1Y90}
