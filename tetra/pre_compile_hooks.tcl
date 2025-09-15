# This file contains pre_compile stage hooks

# set_false_path -to [all_outputs ];
# set_false_path -from   [remove_from_collection  [all_inputs ]  [all_clocks ] ] ;

switch $CURRENT_STEP {
    compile_initial {
   ## cost groups - ## IMI update 03/11
      set blk_cg "${INPUT_COLLATERAL}/block_receipe/${CONFIG}/cost_groups/${DESIGN_NAME}.tcl"
      if {[file exists ${blk_cg}]} {
        puts "FRM_INFO : Sourcing ${DESIGN_NAME} custom costgroups "
        rm_source -file $blk_cg
      } else {
        puts "FRM_INFO : Sourcing default costgroups "
        rm_source -file /projects/pdcom/user_scripts/apr/costgroups.tcl
      }
    }
    initial_place {
      ### Apply placement bounds using the bounds script
      
      # Source the bounds script
      set bounds_script_path "[file dirname [info script]]/../apply_bounds.tcl"
      if {[file exists $bounds_script_path]} {
          rm_source -file $bounds_script_path
          
          # Configure bounds settings (optional)
          # set BOUNDS_CONFIG_FILE "path/to/your/custom_bounds.tcl"
          # set BOUNDS_DEBUG 1
          
          # Apply bounds
          if {[catch {apply_placement_bounds} bounds_result]} {
              puts "BOUNDS_ERROR: Failed to apply bounds: $bounds_result"
          } else {
              puts "BOUNDS_INFO: Successfully applied $bounds_result bounds"
          }
          
          # Report bounds status
          report_bounds_status
      } else {
          puts "BOUNDS_WARNING: Bounds script not found at $bounds_script_path"
      }
      
      # Legacy bounds code (commented out - replaced by bounds script above)
      #set bank0tag [get_flat_cells [all_registers ] -filter "full_name =~*L2Banks[0].l2_bank/l2_tag/*"]
      #create_bound -name "tags0_hierar_bound"  -boundary {{4.39 620.00} {447 1012}} -type hard [get_cells $bank0tag]
    }
    initial_drc {
    }
    initial_opto {
    }
    final_place {
    }
    final_opto {
    }
}
