version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on August 30, 2018 *
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

log using log_files/sbac/touse_va.smcl, replace

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
**************** Create VA Dataset
use merge_id_k12_test_scores all_students_sample first_scores_sample ///
	dataset test cdscode school_id state_student_id year grade ///
	cohort_size ///
	sbac_ela_z_score sbac_math_z_score ///
	`va_control_vars' ///
	using `k12_test_scores'/k12_test_scores_clean.dta, clear
mark touse

* Merge to lagged scores
merge 1:1 merge_id_k12_test_scores using `k12_test_scores'/k12_lag_test_scores_clean.dta, nogen keep(1 3) ///
	keepusing( ///
		L3_cst_ela_z_score ///
		L3_sbac_ela_z_score ///
		L4_cst_ela_z_score ///
		L3_sbac_math_z_score ///
		L4_sbac_math_z_score ///
		L5_cst_math_z_score ///
		L6_cst_math_z_score ///
	)

* Merge to peer scores
merge 1:1 merge_id_k12_test_scores using `k12_test_scores'/k12_peer_test_scores_clean.dta, nogen keep(1 3) ///
	keepusing( ///
		`peer_demographic_controls' ///
		peer_L3_cst_ela_z_score ///
		peer_L3_sbac_ela_z_score ///
		peer_L4_cst_ela_z_score ///
		peer_L3_sbac_math_z_score ///
		peer_L4_sbac_math_z_score ///
		peer_L5_cst_math_z_score ///
		peer_L6_cst_math_z_score ///
	)

* Merge to school grade spans
merge m:1 cdscode year using `k12_test_scores_public'/k12_diff_school_prop_schyr.dta ///
	, gen(merge_grade_span) keepusing(gr11_*_diff_school_prop) keep(1 3)

* Merge to median cohort sizes
merge m:1 cdscode using `k12_test_scores_public'/k12_cohort_size_sch.dta ///
	, gen(merge_cohort_size) keepusing(med_cohort_size_first_scores) keep(1 3)

* Keep conventional schools
merge m:1 cdscode using `k12_public_schools'/k12_public_schools_clean.dta ///
	, gen(merge_public_schools) keepusing(conventional_school) keep(1 3)
replace touse = 0 if conventional_school!=1

* Exclude schools where more than 25 percent of students are receiving special education services

* Drop if a student is receiving instruction at home, in a hospital, or in a school serving disabled students solely

* Drop if 10 or fewer students per school
replace touse = 0 if cohort_size<=10




******** Postsecondary Outcomes
do do_files/merge_k12_postsecondary.doh enr_only
drop enr enr_2year enr_4year
rename enr_ontime enr
rename enr_ontime_2year enr_2year
rename enr_ontime_4year enr_4year
































******************************** 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
include do_files/sbac/create_diff_school_prop.doh

include do_files/sbac/create_prior_scores.doh

**** Test Score Sample
foreach subject in ela math {
	mark touse_g11_`subject' ///
		if grade==11 & dataset=="CAASPP" & inrange(year, `test_score_min_year', `test_score_max_year') ///
		& diff_school_prop>=0.95
	markout touse_g11_`subject' ///
		sbac_`subject'_z_score ///
		school_id i.year ///
		`school_controls' ///
		`demographic_controls' ///
		`ela_score_controls' ///
		`math_score_controls' ///
		`peer_demographic_controls' ///
		`peer_ela_score_controls' ///
		`peer_math_score_controls'
	
	replace touse_g11_`subject' = 0 if touse==0
	
	egen n_g11_`subject' = count(state_student_id) ///
		if touse_g11_`subject'==1 ///
		, by(cdscode year)
	replace touse_g11_`subject' = 0 if n_g11_`subject'<7
}

**** Postsecondary Outcomes Sample
foreach outcome in enr enr_2year enr_4year {
	mark touse_g11_`outcome' ///
		if grade==11 & dataset=="CAASPP" & inrange(year, `outcome_min_year', `outcome_max_year') ///
		& diff_school_prop>=0.95
	markout touse_g11_`outcome' ///
		`outcome' ///
		school_id i.year ///
		`school_controls' ///
		`demographic_controls' ///
		`ela_score_controls' ///
		`math_score_controls' ///
		`peer_demographic_controls' ///
		`peer_ela_score_controls' ///
		`peer_math_score_controls'
	
	replace touse_g11_`outcome' = 0 if touse==0
	
	egen n_g11_`outcome' = count(state_student_id) ///
		if touse_g11_`outcome'==1 ///
		, by(cdscode year)
	replace touse_g11_`outcome' = 0 if n_g11_`outcome'<7
}

**** Sample Tabulations
foreach v of varlist touse* {
	tab year `v'
}




keep merge_id_k12_test_scores touse*
sort merge_id_k12_test_scores
compress
save data/sbac/va_samples.dta, replace


timer off 1
timer list
log close
translate log_files/sbac/touse_va.smcl log_files/sbac/touse_va.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
