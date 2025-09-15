###########################################################################################
## Apply Bounds Script for Fusion Compiler
## 
## This script provides a comprehensive solution for applying placement bounds
## in the fusion compiler place & route flow.
##
## Usage:
##   rm_source -file apply_bounds.tcl
##   apply_placement_bounds
##
## Configuration:
##   Set BOUNDS_CONFIG_FILE to specify custom bounds configuration
##   Default behavior uses predefined bounds for common design patterns
###########################################################################################

# Global variables for bounds configuration
set BOUNDS_ENABLED 1
set BOUNDS_CONFIG_FILE ""
set BOUNDS_DEFAULT_TYPE "hard"
set BOUNDS_DEBUG 0

# Procedure to log bounds information
proc bounds_log {message} {
    global BOUNDS_DEBUG
    if {![info exists BOUNDS_DEBUG]} {
        set BOUNDS_DEBUG 0
    }
    if {$BOUNDS_DEBUG || [info exists ::ENABLE_BOUNDS_DEBUG]} {
        puts "BOUNDS_INFO: $message"
    }
}

# Procedure to validate bound coordinates
proc validate_bound_coordinates {coordinates} {
    if {[llength $coordinates] != 2} {
        return 0
    }
    foreach coord $coordinates {
        if {[llength $coord] != 2} {
            return 0
        }
        if {![string is double [lindex $coord 0]] || ![string is double [lindex $coord 1]]} {
            return 0
        }
    }
    return 1
}

# Procedure to create a single bound
proc create_placement_bound {bound_name cell_collection boundary_coords bound_type} {
    bounds_log "Creating bound: $bound_name with type: $bound_type"
    
    # Validate coordinates
    if {![validate_bound_coordinates $boundary_coords]} {
        puts "BOUNDS_ERROR: Invalid coordinates for bound $bound_name: $boundary_coords"
        return 0
    }
    
    # Check if cells exist
    if {[sizeof_collection $cell_collection] == 0} {
        bounds_log "No cells found for bound $bound_name - skipping"
        return 0
    }
    
    # Validate bound type
    if {$bound_type ni {hard soft guide}} {
        puts "BOUNDS_ERROR: Invalid bound type '$bound_type' for bound $bound_name. Using 'hard'"
        set bound_type "hard"
    }
    
    # Create the bound
    if {[catch {
        create_bound -name $bound_name -boundary $boundary_coords -type $bound_type $cell_collection
    } error]} {
        puts "BOUNDS_ERROR: Failed to create bound $bound_name: $error"
        return 0
    } else {
        bounds_log "Successfully created bound: $bound_name for [sizeof_collection $cell_collection] cells"
        return 1
    }
}

# Procedure to apply predefined bounds for L2 cache design
proc apply_l2_cache_bounds {} {
    bounds_log "Applying L2 cache specific bounds"
    
    # Example bounds for L2 cache banks - these can be customized
    set bound_configs {
        {
            name "l2_bank0_tags_bound"
            pattern "*L2Banks\[0\].l2_bank/l2_tag/*"
            boundary {{50.0 600.0} {450.0 1000.0}}
            type "hard"
            cell_type "registers"
        }
        {
            name "l2_bank1_tags_bound" 
            pattern "*L2Banks\[1\].l2_bank/l2_tag/*"
            boundary {{500.0 600.0} {900.0 1000.0}}
            type "hard"
            cell_type "registers"
        }
        {
            name "l2_data_array_bound"
            pattern "*l2_data/*"
            boundary {{50.0 100.0} {900.0 500.0}}
            type "soft"
            cell_type "all_cells"
        }
    }
    
    set bounds_created 0
    foreach config $bound_configs {
        set bound_name [dict get $config name]
        set pattern [dict get $config pattern]
        set boundary [dict get $config boundary]
        set bound_type [dict get $config type]
        set cell_type [dict get $config cell_type]
        
        # Get cells based on type
        switch $cell_type {
            "registers" {
                set cells [get_flat_cells [all_registers] -filter "full_name =~ $pattern"]
            }
            "instances" {
                set cells [get_flat_cells [all_instances] -filter "full_name =~ $pattern"]
            }
            "all_cells" {
                set cells [get_flat_cells * -filter "full_name =~ $pattern"]
            }
            default {
                set cells [get_flat_cells [all_registers] -filter "full_name =~ $pattern"]
            }
        }
        
        if {[create_placement_bound $bound_name $cells $boundary $bound_type]} {
            incr bounds_created
        }
    }
    
    bounds_log "Created $bounds_created bounds for L2 cache design"
    return $bounds_created
}

