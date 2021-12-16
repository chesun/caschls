version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on May 8, 2018 *
*****************************************************

if inlist(c(hostname), "sapper", "scribe") {
	global S_ADO BASE;.;PERSONAL;PLUS;SITE;OLDPLACE
	local home "/home/research/ca_ed_lab/msnaven/common_core_va"
	local ca_ed_lab "/home/research/ca_ed_lab"
	local k12_test_scores "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores"
	local public_access "/home/research/ca_ed_lab/data/public_access"
	local k12_public_schools "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools"
	local k12_test_scores_public "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_test_scores"
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

log using log_files/sbac/va_cfr.smcl, replace

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
This file calculates value added estimates for the SBAC using the CFR 
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
	use `va_g11_dataset' if touse_g11_`subject'==1, clear
	
	
	**************** Value Added
	**** No Peer Controls
	** No TFX
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
		) ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_cfr_g11_`subject'
	rename score_r sbac_g11_`subject'_r

	** TFX
	vam sbac_`subject'_z_score ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
		) ///
		tfx_resid(school_id) ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_tfx_g11_`subject'
	drop score_r

	**** Peer Controls
	** No TFX
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
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_cfr_g11_`subject'_peer
	rename score_r sbac_g11_`subject'_r_peer

	** TFX
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
		tfx_resid(school_id) ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_tfx_g11_`subject'_peer
	drop score_r


	**************** Specification Test
	**** No Peer Controls
	reg sbac_g11_`subject'_r va_cfr_g11_`subject', cluster(school_id)
	estimates save estimates/sbac/spec_test_va_cfr_g11_`subject'.ster, replace

	**** Peer Controls
	reg sbac_g11_`subject'_r_peer va_cfr_g11_`subject'_peer, cluster(school_id)
	estimates save estimates/sbac/spec_test_va_cfr_g11_`subject'_peer.ster, replace


	**************** Save Value Added Estimates
	collapse (firstnm) va_* ///
		(mean) sbac_*_r* ///
		(sum) n_g11_`subject' = touse_g11_`subject' ///
		, by(school_id cdscode grade year)
	save data/sbac/va_g11_`subject'.dta, replace
}


timer off 1
timer list
log close
translate log_files/sbac/va_cfr.smcl log_files/sbac/va_cfr.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
