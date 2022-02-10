version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on June 2, 2020 *
*****************************************************

if inlist(c(hostname), "sapper", "scribe") {
	global S_ADO BASE;.;PERSONAL;PLUS;SITE;OLDPLACE
	local home "/home/research/ca_ed_lab/projects/common_core_va"
	local ca_ed_lab "/home/research/ca_ed_lab"
	local k12_test_scores "`home'/data/restricted_access/clean/k12_test_scores"
	local public_access "`home'/data/public_access"
	local k12_public_schools "`public_access'/clean/k12_public_schools"
	local k12_test_scores_public "`public_access'/clean/k12_test_scores"
	local acs "`public_access'/clean/acs"
}
else if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="naven" {
	local home "/Users/naven/Documents/research/ca_ed_lab/common_core_va"
}
else if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="navenm" {
	local home "/Users/navenm/Documents/research/ca_ed_lab/common_core_va"
}
else if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="Naven" {
	local home "/Users/Naven/Documents/research/ca_ed_lab/common_core_va"
}
cd `home'

log using log_files/sbac/va_cfr_forecast_bias.smcl, replace

clear all
graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
/* Color Order
color p       gs6
color p1      navy
color p2      maroon
color p3      forest_green
color p4      dkorange
color p5      teal
color p6      cranberry
color p7      lavender
color p8      khaki
color p9      sienna
color p10     emidblue
color p11     emerald
color p12     brown
color p13     erose
color p14     gold
color p15     bluishgray
*/
/* Marker Symbol Order
circle             O
diamond            D
triangle           T
square             S
plus               +
X                  X
arrowf             A
arrow              a
pipe               |
V                  V
*/
/* Line Pattern Order
solid
dash
dot
dash_dot
shortdash
shortdash_dot
longdash
longdash_dot
*/
set seed 1984


***************
* Description *
***************
/*
This file calculates value added forecast bias estimates for the SBAC using the CFR 
methodology.
*/


**********
* Macros *
**********
include do_files/sbac/macros_va.doh

#delimit ;
#delimit cr
macro list


timer on 1
*****************
* Begin Do File *
*****************
******************************** Value Added Sample
include do_files/sbac/create_va_sample.doh

* Save temporary dataset
compress
tempfile va_dataset
save `va_dataset'
































******************************** 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
include do_files/sbac/create_va_g11_sample.doh

