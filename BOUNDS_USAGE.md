# Bounds Script Usage Guide

## Overview

The `apply_bounds.tcl` script provides a comprehensive solution for applying placement bounds in the fusion compiler place & route flow. It integrates seamlessly with the existing hook system and supports both predefined and custom bounds configurations.

## Quick Start

The bounds script is automatically integrated into the `pre_compile_hooks.tcl` files and will run during the `initial_place` stage. No additional configuration is required for basic usage.

## Features

- **Automatic Integration**: Seamlessly integrates with existing hook files
- **Flexible Configuration**: Support for custom bounds via configuration files
- **Multiple Bound Types**: Support for hard, soft, and guide bounds
- **Error Handling**: Robust error checking and validation
- **Debug Support**: Detailed logging for troubleshooting
- **Predefined Patterns**: Built-in bounds for common L2 cache designs

## Configuration Options

### Global Variables

- `BOUNDS_ENABLED`: Enable/disable bounds application (default: 1)
- `BOUNDS_CONFIG_FILE`: Path to custom bounds configuration file
- `BOUNDS_DEBUG`: Enable debug output (default: 0)
- `BOUNDS_DEFAULT_TYPE`: Default bound type when not specified (default: "hard")

### Setting Configuration in Hook Files

```tcl
# Enable debug output
set BOUNDS_DEBUG 1

# Use custom configuration file
set BOUNDS_CONFIG_FILE "/path/to/your/custom_bounds.tcl"

# Apply bounds
apply_placement_bounds
```

## Custom Bounds Configuration

### Creating a Custom Configuration File

1. Copy `bounds_config_example.tcl` as a starting point
2. Modify the bounds definitions for your design
3. Set `BOUNDS_CONFIG_FILE` to point to your custom file

### Example Custom Bounds

```tcl
# Hard bound for critical timing path
set critical_cells [get_flat_cells [all_registers] -filter "full_name =~ *critical*"]
create_placement_bound "critical_bound" $critical_cells {{100.0 100.0} {400.0 300.0}} "hard"

# Soft bound for memory interface
set mem_cells [get_flat_cells * -filter "full_name =~ *memory*"]  
create_placement_bound "memory_bound" $mem_cells {{50.0 400.0} {350.0 600.0}} "soft"
```

## Bound Types

- **hard**: Strict placement constraints - cells must be placed within the boundary
- **soft**: Preferred placement - tools will try to place cells within boundary but may violate if necessary
- **guide**: Guidance only - provides hint to placer but no enforcement

## API Reference

### Core Functions

#### `apply_placement_bounds [force_refresh]`
Main function to apply bounds. Optional `force_refresh` parameter removes existing bounds first.

#### `create_placement_bound bound_name cell_collection boundary_coords bound_type`
Creates a single placement bound with validation.

#### `report_bounds_status`
Displays current bounds information for debugging.

#### `remove_all_bounds`
Removes all existing bounds from the design.

#### `apply_l2_cache_bounds`
Applies predefined bounds for L2 cache designs.

### Utility Functions

#### `validate_bound_coordinates coordinates`
Validates that boundary coordinates are properly formatted.

#### `bounds_log message`
Logs bounds-related messages (controlled by `BOUNDS_DEBUG`).

## Coordinate Format

Bounds coordinates are specified as a list of two points representing opposite corners of a rectangle:

```tcl
{{x1 y1} {x2 y2}}
```

Example:
```tcl
{{100.0 200.0} {500.0 600.0}}  # Rectangle from (100,200) to (500,600)
```

## Troubleshooting

### Enable Debug Output

```tcl
set BOUNDS_DEBUG 1
apply_placement_bounds
```

### Check Bounds Status

```tcl
report_bounds_status
```

### Common Issues

1. **No cells found**: Check your cell selection patterns
2. **Invalid coordinates**: Ensure coordinates are numeric and properly formatted
3. **Bounds conflicts**: Use `remove_all_bounds` before applying new bounds

### Error Messages

- `BOUNDS_ERROR`: Critical errors that prevent bounds creation
- `BOUNDS_WARNING`: Non-critical issues that don't stop execution
- `BOUNDS_INFO`: General information about bounds operations

## Integration Points

The bounds script integrates at the following points in the flow:

- **pre_compile_hooks.tcl**: `initial_place` stage
- Custom configuration files can be sourced at any appropriate stage

## Best Practices

1. **Test incrementally**: Start with a few bounds and verify results
2. **Use appropriate types**: Hard bounds for critical constraints, soft for preferences
3. **Validate coordinates**: Ensure bounds don't conflict with floorplan
4. **Monitor timing**: Check that bounds don't negatively impact timing
5. **Document custom bounds**: Keep configuration files well-documented

## Examples

### Basic Usage (Automatic)
The script runs automatically during initial_place with predefined L2 cache bounds.

### Custom Configuration
```tcl
# In your hook file
set BOUNDS_CONFIG_FILE "${INPUT_COLLATERAL}/bounds/my_design_bounds.tcl"
apply_placement_bounds
```

### Conditional Bounds
```tcl
# Apply different bounds based on design configuration
if {$CONFIG == "high_performance"} {
    set BOUNDS_CONFIG_FILE "hp_bounds.tcl"
} else {
    set BOUNDS_CONFIG_FILE "area_bounds.tcl"  
}
apply_placement_bounds
```

### Force Refresh
```tcl
# Remove existing bounds and apply new ones
apply_placement_bounds 1
```