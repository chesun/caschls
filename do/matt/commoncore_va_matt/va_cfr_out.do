version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on May 29, 2018 *
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

log using log_files/sbac/va_cfr_out.smcl, replace

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
This do file estimates school value added on long-run outcomes using the 
Chetty, Friedman, and Rockoff methodology.
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

foreach outcome in enr enr_2year enr_4year {
	use `va_g11_dataset' if touse_g11_`outcome'==1, clear


	**************** Overall Value Added
	**** No Peer Controls
	** No TFX
	vam `outcome' ///
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
	rename tv va_cfr_g11_`outcome'
	rename score_r g11_`outcome'_r

	** TFX
	vam `outcome' ///
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
	rename tv va_tfx_g11_`outcome'
	drop score_r
	
	corr va_cfr_g11_`outcome' va_tfx_g11_`outcome'

	**** Peer Controls
	** No TFX
	vam `outcome' ///
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
	rename tv va_cfr_g11_`outcome'_peer
	rename score_r g11_`outcome'_r_peer

	** TFX
	vam `outcome' ///
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
	rename tv va_tfx_g11_`outcome'_peer
	drop score_r
	
	corr va_cfr_g11_`outcome'_peer va_tfx_g11_`outcome'_peer


	**************** Specification Test
	**** No Peer Controls
	reg g11_`outcome'_r va_cfr_g11_`outcome', cluster(school_id)
	estimates save estimates/sbac/spec_test_va_cfr_g11_`outcome'.ster, replace

	**** Peer Controls
	reg g11_`outcome'_r_peer va_cfr_g11_`outcome'_peer, cluster(school_id)
	estimates save estimates/sbac/spec_test_va_cfr_g11_`outcome'_peer.ster, replace




	**************** Deep Knowledge Value Added
	foreach subject in ela math {
		merge m:1 cdscode year using data/sbac/va_g11_`subject'.dta, nogen keep(1 3) keepusing(va_cfr_g11_`subject' va_cfr_g11_`subject'_peer)
		gen touse_g11_`outcome'_`subject' = touse_g11_`outcome'
		replace touse_g11_`outcome'_`subject' = 0 if mi(va_cfr_g11_`subject')
		
		/*sum va_cfr_g11_`subject'
		replace va_cfr_g11_`subject' = va_cfr_g11_`subject' / r(sd)*/
		
		**** No Peer Controls
		** No TFX
		vam `outcome' ///
			, teacher(school_id) year(year) class(school_id) ///
			controls( ///
				va_cfr_g11_`subject' ///
				i.year ///
				`school_controls' ///
				`demographic_controls' ///
				`ela_score_controls' ///
				`math_score_controls' ///
			) ///
			data(merge tv score_r) ///
			driftlimit(`drift_limit') ///
			estimates(estimates/sbac/vam_cfr_g11_`outcome'_`subject'.ster, replace)
		rename tv va_cfr_g11_`outcome'_`subject'
		rename score_r g11_`outcome'_`subject'_r

		** TFX
		vam `outcome' ///
			, teacher(school_id) year(year) class(school_id) ///
			controls( ///
				va_cfr_g11_`subject' ///
				i.year ///
				`school_controls' ///
				`demographic_controls' ///
				`ela_score_controls' ///
				`math_score_controls' ///
			) ///
			/*tfx_resid(school_id)*/ ///
			tfx_resid(school_id) ///
			data(merge tv score_r) ///
			driftlimit(`drift_limit') ///
			estimates(estimates/sbac/vam_tfx_g11_`outcome'_`subject'.ster, replace)
		rename tv va_tfx_g11_`outcome'_`subject'
		drop score_r
		
		corr va_cfr_g11_`outcome'_`subject' va_tfx_g11_`outcome'_`subject'

		**** Peer Controls
		** No TFX
		vam `outcome' ///
			, teacher(school_id) year(year) class(school_id) ///
			controls( ///
				va_cfr_g11_`subject'_peer ///
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
			driftlimit(`drift_limit') ///
			estimates(estimates/sbac/vam_cfr_g11_`outcome'_`subject'_peer.ster, replace)
		rename tv va_cfr_g11_`outcome'_`subject'_peer
		rename score_r g11_`outcome'_`subject'_r_peer

		** TFX
		vam `outcome' ///
			, teacher(school_id) year(year) class(school_id) ///
			controls( ///
				va_cfr_g11_`subject'_peer ///
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
			driftlimit(`drift_limit') ///
			estimates(estimates/sbac/vam_tfx_g11_`outcome'_`subject'_peer.ster, replace)
		rename tv va_tfx_g11_`outcome'_`subject'_peer
		drop score_r
		
		corr va_cfr_g11_`outcome'_`subject'_peer va_tfx_g11_`outcome'_`subject'_peer


		**************** Specification Test
		**** No Peer Controls
		reg g11_`outcome'_`subject'_r va_cfr_g11_`outcome'_`subject', cluster(school_id)
		estimates save estimates/sbac/spec_test_va_cfr_g11_`outcome'_`subject'.ster, replace

		**** Peer Controls
		reg g11_`outcome'_`subject'_r_peer va_cfr_g11_`outcome'_`subject'_peer, cluster(school_id)
		estimates save estimates/sbac/spec_test_va_cfr_g11_`outcome'_`subject'_peer.ster, replace
	}


	gen touse_g11_`outcome'_dk = touse_g11_`outcome'
	replace touse_g11_`outcome'_dk = 0 if mi(va_cfr_g11_ela)
	replace touse_g11_`outcome'_dk = 0 if mi(va_cfr_g11_math)
	
	**** No Peer Controls
	** No TFX
	vam `outcome' ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			va_cfr_g11_ela ///
			va_cfr_g11_math ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
		) ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit') ///
		estimates(estimates/sbac/vam_cfr_g11_`outcome'_dk.ster, replace)
	rename tv va_cfr_g11_`outcome'_dk
	rename score_r g11_`outcome'_dk_r

	** TFX
	vam `outcome' ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			va_cfr_g11_ela ///
			va_cfr_g11_math ///
			i.year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
		) ///
		tfx_resid(school_id) ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit') ///
		estimates(estimates/sbac/vam_tfx_g11_`outcome'_dk.ster, replace)
	rename tv va_tfx_g11_`outcome'_dk
	drop score_r
	
	corr va_cfr_g11_`outcome'_dk va_tfx_g11_`outcome'_dk
	
	drop va_cfr_g11_ela va_cfr_g11_math

	**** Peer Controls
	** No TFX
	vam `outcome' ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			va_cfr_g11_ela_peer ///
			va_cfr_g11_math_peer ///
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
		driftlimit(`drift_limit') ///
		estimates(estimates/sbac/vam_cfr_g11_`outcome'_dk_peer.ster, replace)
	rename tv va_cfr_g11_`outcome'_dk_peer
	rename score_r g11_`outcome'_dk_r_peer

	** TFX
	vam `outcome' ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			va_cfr_g11_ela_peer ///
			va_cfr_g11_math_peer ///
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
		driftlimit(`drift_limit') ///
		estimates(estimates/sbac/vam_tfx_g11_`outcome'_dk_peer.ster, replace)
	rename tv va_tfx_g11_`outcome'_dk_peer
	drop score_r
	
	corr va_cfr_g11_`outcome'_dk_peer va_tfx_g11_`outcome'_dk_peer
	
	drop va_cfr_g11_ela_peer va_cfr_g11_math_peer


	**************** Specification Test
	**** No Peer Controls
	reg g11_`outcome'_dk_r va_cfr_g11_`outcome'_dk, cluster(school_id)
	estimates save estimates/sbac/spec_test_va_cfr_g11_`outcome'_dk.ster, replace

	**** Peer Controls
	reg g11_`outcome'_dk_r_peer va_cfr_g11_`outcome'_dk_peer, cluster(school_id)
	estimates save estimates/sbac/spec_test_va_cfr_g11_`outcome'_dk_peer.ster, replace
	
	
	**************** Save Value Added Estimates
	collapse (firstnm) va_* ///
		(mean) g11_`outcome'* ///
		(sum) n_g11_`outcome' = touse_g11_`outcome' n_g11_`outcome'_ela = touse_g11_`outcome'_ela n_g11_`outcome'_math = touse_g11_`outcome'_math n_g11_`outcome'_dk = touse_g11_`outcome'_dk ///
		, by(school_id cdscode grade year)
	save data/sbac/va_g11_`outcome'.dta, replace
}


timer off 1
timer list
log close
translate log_files/sbac/va_cfr_out.smcl log_files/sbac/va_cfr_out.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
