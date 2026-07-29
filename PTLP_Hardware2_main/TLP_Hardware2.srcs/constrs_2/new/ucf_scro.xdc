






#INST "Inst_MUX"  LOC=SLICE_X3Y2;


create_pblock pblock_SCRO_0
create_pblock SCRO
resize_pblock [get_pblocks SCRO] -add {SLICE_X0Y0:SLICE_X3Y3}
create_pblock SCRO_block
resize_pblock [get_pblocks SCRO_block] -add {SLICE_X0Y0:SLICE_X3Y3}

set_property DONT_TOUCH true [get_cells inst_sc]
set_property KEEP_HIERARCHY true [get_cells inst_sc]