foreach subject in ela math {
	**************** Four Grade Prior Test Score Forecast Bias Test
	use `va_g11_dataset' if touse_g11_`subject'==1, clear
	merge 1:1 merge_id_k12_test_scores using `k12_test_scores'/k12_lag_test_scores_clean.dta, nogen keep(1 3) ///
		keepusing( ///
			L4_cst_ela_z_score ///
		) ///
		update
	drop if mi(L4_cst_ela_z_score)


	**************** Value Added
	**** No Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_cfr_g11_`subject'
	rename score_r sbac_g11_`subject'_r

	**** Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			`peer_demographic_controls' ///
			`peer_ela_score_controls' ///
			`peer_math_score_controls' ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_cfr_g11_`subject'_peer
	rename score_r sbac_g11_`subject'_r_peer


	**************** Specification Test
	**** No Peer Controls
	reg sbac_g11_`subject'_r va_cfr_g11_`subject', cluster(school_id)
	estimates save estimates/sbac/bias_spec_test_va_cfr_g11_`subject'_L4ela.ster, replace

	**** Peer Controls
	reg sbac_g11_`subject'_r_peer va_cfr_g11_`subject'_peer, cluster(school_id)
	estimates save estimates/sbac/bias_spec_test_va_cfr_g11_`subject'_L4ela_peer.ster, replace


	**************** Chetty, Friedman, Rockoff Forecast Bias Test
	******** Add excluded observables as controls
	**** No Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			L4_cst_ela_z_score ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_fb_g11_`subject'
	rename score_r sbac_g11_`subject'_r_p

	**** Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			`peer_demographic_controls' ///
			`peer_ela_score_controls' ///
			`peer_math_score_controls' ///
			L4_cst_ela_z_score ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_fb_g11_`subject'_peer
	rename score_r sbac_g11_`subject'_r_p_peer


	******** Regress predicted scores on value added
	**** No Peer Controls
	gen sbac_g11_`subject'_r_d = sbac_g11_`subject'_r - sbac_g11_`subject'_r_p
	/*a*/reg sbac_g11_`subject'_r_d va_cfr_g11_`subject', /*absorb(school_id)*/	cluster(school_id)
	estimates save estimates/sbac/bias_test_va_cfr_g11_`subject'_L4ela.ster, replace

	**** Peer Controls
	gen sbac_g11_`subject'_r_d_peer = sbac_g11_`subject'_r_peer - sbac_g11_`subject'_r_p_peer
	/*a*/reg sbac_g11_`subject'_r_d_peer va_cfr_g11_`subject'_peer, /*absorb(school_id)*/	cluster(school_id)
	estimates save estimates/sbac/bias_test_va_cfr_g11_`subject'_L4ela_peer.ster, replace


	**************** Save Value Added Estimates
	collapse (firstnm) va_* ///
		(mean) sbac_*_r* ///
		(sum) n_g11_`subject' = touse_g11_`subject' ///
		, by(school_id cdscode grade year)
	save data/sbac/bias_va_g11_`subject'_L4ela.dta, replace
































	**************** Census Tract Forecast Bias Test
	import delimited data/restricted_access/clean/crosswalks/address_list_census_batch_geocoded.csv ///
		, delimiter(tab) varnames(1) case(lower) stringcols(_all) clear
	gen census_sct = statefp + countyfp + tract
	keep address_id census_sct
	compress
	tempfile census_geocode
	save `census_geocode'
	
	use merge_id_k12_test_scores state_student_id student_id cdscode year grade ///
		street_address_line_one street_address_line_two city state zip_code ///
		using `k12_test_scores'/k12_test_scores_clean.dta, clear
	keep if grade==`census_grade' & inrange(year, `test_score_min_year'-(11-`census_grade'), `test_score_max_year'-(11-`census_grade'))
	drop if mi(state_student_id)
	duplicates tag state_student_id, gen(dup_ssid)
	egen year_min = min(year) if dup_ssid!=0, by(state_student_id)
	drop if year!=year_min & dup_ssid!=0
	duplicates drop state_student_id, force
	keep state_student_id student_id street_address_line_one street_address_line_two city state zip_code
	compress
	tempfile lagged_address
	save `lagged_address'
	
	use data/restricted_access/clean/crosswalks/address_list.dta, clear
	keep address_id street_address_line_one city state zip_code
	duplicates drop
	compress
	tempfile address_id
	save `address_id'
	
	use `va_g11_dataset' if touse_g11_`subject'==1, clear
	merge m:1 state_student_id using `lagged_address' ///
		, keep(3) keepusing(street_address_line_one city state zip_code) gen(merge_lagged_address)
	merge m:1 street_address_line_one city state zip_code using `address_id' ///
		, keep(3) gen(merge_address_id)
	merge m:1 address_id using `census_geocode' ///
		, keep(3) gen(merge_census_geocode)
	rename census_sct geoid2
	merge m:1 geoid2 using `acs'/acs_ca_census_tract_clean.dta ///
		, keep(3) gen(merge_acs)
	rename geoid2 census_sct
	foreach v of varlist `census_controls' {
		drop if mi(`v')
	}


	**************** Value Added
	**** No Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_cfr_g11_`subject'
	rename score_r sbac_g11_`subject'_r

	**** Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			`peer_demographic_controls' ///
			`peer_ela_score_controls' ///
			`peer_math_score_controls' ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_cfr_g11_`subject'_peer
	rename score_r sbac_g11_`subject'_r_peer


	**************** Specification Test
	**** No Peer Controls
	reg sbac_g11_`subject'_r va_cfr_g11_`subject', cluster(school_id)
	estimates save estimates/sbac/bias_spec_test_va_cfr_g11_`subject'_census.ster, replace

	**** Peer Controls
	reg sbac_g11_`subject'_r_peer va_cfr_g11_`subject'_peer, cluster(school_id)
	estimates save estimates/sbac/bias_spec_test_va_cfr_g11_`subject'_census_peer.ster, replace


	**************** Chetty, Friedman, Rockoff Forecast Bias Test
	******** Add excluded observables as controls
	**** No Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			`census_controls' ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_fb_g11_`subject'
	rename score_r sbac_g11_`subject'_r_p

	**** Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			`peer_demographic_controls' ///
			`peer_ela_score_controls' ///
			`peer_math_score_controls' ///
			`census_controls' ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_fb_g11_`subject'_peer
	rename score_r sbac_g11_`subject'_r_p_peer


	******** Regress predicted scores on value added
	**** No Peer Controls
	gen sbac_g11_`subject'_r_d = sbac_g11_`subject'_r - sbac_g11_`subject'_r_p
	/*a*/reg sbac_g11_`subject'_r_d va_cfr_g11_`subject', /*absorb(school_id)*/	cluster(school_id)
	estimates save estimates/sbac/bias_test_va_cfr_g11_`subject'_census.ster, replace

	**** Peer Controls
	gen sbac_g11_`subject'_r_d_peer = sbac_g11_`subject'_r_peer - sbac_g11_`subject'_r_p_peer
	/*a*/reg sbac_g11_`subject'_r_d_peer va_cfr_g11_`subject'_peer, /*absorb(school_id)*/	cluster(school_id)
	estimates save estimates/sbac/bias_test_va_cfr_g11_`subject'_census_peer.ster, replace


	**************** Save Value Added Estimates
	collapse (firstnm) va_* ///
		(mean) sbac_*_r* ///
		(sum) n_g11_`subject' = touse_g11_`subject' ///
		, by(school_id cdscode grade year)
	save data/sbac/bias_va_g11_`subject'_census.dta, replace
































	**************** Four Grade Prior Test Score + Six Grade Prior Test Score Forecast Bias Test
	use `va_g11_dataset' if touse_g11_`subject'==1, clear
	merge 1:1 merge_id_k12_test_scores using `k12_test_scores'/k12_lag_test_scores_clean.dta, nogen keep(1 3) ///
		keepusing( ///
			L4_cst_ela_z_score ///
			L6_cst_ela_z_score ///
			L6_cst_math_z_score ///
		) ///
		update
	drop if mi(L4_cst_ela_z_score, L6_cst_ela_z_score, L6_cst_math_z_score)


	**************** Value Added
	**** No Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_cfr_g11_`subject'
	rename score_r sbac_g11_`subject'_r

	**** Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			`peer_demographic_controls' ///
			`peer_ela_score_controls' ///
			`peer_math_score_controls' ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_cfr_g11_`subject'_peer
	rename score_r sbac_g11_`subject'_r_peer


	**************** Specification Test
	**** No Peer Controls
	reg sbac_g11_`subject'_r va_cfr_g11_`subject', cluster(school_id)
	estimates save estimates/sbac/bias_spec_test_va_cfr_g11_`subject'_L4ela_L6ela_L6math.ster, replace

	**** Peer Controls
	reg sbac_g11_`subject'_r_peer va_cfr_g11_`subject'_peer, cluster(school_id)
	estimates save estimates/sbac/bias_spec_test_va_cfr_g11_`subject'_L4ela_L6ela_L6math_peer.ster, replace


	**************** Chetty, Friedman, Rockoff Forecast Bias Test
	******** Add excluded observables as controls
	**** No Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			L4_cst_ela_z_score ///
			L6_cst_ela_z_score ///
			L6_cst_math_z_score ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_fb_g11_`subject'
	rename score_r sbac_g11_`subject'_r_p

	**** Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			`peer_demographic_controls' ///
			`peer_ela_score_controls' ///
			`peer_math_score_controls' ///
			L4_cst_ela_z_score ///
			L6_cst_ela_z_score ///
			L6_cst_math_z_score ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_fb_g11_`subject'_peer
	rename score_r sbac_g11_`subject'_r_p_peer


	******** Regress predicted scores on value added
	**** No Peer Controls
	gen sbac_g11_`subject'_r_d = sbac_g11_`subject'_r - sbac_g11_`subject'_r_p
	/*a*/reg sbac_g11_`subject'_r_d va_cfr_g11_`subject', /*absorb(school_id)*/	cluster(school_id)
	estimates save estimates/sbac/bias_test_va_cfr_g11_`subject'_L4ela_L6ela_L6math.ster, replace

	**** Peer Controls
	gen sbac_g11_`subject'_r_d_peer = sbac_g11_`subject'_r_peer - sbac_g11_`subject'_r_p_peer
	/*a*/reg sbac_g11_`subject'_r_d_peer va_cfr_g11_`subject'_peer, /*absorb(school_id)*/	cluster(school_id)
	estimates save estimates/sbac/bias_test_va_cfr_g11_`subject'_L4ela_L6ela_L6math_peer.ster, replace


	**************** Save Value Added Estimates
	collapse (firstnm) va_* ///
		(mean) sbac_*_r* ///
		(sum) n_g11_`subject' = touse_g11_`subject' ///
		, by(school_id cdscode grade year)
	save data/sbac/bias_va_g11_`subject'_L4ela_L6ela_L6math.dta, replace
































	**************** Four Grade Prior Test Score + Six Grade Prior Test Score + Census Tract Forecast Bias Test
	import delimited data/restricted_access/clean/crosswalks/address_list_census_batch_geocoded.csv ///
		, delimiter(tab) varnames(1) case(lower) stringcols(_all) clear
	gen census_sct = statefp + countyfp + tract
	keep address_id census_sct
	compress
	tempfile census_geocode
	save `census_geocode'
	
	use merge_id_k12_test_scores state_student_id student_id cdscode year grade ///
		street_address_line_one street_address_line_two city state zip_code ///
		using `k12_test_scores'/k12_test_scores_clean.dta, clear
	keep if grade==`census_grade' & inrange(year, `test_score_min_year'-(11-`census_grade'), `test_score_max_year'-(11-`census_grade'))
	drop if mi(state_student_id)
	duplicates tag state_student_id, gen(dup_ssid)
	egen year_min = min(year) if dup_ssid!=0, by(state_student_id)
	drop if year!=year_min & dup_ssid!=0
	duplicates drop state_student_id, force
	keep state_student_id student_id street_address_line_one street_address_line_two city state zip_code
	compress
	tempfile lagged_address
	save `lagged_address'
	
	use data/restricted_access/clean/crosswalks/address_list.dta, clear
	keep address_id street_address_line_one city state zip_code
	duplicates drop
	compress
	tempfile address_id
	save `address_id'
	
	use `va_g11_dataset' if touse_g11_`subject'==1, clear
	merge 1:1 merge_id_k12_test_scores using `k12_test_scores'/k12_lag_test_scores_clean.dta, nogen keep(1 3) ///
		keepusing( ///
			L4_cst_ela_z_score ///
			L6_cst_ela_z_score ///
			L6_cst_math_z_score ///
		) ///
		update
	drop if mi(L4_cst_ela_z_score, L6_cst_ela_z_score, L6_cst_math_z_score)
	merge m:1 state_student_id using `lagged_address' ///
		, keep(3) keepusing(street_address_line_one city state zip_code) gen(merge_lagged_address)
	merge m:1 street_address_line_one city state zip_code using `address_id' ///
		, keep(3) gen(merge_address_id)
	merge m:1 address_id using `census_geocode' ///
		, keep(3) gen(merge_census_geocode)
	rename census_sct geoid2
	merge m:1 geoid2 using `acs'/acs_ca_census_tract_clean.dta ///
		, keep(3) gen(merge_acs)
	rename geoid2 census_sct
	foreach v of varlist `census_controls' {
		drop if mi(`v')
	}


	**************** Value Added
	**** No Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_cfr_g11_`subject'
	rename score_r sbac_g11_`subject'_r

	**** Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			`peer_demographic_controls' ///
			`peer_ela_score_controls' ///
			`peer_math_score_controls' ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_cfr_g11_`subject'_peer
	rename score_r sbac_g11_`subject'_r_peer


	**************** Specification Test
	**** No Peer Controls
	reg sbac_g11_`subject'_r va_cfr_g11_`subject', cluster(school_id)
	estimates save estimates/sbac/bias_spec_test_va_cfr_g11_`subject'_L4ela_L6ela_L6math_census.ster, replace

	**** Peer Controls
	reg sbac_g11_`subject'_r_peer va_cfr_g11_`subject'_peer, cluster(school_id)
	estimates save estimates/sbac/bias_spec_test_va_cfr_g11_`subject'_L4ela_L6ela_L6math_census_peer.ster, replace


	**************** Chetty, Friedman, Rockoff Forecast Bias Test
	******** Add excluded observables as controls
	**** No Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			L4_cst_ela_z_score ///
			L6_cst_ela_z_score ///
			L6_cst_math_z_score ///
			`census_controls' ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_fb_g11_`subject'
	rename score_r sbac_g11_`subject'_r_p

	**** Peer Controls
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			`peer_demographic_controls' ///
			`peer_ela_score_controls' ///
			`peer_math_score_controls' ///
			L4_cst_ela_z_score ///
			L6_cst_ela_z_score ///
			L6_cst_math_z_score ///
			`census_controls' ///
		) ///
		/*tfx_resid(school_id)*/ ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_fb_g11_`subject'_peer
	rename score_r sbac_g11_`subject'_r_p_peer


	******** Regress predicted scores on value added
	**** No Peer Controls
	gen sbac_g11_`subject'_r_d = sbac_g11_`subject'_r - sbac_g11_`subject'_r_p
	/*a*/reg sbac_g11_`subject'_r_d va_cfr_g11_`subject', /*absorb(school_id)*/	cluster(school_id)
	estimates save estimates/sbac/bias_test_va_cfr_g11_`subject'_L4ela_L6ela_L6math_census.ster, replace

	**** Peer Controls
	gen sbac_g11_`subject'_r_d_peer = sbac_g11_`subject'_r_peer - sbac_g11_`subject'_r_p_peer
	/*a*/reg sbac_g11_`subject'_r_d_peer va_cfr_g11_`subject'_peer, /*absorb(school_id)*/	cluster(school_id)
	estimates save estimates/sbac/bias_test_va_cfr_g11_`subject'_L4ela_L6ela_L6math_census_peer.ster, replace


	**************** Save Value Added Estimates
	collapse (firstnm) va_* ///
		(mean) sbac_*_r* ///
		(sum) n_g11_`subject' = touse_g11_`subject' ///
		, by(school_id cdscode grade year)
	save data/sbac/bias_va_g11_`subject'_L4ela_L6ela_L6math_census.dta, replace
}


timer off 1
timer list
log close
translate log_files/sbac/va_cfr_forecast_bias.smcl log_files/sbac/va_cfr_forecast_bias.log, replace

if inlist(c(hostname), "sapper", "scribe") {
	/*exit, STATA*/ clear
}
