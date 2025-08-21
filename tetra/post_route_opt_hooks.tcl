# This file contains post_route_opt stage hooks
if [string match "IsoPerf*" ${FMODE}] {
            puts "FRM_INFO: Running 'optimize_route' "
            optimize_routes
            puts "FRM_INFO: Running additional detail route"
            route_detail -incr true -initial_drc_from_input true -max_number_iterations $ROUTE_OPT_ROUTE_DETAIL_MAX_ITER
            check_routes
            route_detail -incr true -initial_drc_from_input true -max_number_iterations $ROUTE_OPT_ROUTE_DETAIL_MAX_ITER

        } elseif [string match "Fmax" ${FMODE}] {
            puts "FRM_INFO: Running 'optimize_route' "
            optimize_routes

            }


rm_source -file ./frm_fc_scripts/custom_scripts/post_work.tcl