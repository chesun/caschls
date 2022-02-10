version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on May 23, 2018 *
*****************************************************

if inlist(c(hostname), "sapper", "scribe") {
	global S_ADO BASE;.;PERSONAL;PLUS;SITE;OLDPLACE
	local home "/home/research/ca_ed_lab/projects/common_core_va"
	local ca_ed_lab "/home/research/ca_ed_lab"
	local k12_test_scores "`home'/data/restricted_access/clean/k12_test_scores"
	local public_access "`home'/data/public_access"
	local k12_public_schools "`public_access'/clean/k12_public_schools"
	local k12_test_scores_public "`public_access'/clean/k12_test_scores"
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

log using log_files/sbac/reg_out_va_cfr.smcl, replace

clear all
graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984


***************
* Description *
***************
/*
This do file runs regressions of outcomes on school value added.
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

******** Postsecondary Outcomes
do do_files/merge_k12_postsecondary.doh enr_only
drop enr enr_2year enr_4year
rename enr_ontime enr
rename enr_ontime_2year enr_2year
rename enr_ontime_4year enr_4year

* Save temporary dataset
compress
tempfile va_dataset
save `va_dataset'
































******************************** 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
include do_files/sbac/create_va_g11_out_sample.doh

foreach subject in ela math {
	di "Subject = `subject'"
	
	* Standardize value added estimates
	use data/sbac/va_g11_`subject'.dta, clear
	
	foreach v of varlist va_cfr_* {
		sum `v'
		replace `v' = `v' - r(mean)
		replace `v' = `v' / r(sd)
	}
	
	compress
	tempfile va_cfr_g11_`subject'
	save `va_cfr_g11_`subject''
}

**************** Sample
use `va_g11_dataset', clear

foreach subject in ela math {
	di "Subject = `subject'"
	
	merge m:1 cdscode year using `va_cfr_g11_`subject'' ///
		, nogen keep(1 3) keepusing(va_cfr_* va_tfx_*)
}


**************** Regress Outcomes on Value Added
foreach yvar of varlist enr enr_2year enr_4year {
	di "Y Variable = `yvar'"
	
	foreach subject in ela math {
		di "Subject = `subject'"
		
		**** No Peer Controls
		** No TFX
		reg `yvar' va_cfr_g11_`subject' ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			if touse_g11_`subject'==1 ///
			, cluster(cdscode)
		estadd ysumm, mean
		estimates save estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'.ster, replace

		**** Peer Controls
		** No TFX
		reg `yvar' va_cfr_g11_`subject' ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			`peer_demographic_controls' ///
			`peer_ela_score_controls' ///
			`peer_math_score_controls' ///
			if touse_g11_`subject'==1 ///
			, cluster(cdscode)
		estadd ysumm, mean
		estimates save estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'_peer.ster, replace
	}
	
	**** No Peer Controls
	** No TFX
	reg `yvar' va_cfr_g11_ela va_cfr_g11_math ///
		i.year ///
		`school_controls' ///
		`demographic_controls' ///
		`ela_score_controls' ///
		`math_score_controls' ///
		if touse_g11_ela==1 & touse_g11_math==1 ///
		, cluster(cdscode)
	estadd ysumm, mean
	estimates save estimates/sbac/reg_`yvar'_va_cfr_g11_ela_math.ster, replace

	**** Peer Controls
	** No TFX
	reg `yvar' va_cfr_g11_ela va_cfr_g11_math ///
		i.year ///
		`school_controls' ///
		`demographic_controls' ///
		`ela_score_controls' ///
		`math_score_controls' ///
		`peer_demographic_controls' ///
		`peer_ela_score_controls' ///
		`peer_math_score_controls' ///
		if touse_g11_ela==1 & touse_g11_math==1 ///
		, cluster(cdscode)
	estadd ysumm, mean
	estimates save estimates/sbac/reg_`yvar'_va_cfr_g11_ela_math_peer.ster, replace
}








**************** Regress Outcomes on Value Added: Heterogeneity by Predicted College
* Predicted College Enrollment Quantiles
merge 1:1 merge_id_k12_test_scores using data/sbac/enr_prob.dta ///
	, nogen keep(1 3)
gen enr_2year_prob_diff = abs(enr_2year_prob - enr_0year_prob)
xtile enr_2year_prob_diff_xtile = enr_2year_prob_diff, n(10)
gen enr_4year_prob_diff = abs(enr_4year_prob - enr_2year_prob)
xtile enr_4year_prob_diff_xtile = enr_4year_prob_diff, n(10)

foreach subject in ela math {
	di "Subject = `subject'"
	
	**** No Peer Controls
	** No TFX
	* 2 Year
	reg enr_2year c.va_cfr_g11_`subject'#i.enr_2year_prob_diff_xtile ///
		i.year ///
		`school_controls' ///
		`demographic_controls' ///
		`ela_score_controls' ///
		`math_score_controls' ///
		if touse_g11_`subject'==1 ///
		, cluster(cdscode)
	estadd ysumm, mean
	estimates save estimates/sbac/reg_enr_2year_va_cfr_g11_`subject'_hetero_enr_prob.ster, replace
	
	* 4 Year
	reg enr_4year c.va_cfr_g11_`subject'#i.enr_4year_prob_diff_xtile ///
		i.year ///
		`school_controls' ///
		`demographic_controls' ///
		`ela_score_controls' ///
		`math_score_controls' ///
		if touse_g11_`subject'==1 ///
		, cluster(cdscode)
	estadd ysumm, mean
	estimates save estimates/sbac/reg_enr_4year_va_cfr_g11_`subject'_hetero_enr_prob.ster, replace
}

**** No Peer Controls
** No TFX
* 2 Year
reg enr_2year c.va_cfr_g11_ela#i.enr_2year_prob_diff_xtile c.va_cfr_g11_math#i.enr_2year_prob_diff_xtile ///
	i.year ///
	`school_controls' ///
	`demographic_controls' ///
	`ela_score_controls' ///
	`math_score_controls' ///
	if touse_g11_ela==1 & touse_g11_math==1 ///
	, cluster(cdscode)
estadd ysumm, mean
estimates save estimates/sbac/reg_enr_2year_va_cfr_g11_ela_math_hetero_enr_prob.ster, replace

* 4 Year
reg enr_4year c.va_cfr_g11_ela#i.enr_4year_prob_diff_xtile c.va_cfr_g11_math#i.enr_4year_prob_diff_xtile ///
	i.year ///
	`school_controls' ///
	`demographic_controls' ///
	`ela_score_controls' ///
	`math_score_controls' ///
	if touse_g11_ela==1 & touse_g11_math==1 ///
	, cluster(cdscode)
estadd ysumm, mean
estimates save estimates/sbac/reg_enr_4year_va_cfr_g11_ela_math_hetero_enr_prob.ster, replace








**************** Regress Outcomes on Value Added: Heterogeneity by Prior Score
* Prior Scores Quantiles
xtile prior_ela_z_score_xtile = prior_ela_z_score, n(10)
xtile prior_math_z_score_xtile = prior_math_z_score, n(10)

foreach yvar of varlist enr enr_2year enr_4year {
	di "Y Variable = `yvar'"
	
	foreach subject in ela math {
		di "Subject = `subject'"
		
		**** No Peer Controls
		** No TFX
		* Prior ELA Score
		reg `yvar' c.va_cfr_g11_`subject'#i.prior_ela_z_score_xtile ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			if touse_g11_`subject'==1 ///
			, cluster(cdscode)
		estadd ysumm, mean
		estimates save estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'_hetero_prior_ela.ster, replace
		
		* Prior Math Score
		reg `yvar' c.va_cfr_g11_`subject'#i.prior_math_z_score_xtile ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			if touse_g11_`subject'==1 ///
			, cluster(cdscode)
		estadd ysumm, mean
		estimates save estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'_hetero_prior_math.ster, replace
	}
	
	**** No Peer Controls
	** No TFX
	* Prior ELA Score
	reg `yvar' c.va_cfr_g11_ela#i.prior_ela_z_score_xtile c.va_cfr_g11_math#i.prior_ela_z_score_xtile ///
		i.year ///
		`school_controls' ///
		`demographic_controls' ///
		`ela_score_controls' ///
		`math_score_controls' ///
		if touse_g11_ela==1 & touse_g11_math==1 ///
		, cluster(cdscode)
	estadd ysumm, mean
	estimates save estimates/sbac/reg_`yvar'_va_cfr_g11_ela_math_hetero_prior_ela.ster, replace
	
	* Prior Math Score
	reg `yvar' c.va_cfr_g11_ela#i.prior_math_z_score_xtile c.va_cfr_g11_math#i.prior_math_z_score_xtile ///
		i.year ///
		`school_controls' ///
		`demographic_controls' ///
		`ela_score_controls' ///
		`math_score_controls' ///
		if touse_g11_ela==1 & touse_g11_math==1 ///
		, cluster(cdscode)
	estadd ysumm, mean
	estimates save estimates/sbac/reg_`yvar'_va_cfr_g11_ela_math_hetero_prior_math.ster, replace
}



timer off 1
timer list
log close
translate log_files/sbac/reg_out_va_cfr.smcl log_files/sbac/reg_out_va_cfr.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
