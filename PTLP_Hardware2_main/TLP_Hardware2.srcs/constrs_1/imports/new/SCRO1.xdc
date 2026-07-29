#set_property KEEP_HIERARCHY true [get_cells -hier *RO_Instances*]
#set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ *RO_Instances[*].RODCU_i*}]

#create_pblock pb_RO0
#resize_pblock pb_RO0 -add {SLICE_X0Y50:SLICE_X1Y82}
#add_cells_to_pblock pb_RO0 [get_cells -hierarchical -filter {NAME =~ *RO_Instances[0].RODCU_i*}]
###---tamrin:---
#set_property LOC SLICE_X0Y50 [get_cells {RO_Instances[0].RODCU_i/Generate_RO1[0].inst_or_DCU3}]

#create_pblock pb_RO1
#resize_pblock pb_RO1 -add {SLICE_X2Y50:SLICE_X3Y82}
#add_cells_to_pblock pb_RO1 [get_cells -hierarchical -filter {NAME =~ *RO_Instances[1].RODCU_i*}]
#set_property LOC SLICE_X2Y50 [get_cells {RO_Instances[1].RODCU_i/Generate_RO1[0].inst_or_DCU3}]

#create_pblock pb_RO2
#resize_pblock pb_RO2 -add {SLICE_X4Y50:SLICE_X5Y82}
#add_cells_to_pblock pb_RO2 [get_cells -hierarchical -filter {NAME =~ *RO_Instances[2].RODCU_i*}]
#set_property LOC SLICE_X4Y50 [get_cells {RO_Instances[2].RODCU_i/Generate_RO1[0].inst_or_DCU3}]

#create_pblock pb_RO3
#resize_pblock pb_RO3 -add {SLICE_X6Y50:SLICE_X7Y82}
#add_cells_to_pblock pb_RO3 [get_cells -hierarchical -filter {NAME =~ *RO_Instances[3].RODCU_i*}]
#set_property LOC SLICE_X6Y50 [get_cells {RO_Instances[3].RODCU_i/Generate_RO1[0].inst_or_DCU3}]
##set_property LOC {SLICE_X6Y50} [get_cells -hierarchical *RO_Instances[3].RODCU_i*]
##set_property IS_LOC_FIXED true [get_cells -hierarchical *RO_Instances[3].RODCU_i*]

###Regarding the warning "One net in the loop is RO_Instances[0].RODCU_i/D[2]. Please evaluate your design.":
###there's no combinatorial DRC warning with these constraints:
#set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RO_Instances[0].RODCU_i/D[2]}]
#set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RO_Instances[1].RODCU_i/D[2]}]
#set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RO_Instances[2].RODCU_i/D[2]}]
#set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RO_Instances[3].RODCU_i/D[2]}]
###previous form, regarding this error "One net in the loop is SCRO_1/Generate_RO1[0].inst_and_DCU1/REZ":
##set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RO_Instances[3].RODCU_i/Generate_RO1[0].inst_and_DCU1/REZ}]

#set_property KEEP_HIERARCHY true [get_cells -hier *RO_Instances*]
set_property KEEP_HIERARCHY true [get_cells -hier *RODCU_0*]
set_property KEEP_HIERARCHY true [get_cells -hier *RODCU_1*]
set_property KEEP_HIERARCHY true [get_cells -hier *RODCU_2*]
set_property KEEP_HIERARCHY true [get_cells -hier *RODCU_3*]
set_property KEEP_HIERARCHY true [get_cells -hier *RODCU_4*]
set_property KEEP_HIERARCHY true [get_cells -hier *RODCU_5*]
set_property KEEP_HIERARCHY true [get_cells -hier *RODCU_6*]
set_property KEEP_HIERARCHY true [get_cells -hier *RODCU_7*]
set_property KEEP_HIERARCHY true [get_cells -hier *RODCU_8*]
set_property KEEP_HIERARCHY true [get_cells -hier *RODCU_9*]


