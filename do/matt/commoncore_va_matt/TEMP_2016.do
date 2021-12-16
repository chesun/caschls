version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on May 7, 2018 *
*****************************************************

if inlist(c(hostname), "sapper", "scribe") {
	global S_ADO BASE;.;PERSONAL;PLUS;SITE;OLDPLACE
	local home "/home/research/ca_ed_lab/msnaven/common_core_va"
	local ca_ed_lab "/home/research/ca_ed_lab"
	local k12_test_scores "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores"
	local public_access "/home/research/ca_ed_lab/msnaven/data/public_access"
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
This file calculates summary statistics for the SBAC value added sample and 
college outcome sample.
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
**************** Create VA Dataset
use merge_id_k12_test_scores all_students_sample all_scores_sample first_scores_sample ///
	dataset test cdscode school_id state_student_id year grade ///
	cohort_size ///
	sbac_ela_z_score sbac_math_z_score ///
	`va_control_vars' eth_white ///
	/*if substr(cdscode, 1, 7)=="3768338"*/ ///
	using `k12_test_scores'/k12_test_scores_clean.dta, clear
merge 1:1 merge_id_k12_test_scores using data/sbac/va_samples.dta ///
	, nogen keepusing(touse_*)

replace age = age / 365
label var age "Age in Years"

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

replace peer_age = peer_age / 365
label var peer_age "Age in Years Peer Avg."

count
sum

* Merge to school grade spans
merge m:1 cdscode year using `k12_test_scores_public'/k12_diff_school_prop_schyr.dta ///
	, gen(merge_grade_span) keepusing(gr11_*_diff_school_prop) keep(1 3)

* Merge to median cohort sizes
merge m:1 cdscode using `k12_test_scores_public'/k12_cohort_size_sch.dta ///
	, gen(merge_cohort_size) keepusing(med_cohort_size_first_scores) keep(1 3)

* Keep conventional schools
merge m:1 cdscode using `k12_public_schools'/k12_public_schools_clean.dta ///
	, gen(merge_public_schools) keepusing(conventional_school) keep(1 3)
/*keep if conventional_school==1*/

count
tab year
sum

* Exclude schools where more than 25 percent of students are receiving special education services

* Drop if a student is receiving instruction at home, in a hospital, or in a school serving disabled students solely

* Drop if 10 or fewer students per school
/*drop if cohort_size<=10*/




******** Postsecondary Outcomes
do `ca_ed_lab'/msnaven/data/do_files/merge_k12_postsecondary.doh enr_only




count
tab year
sum


* Save temporary dataset
count
tab year
sum
compress
tempfile va_dataset
save `va_dataset'








