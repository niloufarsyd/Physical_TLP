
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name AVA6STest -dir "F:/iot/puf/PUF/code/mine/ex24/planAhead_run_3" -part xc6slx9tqg144-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "F:/iot/puf/PUF/code/mine/ex24/AVA6STest_TopModule_cs.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {F:/iot/puf/PUF/code/mine/ex24} {ipcore_dir} }
set_property target_constrs_file "uuccff.ucf" [current_fileset -constrset]
add_files [list {uuccff.ucf}] -fileset [get_property constrset [current_run]]
link_design
