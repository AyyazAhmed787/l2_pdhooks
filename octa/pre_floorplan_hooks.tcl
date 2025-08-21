###########################################################################################
## Place Macros/Memories -Floorplan TCL file 
###########################################################################################
if {$USER_MACRO_PLACEMENT_TCL_FILE != ""} {
		puts "FRM_INFO: sourcing user macro placement file $USER_MACRO_PLACEMENT_TCL_FILE"
   rm_source -file $USER_MACRO_PLACEMENT_TCL_FILE
}  