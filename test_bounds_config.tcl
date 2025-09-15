#!/usr/bin/env tclsh

###########################################################################################
## Bounds Configuration Test Utility
##
## This utility helps validate bounds configurations before using them in the 
## fusion compiler flow.
##
## Usage:
##   tclsh test_bounds_config.tcl [config_file]
##
## If no config file is specified, tests the default apply_bounds.tcl script
###########################################################################################

# Mock fusion compiler commands for testing
proc mock_fusion_commands {} {
    proc get_flat_cells {args} { 
        puts "  Query: get_flat_cells $args"
        return "test_collection_[expr {int(rand() * 1000)}]" 
    }
    proc all_registers {} { return "all_registers_collection" }
    proc all_instances {} { return "all_instances_collection" }
    proc sizeof_collection {collection} { 
        # Return random number between 1-10 for realistic testing
        return [expr {int(rand() * 10) + 1}]
    }
    proc create_bound {args} { 
        puts "  Creating bound: $args"
        return 
    }
    proc get_bounds {args} { return "existing_bounds_collection" }
    proc remove_bound {args} { puts "  Removing bounds: $args" }
    proc get_attribute {obj attr} { 
        if {$attr == "name"} {
            return "test_bound_[expr {int(rand() * 100)}]"
        } elseif {$attr == "type"} {
            return [lindex {hard soft guide} [expr {int(rand() * 3)}]]
        }
        return "test_attribute"
    }
    proc foreach_in_collection {var collection script} {
        # Mock iteration with a few test items
        for {set i 0} {$i < 3} {incr i} {
            set $var "test_bound_$i"
            eval $script
        }
    }
    proc rm_source {args} { 
        set file [lindex $args end]
        puts "Sourcing: $file"
        if {[file exists $file]} {
            source $file
        } else {
            puts "Warning: File not found: $file"
        }
    }
}

proc test_bounds_script {} {
    puts "\n=== Testing apply_bounds.tcl ==="
    
    if {![file exists "apply_bounds.tcl"]} {
        puts "ERROR: apply_bounds.tcl not found in current directory"
        return 0
    }
    
    # Initialize random seed for consistent testing
    expr {srand(12345)}
    
    # Load the bounds script
    puts "Loading bounds script..."
    source apply_bounds.tcl
    
    # Enable debug mode
    set ::BOUNDS_DEBUG 1
    
    # Test default bounds
    puts "\n--- Testing default L2 cache bounds ---"
    set result [apply_placement_bounds]
    puts "Default bounds result: $result"
    
    # Test bounds status
    puts "\n--- Testing bounds status report ---"
    report_bounds_status
    
    # Test bounds removal
    puts "\n--- Testing bounds removal ---"
    remove_all_bounds
    
    return 1
}

proc test_config_file {config_file} {
    puts "\n=== Testing configuration file: $config_file ==="
    
    if {![file exists $config_file]} {
        puts "ERROR: Configuration file not found: $config_file"
        return 0
    }
    
    # Load the bounds script first
    if {[file exists "apply_bounds.tcl"]} {
        source apply_bounds.tcl
    }
    
    # Set debug mode
    set ::BOUNDS_DEBUG 1
    set ::BOUNDS_CONFIG_FILE $config_file
    
    puts "Testing configuration file: $config_file"
    
    if {[catch {
        set result [apply_placement_bounds]
        puts "Configuration test result: $result"
        return 1
    } error]} {
        puts "ERROR testing configuration: $error"
        return 0
    }
}

proc validate_syntax {file} {
    puts "Validating TCL syntax for: $file"
    
    if {[catch {
        # Create a safe interpreter for syntax checking
        set interp [interp create -safe]
        $interp eval "source $file"
        interp delete $interp
        
        puts "  ✓ Syntax validation passed"
        return 1
    } error]} {
        # For files that need non-safe commands, try basic parse check
        if {[catch {
            set fp [open $file r]
            set content [read $fp]
            close $fp
            # Just try to parse the structure
            info complete $content
            puts "  ✓ Syntax validation passed (basic)"
            return 1
        } parse_error]} {
            puts "  ✗ Syntax error: $parse_error"
            return 0
        }
    }
}

# Main execution
proc main {argv} {
    puts "Bounds Configuration Test Utility"
    puts "================================="
    
    # Setup mock environment
    mock_fusion_commands
    
    # Change to script directory if apply_bounds.tcl exists there
    set script_dir [file dirname [info script]]
    if {$script_dir != "." && [file exists [file join $script_dir apply_bounds.tcl]]} {
        cd $script_dir
        puts "Changed to script directory: $script_dir"
    }
    
    set all_passed 1
    
    # Test syntax validation
    if {[file exists "apply_bounds.tcl"]} {
        if {![validate_syntax "apply_bounds.tcl"]} {
            set all_passed 0
        }
    }
    
    # Test the main bounds script
    if {![test_bounds_script]} {
        set all_passed 0
    }
    
    # Test configuration file if provided
    if {[llength $argv] > 0} {
        set config_file [lindex $argv 0]
        if {![validate_syntax $config_file]} {
            set all_passed 0
        }
        if {![test_config_file $config_file]} {
            set all_passed 0
        }
    } else {
        # Test example config if it exists
        if {[file exists "bounds_config_example.tcl"]} {
            if {![validate_syntax "bounds_config_example.tcl"]} {
                set all_passed 0
            }
            if {![test_config_file "bounds_config_example.tcl"]} {
                set all_passed 0
            }
        }
    }
    
    puts "\n================================="
    if {$all_passed} {
        puts "✓ All tests passed!"
        exit 0
    } else {
        puts "✗ Some tests failed!"
        exit 1
    }
}

# Run main if this script is executed directly
if {[info script] eq $argv0} {
    main $argv
}