
set old [exec date +%m%d_%H:%M:%S]
if {[file exist ./outputs_fc/${CURRENT_STEP}]} {
    sh mv ./outputs_fc/${CURRENT_STEP} ./outputs_fc/${CURRENT_STEP}_${old}
    sh mkdir ./outputs_fc/${CURRENT_STEP}
} else {
    sh mkdir ./outputs_fc/${CURRENT_STEP}
}

set HASH_VIA_RULE_FILE ""
set HASH_VIA_ASSOC_FILE ""
if {$HASH_VIA_FLOW} {
  if {$HASH_VIA_RULE_FILE == "" || $HASH_VIA_ASSOC_FILE == ""} {
    setup_performance_via_ladder -max_layer $HASH_VIA_MAX_LAYER -association_file ./outputs_fc/${CURRENT_STEP}/VL_asso.tcl -rule ./outputs_fc/${CURRENT_STEP}/VL_rule.tcl -ignore_dont_use -effort $HASH_VIA_EFFORT -smaller
    rm_source -quiet -file ./outputs_fc/${CURRENT_STEP}/VL_asso.tcl ;#(2024.07.01+JWY) Added '-quiet' option.
  } else {
    rm_source -file $TCL_VIA_LADDER_DEFINITION_FILE
    rm_source -file $TCL_SET_VIA_LADDER_CANDIDATE_FILE
  }
}
#attribute setting for via ladder insertion
set_attribute [get_layers -filter "is_routing_layer == true && name =~ D*"] -name number_of_masks -value 0

if {$TCL_PLACEMENT_CONSTRAINT_FILE_LIST != ""} {
	foreach file $TCL_PLACEMENT_CONSTRAINT_FILE_LIST {
		rm_source -file $file
	}
}

redirect -file $REPORTS_DIR/${CURRENT_STEP}/report_cell_groups.rpt  {report_cell_groups} ;#(2024.06.21+JWY+Reports for Variant cells)