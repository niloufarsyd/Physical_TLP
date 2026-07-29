copy_macro_placement -source_macro RO_MACRO -target_macro RO_MACRO_1
copy_macro_placement -source_macro RO_MACRO -target_macro RO_MACRO_2
copy_macro_placement -source_macro RO_MACRO -target_macro RO_MACRO_3
set_property MACRO true [get_cells -of_objects [get_macro RO_MACRO]]