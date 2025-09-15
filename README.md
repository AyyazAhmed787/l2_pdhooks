# L2_pdhooks
This Repository Contains the custom pd scripts used in the place &amp; route flow for fusion compiler.

## Bounds Script Integration

This repository now includes a comprehensive bounds management system for the fusion compiler:

### New Files Added:
- `apply_bounds.tcl` - Main bounds application script
- `bounds_config_example.tcl` - Example configuration file
- `test_bounds_config.tcl` - Test utility for validating bounds configurations  
- `BOUNDS_USAGE.md` - Detailed usage documentation

### Integration:
The bounds script is automatically integrated into both `octa/` and `tetra/` hook files:
- Runs during the `initial_place` stage in `pre_compile_hooks.tcl`
- Provides predefined bounds for L2 cache designs
- Supports custom bounds through configuration files
- Includes comprehensive error handling and logging

### Quick Start:
1. The bounds script runs automatically during place & route
2. For custom bounds, create a configuration file based on `bounds_config_example.tcl`
3. Set `BOUNDS_CONFIG_FILE` variable to your custom file path
4. Use `test_bounds_config.tcl` to validate your configuration

See `BOUNDS_USAGE.md` for detailed documentation.