#set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ *RO_Instances[*].RODCU_i*}]
set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ *RODCU_0*}]
set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ *RODCU_1*}]
set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ *RODCU_2*}]
set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ *RODCU_3*}]
set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ *RODCU_4*}]
set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ *RODCU_5*}]
set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ *RODCU_6*}]
set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ *RODCU_7*}]
set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ *RODCU_8*}]
set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ *RODCU_9*}]

create_pblock pb_RO0
resize_pblock pb_RO0 -add {SLICE_X0Y50:SLICE_X0Y82}
add_cells_to_pblock pb_RO0 [get_cells -hierarchical -filter {NAME =~ *RODCU_0*}]
#set_property LOC SLICE_X0Y50 [get_cells {RODCU_0/Generate_RO1[0].inst_or_DCU3}]

create_pblock pb_RO1
resize_pblock pb_RO1 -add {SLICE_X1Y50:SLICE_X1Y82}
add_cells_to_pblock pb_RO1 [get_cells -hierarchical -filter {NAME =~ *RODCU_1*}]
#set_property LOC SLICE_X2Y50 [get_cells {RODCU_1/Generate_RO1[0].inst_or_DCU3}]

create_pblock pb_RO2
resize_pblock pb_RO2 -add {SLICE_X2Y50:SLICE_X2Y82}
add_cells_to_pblock pb_RO2 [get_cells -hierarchical -filter {NAME =~ *RODCU_2*}]
#set_property LOC SLICE_X4Y50 [get_cells {RODCU_2/Generate_RO1[0].inst_or_DCU3}]

create_pblock pb_RO3
resize_pblock pb_RO3 -add {SLICE_X3Y50:SLICE_X3Y82}
add_cells_to_pblock pb_RO3 [get_cells -hierarchical -filter {NAME =~ *RODCU_3*}]
#set_property LOC SLICE_X6Y50 [get_cells {RODCU_3/Generate_RO1[0].inst_or_DCU3}]

create_pblock pb_RO4
resize_pblock pb_RO4 -add {SLICE_X4Y50:SLICE_X4Y82}
add_cells_to_pblock pb_RO4 [get_cells -hierarchical -filter {NAME =~ *RODCU_4*}]

create_pblock pb_RO5
resize_pblock pb_RO5 -add {SLICE_X5Y50:SLICE_X5Y82}
add_cells_to_pblock pb_RO5 [get_cells -hierarchical -filter {NAME =~ *RODCU_5*}]

create_pblock pb_RO6
resize_pblock pb_RO6 -add {SLICE_X6Y50:SLICE_X6Y82}
add_cells_to_pblock pb_RO6 [get_cells -hierarchical -filter {NAME =~ *RODCU_6*}]

create_pblock pb_RO7
resize_pblock pb_RO7 -add {SLICE_X7Y50:SLICE_X7Y82}
add_cells_to_pblock pb_RO7 [get_cells -hierarchical -filter {NAME =~ *RODCU_7*}]

create_pblock pb_RO8
resize_pblock pb_RO8 -add {SLICE_X8Y50:SLICE_X8Y82}
add_cells_to_pblock pb_RO8 [get_cells -hierarchical -filter {NAME =~ *RODCU_8*}]

create_pblock pb_RO9
resize_pblock pb_RO9 -add {SLICE_X9Y50:SLICE_X9Y82}
add_cells_to_pblock pb_RO9 [get_cells -hierarchical -filter {NAME =~ *RODCU_9*}]

set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RODCU_0/D[2]}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RODCU_1/D[2]}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RODCU_2/D[2]}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RODCU_3/D[2]}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RODCU_4/D[2]}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RODCU_5/D[2]}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RODCU_6/D[2]}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RODCU_7/D[2]}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RODCU_8/D[2]}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets {RODCU_9/D[2]}]