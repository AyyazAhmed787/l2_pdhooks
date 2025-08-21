# This file contains post-endpoint hooks
set_host_option -name pteco_host_option -submit_command [list /global/lsf/lsf_top/10.1.14/linux3.10-glibc2.17-x86_64/bin/bsub -app batch -n 8 ] -max_core 8
set_pt_options -host_option "pteco_host_option" -pt_exec /global/apps/pt_2022.12-SP5/bin/pt_shell -clib_flow
eco_opt -types leakage_power -pba_mode exhaustive -size_only -setup_margin 0.1	
eco_opt -types leakage_power -pba_mode exhaustive -setup_margin 0.1
eco_opt -types setup -pba_mode exhaustive -size_only -setup_margin 0.1
eco_opt -types setup -pba_mode exhaustive -setup_margin 0.1
route_detail -incremental true -max_number_iterations 100


rm_source -file ./frm_fc_scripts/custom_scripts/post_work.tcl