/* this file uses the va_dataset temp file, and produces the va_g11_dataset temp file  */

local drift_limit = max(`test_score_max_year' - `test_score_min_year' - 1, 1)
use if grade==11 & dataset=="CAASPP" & inrange(year, `test_score_min_year', `test_score_max_year') using `va_dataset', clear

gen diff_school_prop = gr11_L3_diff_school_prop if year!=2017
replace diff_school_prop = gr11_L4_diff_school_prop if year==2017
keep if diff_school_prop>=0.95

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


* Save temporary dataset
compress
tempfile va_g11_dataset
save `va_g11_dataset'
