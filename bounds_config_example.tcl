###########################################################################################
## Example Bounds Configuration File
## 
## This file demonstrates how to configure custom bounds for your design.
## Copy and modify this file to define your specific bounds requirements.
##
## Usage:
##   1. Copy this file and customize for your design
##   2. Set BOUNDS_CONFIG_FILE to point to your custom file
##   3. Call apply_placement_bounds
###########################################################################################

# Enable debug output for bounds operations
set BOUNDS_DEBUG 1

# Custom bounds configuration for your design
# Each bound should define: name, cell_pattern, boundary_coordinates, type

# Example 1: Hard bound for critical timing path
set critical_path_cells [get_flat_cells [all_registers] -filter "full_name =~ *critical_path*"]
if {[sizeof_collection $critical_path_cells] > 0} {
    create_placement_bound "critical_path_bound" $critical_path_cells {{100.0 100.0} {400.0 300.0}} "hard"
}

# Example 2: Soft bound for memory controllers
set memory_ctrl_cells [get_flat_cells * -filter "full_name =~ *mem_ctrl*"]
if {[sizeof_collection $memory_ctrl_cells] > 0} {
    create_placement_bound "memory_controller_bound" $memory_ctrl_cells {{50.0 400.0} {350.0 600.0}} "soft"
}

# Example 3: Guide bound for clock tree elements
set clock_cells [get_flat_cells * -filter "full_name =~ *clock*"]
if {[sizeof_collection $clock_cells] > 0} {
    create_placement_bound "clock_guide_bound" $clock_cells {{200.0 50.0} {600.0 150.0}} "guide"
}

# Example 4: Multiple bounds for different cache banks
for {set i 0} {$i < 4} {incr i} {
    set bank_cells [get_flat_cells [all_registers] -filter "full_name =~ *bank${i}*"]
    if {[sizeof_collection $bank_cells] > 0} {
        set x_start [expr {$i * 200 + 50}]
        set x_end [expr {$x_start + 180}]
        create_placement_bound "bank${i}_bound" $bank_cells [list [list $x_start 300.0] [list $x_end 500.0]] "hard"
    }
}

puts "BOUNDS_CONFIG: Custom bounds configuration loaded successfully"