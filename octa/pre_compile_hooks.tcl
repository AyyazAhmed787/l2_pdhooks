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
      ### create placement bound

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
