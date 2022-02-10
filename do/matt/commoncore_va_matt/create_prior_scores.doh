**************** Prior Scores
******** ELA
gen prior_ela_z_score = L3_cst_ela_z_score if inrange(year, `star_min_year' + 3, `star_max_year' + 3) & year!=2017
replace prior_ela_z_score = L3_sbac_ela_z_score if inrange(year, `caaspp_min_year' + 3, `caaspp_max_year' + 3) & year!=2017
replace prior_ela_z_score = L4_cst_ela_z_score if year==2017
label var prior_ela_z_score "Prior ELA Z-Score"
gen peer_prior_ela_z_score = peer_L3_cst_ela_z_score if inrange(year, `star_min_year' + 3, `star_max_year' + 3) & year!=2017
replace peer_prior_ela_z_score = peer_L3_sbac_ela_z_score if inrange(year, `caaspp_min_year' + 3, `caaspp_max_year' + 3) & year!=2017
replace peer_prior_ela_z_score = peer_L4_cst_ela_z_score if year==2017
label var peer_prior_ela_z_score "Peer Avg. Prior ELA Z-Score"

******** Math
gen prior_math_z_score = L5_cst_math_z_score if inrange(year, `star_min_year' + 5, `star_max_year' + 5) & !inrange(year, `caaspp_min_year' + 3, `caaspp_max_year' + 3)
replace prior_math_z_score = L3_sbac_math_z_score if inrange(year, `caaspp_min_year' + 3, `caaspp_max_year' + 3)
label var prior_math_z_score "Prior Math Z-Score"
gen peer_prior_math_z_score = peer_L5_cst_math_z_score if inrange(year, `star_min_year' + 5, `star_max_year' + 5) & !inrange(year, `caaspp_min_year' + 3, `caaspp_max_year' + 3)
replace peer_prior_math_z_score = peer_L3_sbac_math_z_score if inrange(year, `caaspp_min_year' + 3, `caaspp_max_year' + 3)
label var peer_prior_math_z_score "Peer Avg. Prior Math Z-Score"