# Procedure to apply bounds from configuration file
proc apply_bounds_from_config {config_file} {
    bounds_log "Loading bounds configuration from: $config_file"
    
    if {![file exists $config_file]} {
        puts "BOUNDS_ERROR: Configuration file not found: $config_file"
        return 0
    }
    
    if {[catch {
        source $config_file
    } error]} {
        puts "BOUNDS_ERROR: Failed to load configuration file $config_file: $error"
        return 0
    } else {
        bounds_log "Successfully loaded bounds configuration"
        return 1
    }
}

# Procedure to remove all existing bounds
proc remove_all_bounds {} {
    bounds_log "Removing all existing bounds"
    
    if {[catch {
        set existing_bounds [get_bounds *]
        if {[sizeof_collection $existing_bounds] > 0} {
            remove_bound $existing_bounds
            bounds_log "Removed [sizeof_collection $existing_bounds] existing bounds"
        } else {
            bounds_log "No existing bounds to remove"
        }
    } error]} {
        bounds_log "Warning: Could not remove existing bounds: $error"
    }
}

# Main procedure to apply placement bounds
proc apply_placement_bounds {{force_refresh 0}} {
    global BOUNDS_ENABLED BOUNDS_CONFIG_FILE BOUNDS_DEFAULT_TYPE
    
    # Initialize global variables if not set
    if {![info exists BOUNDS_ENABLED]} { set BOUNDS_ENABLED 1 }
    if {![info exists BOUNDS_CONFIG_FILE]} { set BOUNDS_CONFIG_FILE "" }
    if {![info exists BOUNDS_DEFAULT_TYPE]} { set BOUNDS_DEFAULT_TYPE "hard" }
    
    bounds_log "Starting apply_placement_bounds procedure"
    
    # Check if bounds are enabled
    if {!$BOUNDS_ENABLED} {
        bounds_log "Bounds application is disabled"
        return 0
    }
    
    # Remove existing bounds if force refresh is requested
    if {$force_refresh} {
        remove_all_bounds
    }
    
    set total_bounds 0
    
    # Apply bounds from configuration file if specified
    if {$BOUNDS_CONFIG_FILE != "" && [file exists $BOUNDS_CONFIG_FILE]} {
        if {[apply_bounds_from_config $BOUNDS_CONFIG_FILE]} {
            bounds_log "Applied bounds from configuration file"
        }
    } else {
        # Apply default L2 cache bounds
        set total_bounds [apply_l2_cache_bounds]
    }
    
    bounds_log "Completed bounds application. Total bounds processed: $total_bounds"
    return $total_bounds
}

# Procedure to report current bounds status
proc report_bounds_status {} {
    bounds_log "=== Bounds Status Report ==="
    
    if {[catch {
        set all_bounds [get_bounds *]
        set num_bounds [sizeof_collection $all_bounds]
        
        bounds_log "Total bounds defined: $num_bounds"
        
        if {$num_bounds > 0} {
            foreach_in_collection bound $all_bounds {
                set bound_name [get_attribute $bound name]
                set bound_type [get_attribute $bound type]
                bounds_log "  - $bound_name (type: $bound_type)"
            }
        }
    } error]} {
        bounds_log "Could not generate bounds report: $error"
    }
    
    bounds_log "=== End Bounds Report ==="
}

# Initialize bounds system
bounds_log "Bounds script loaded successfully"
bounds_log "Use 'apply_placement_bounds' to apply bounds"
bounds_log "Use 'report_bounds_status' to check current bounds"