if {$CURRENT_STEP == "floorplan"} {
####################################################################################################################################################
## IMI updated 03/11 
    set custom_sdc "${INPUT_COLLATERAL}/constraints/custom/${CONFIG}/${DESIGN_NAME}.sdc"
    if {[file exists ${custom_sdc}]} {
        rm_source -file ${custom_sdc}
      }
}