
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name AVA6STest -dir "D:/darsi/iot/puf/PUF/code/mine/ex15_new_board/AVA6SV2_DIPLED/planAhead_run_1" -part xc6slx9tqg144-3
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "D:/darsi/iot/puf/PUF/code/mine/ex15_new_board/AVA6SV2_DIPLED/AVA6STest_TopModule.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/darsi/iot/puf/PUF/code/mine/ex15_new_board/AVA6SV2_DIPLED} {ipcore_dir} }
set_property target_constrs_file "uuccff.ucf" [current_fileset -constrset]
add_files [list {uuccff.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "D:/darsi/iot/puf/PUF/code/mine/ex15_new_board/AVA6SV2_DIPLED/AVA6STest_TopModule.ncd"
if {[catch {read_twx -name results_1 -file "D:/darsi/iot/puf/PUF/code/mine/ex15_new_board/AVA6SV2_DIPLED/AVA6STest_TopModule.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"D:/darsi/iot/puf/PUF/code/mine/ex15_new_board/AVA6SV2_DIPLED/AVA6STest_TopModule.twx\": $eInfo"
}
