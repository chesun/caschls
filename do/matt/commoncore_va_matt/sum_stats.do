version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on May 7, 2018 *
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

log using log_files/sbac/sum_stats.smcl, replace

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
tab grade year if dataset=="CAASPP"
sum

* Exclude schools where more than 25 percent of students are receiving special education services

* Drop if a student is receiving instruction at home, in a hospital, or in a school serving disabled students solely

* Drop if 10 or fewer students per school
/*drop if cohort_size<=10*/




******** Postsecondary Outcomes
do do_files/merge_k12_postsecondary.doh enr_only




count
tab year
tab grade year if dataset=="CAASPP"
sum


* Save temporary dataset
count
tab year
tab grade year if dataset=="CAASPP"
sum
compress
tempfile va_dataset
save `va_dataset'
































******************************** 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
use if grade==11 & dataset=="CAASPP" & inrange(year, `test_score_min_year', `test_score_max_year') using `va_dataset', clear

include do_files/sbac/create_diff_school_prop.doh
/*keep if diff_school_prop>=0.95*/

count
tab year
tab grade year
sum

include do_files/sbac/create_prior_scores.doh

**************** Sample
gen byte count_var = 1
gen mi_ssid_grade_year_school = (mi(state_student_id, grade, year, cdscode))
gen byte mi_sbac_ela_z_score = (mi(sbac_ela_z_score))
gen byte mi_sbac_math_z_score = (mi(sbac_math_z_score))
gen byte mi_enr_ontime = (mi(enr_ontime))
gen byte mi_enr_ontime_2year = (mi(enr_ontime_2year))
gen byte mi_enr_ontime_4year = (mi(enr_ontime_4year))
gen byte mi_demographic_controls = (mi(cohort_size, age, male, eth_hispanic, eth_asian, eth_black, eth_other, econ_disadvantage, limited_eng_prof, disabled))
gen byte mi_prior_ela_z_score = (mi(prior_ela_z_score))
gen byte mi_prior_math_z_score = (mi(prior_math_z_score))
gen byte mi_peer_demographic_controls = (mi(peer_age, peer_male, peer_eth_hispanic, peer_eth_asian, peer_eth_black, peer_eth_other, peer_econ_disadvantage, peer_limited_eng_prof, peer_disabled))
gen byte mi_peer_prior_ela_z_score = (mi(peer_prior_ela_z_score))
gen byte mi_peer_prior_math_z_score = (mi(peer_prior_math_z_score))
egen n_g11_ela = count(state_student_id) ///
	if touse_g11_ela==1 ///
	, by(cdscode year)
egen n_g11_math = count(state_student_id) ///
	if touse_g11_math==1 ///
	, by(cdscode year)

******** ELA
**** Counts
estpost tabstat ///
	count_var ///
	if grade==11 ///
	& all_students_sample==1 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_all_g11_ela.ster, replace

tab year ///
	if grade==11 ///
	& all_students_sample==1


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& all_students_sample==1 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_if_school_level_g11_ela.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& all_students_sample==1


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& all_scores_sample==1 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_all_scores_g11_ela.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& all_scores_sample==1


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_first_scores_g11_ela.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_ssid_grade_year_school_g11_ela.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_conventional_school_g11_ela.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_cohort_size_g11_ela.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size))


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_cst_z_score_g11_ela.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	& mi_demographic_controls==0 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_demographic_controls_g11_ela.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	& mi_demographic_controls==0


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_prior_cst_z_score_g11_ela.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	& mi_peer_demographic_controls==0 & mi_peer_prior_ela_z_score==0 & mi_peer_prior_math_z_score==0 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_peer_g11_ela.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	& mi_peer_demographic_controls==0 & mi_peer_prior_ela_z_score==0 & mi_peer_prior_math_z_score==0


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	& mi_peer_demographic_controls==0 & mi_peer_prior_ela_z_score==0 & mi_peer_prior_math_z_score==0 ///
	& (n_g11_ela>=7 & !mi(n_g11_ela)) ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_valid_cohort_size_g11_ela.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	& mi_peer_demographic_controls==0 & mi_peer_prior_ela_z_score==0 & mi_peer_prior_math_z_score==0 ///
	& (n_g11_ela>=7 & !mi(n_g11_ela))


**** Z-Scores
estpost tabstat ///
	sbac_ela_z_score ///
	if grade==11 ///
	& all_students_sample==1 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_all_g11_ela.ster, replace

estpost tabstat ///
	sbac_ela_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& all_students_sample==1 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_if_school_level_g11_ela.ster, replace

estpost tabstat ///
	sbac_ela_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& all_scores_sample==1 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_all_scores_g11_ela.ster, replace

estpost tabstat ///
	sbac_ela_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_first_scores_g11_ela.ster, replace

estpost tabstat ///
	sbac_ela_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_ssid_grade_year_school_g11_ela.ster, replace

estpost tabstat ///
	sbac_ela_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_conventional_school_g11_ela.ster, replace

estpost tabstat ///
	sbac_ela_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_cohort_size_g11_ela.ster, replace

estpost tabstat ///
	sbac_ela_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_cst_z_score_g11_ela.ster, replace

estpost tabstat ///
	sbac_ela_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	& mi_demographic_controls==0 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_demographic_controls_g11_ela.ster, replace

estpost tabstat ///
	sbac_ela_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_prior_cst_z_score_g11_ela.ster, replace

estpost tabstat ///
	sbac_ela_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	& mi_peer_demographic_controls==0 & mi_peer_prior_ela_z_score==0 & mi_peer_prior_math_z_score==0 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_peer_g11_ela.ster, replace

estpost tabstat ///
	sbac_ela_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_ela_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	& mi_peer_demographic_controls==0 & mi_peer_prior_ela_z_score==0 & mi_peer_prior_math_z_score==0 ///
	& (n_g11_ela>=7 & !mi(n_g11_ela)) ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_valid_cohort_size_g11_ela.ster, replace


******** Math
**** Counts
estpost tabstat ///
	count_var ///
	if grade==11 ///
	& all_students_sample==1 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_all_g11_math.ster, replace

tab year ///
	if grade==11 ///
	& all_students_sample==1


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& all_students_sample==1 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_if_school_level_g11_math.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& all_students_sample==1


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& all_scores_sample==1 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_all_scores_g11_math.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& all_scores_sample==1


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_first_scores_g11_math.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_ssid_grade_year_school_g11_math.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_conventional_school_g11_math.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_cohort_size_g11_math.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size))


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_cst_z_score_g11_math.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	& mi_demographic_controls==0 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_demographic_controls_g11_math.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	& mi_demographic_controls==0


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_prior_cst_z_score_g11_math.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	& mi_peer_demographic_controls==0 & mi_peer_prior_ela_z_score==0 & mi_peer_prior_math_z_score==0 ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_peer_g11_math.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	& mi_peer_demographic_controls==0 & mi_peer_prior_ela_z_score==0 & mi_peer_prior_math_z_score==0


estpost tabstat ///
	count_var ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	& mi_peer_demographic_controls==0 & mi_peer_prior_ela_z_score==0 & mi_peer_prior_math_z_score==0 ///
	& (n_g11_math>=7 & !mi(n_g11_math)) ///
	, stat(n) columns(statistics)
estimates save estimates/sbac/counts_k12_valid_cohort_size_g11_math.ster, replace

tab year ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	& mi_peer_demographic_controls==0 & mi_peer_prior_ela_z_score==0 & mi_peer_prior_math_z_score==0 ///
	& (n_g11_math>=7 & !mi(n_g11_math))


**** Z-Scores
estpost tabstat ///
	sbac_math_z_score ///
	if grade==11 ///
	& all_students_sample==1 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_all_g11_math.ster, replace

estpost tabstat ///
	sbac_math_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& all_students_sample==1 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_if_school_level_g11_math.ster, replace

estpost tabstat ///
	sbac_math_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& all_scores_sample==1 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_all_scores_g11_math.ster, replace

estpost tabstat ///
	sbac_math_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_first_scores_g11_math.ster, replace

estpost tabstat ///
	sbac_math_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_ssid_grade_year_school_g11_math.ster, replace

estpost tabstat ///
	sbac_math_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_conventional_school_g11_math.ster, replace

estpost tabstat ///
	sbac_math_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_cohort_size_g11_math.ster, replace

estpost tabstat ///
	sbac_math_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_cst_z_score_g11_math.ster, replace

estpost tabstat ///
	sbac_math_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	& mi_demographic_controls==0 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_demographic_controls_g11_math.ster, replace

estpost tabstat ///
	sbac_math_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_prior_cst_z_score_g11_math.ster, replace

estpost tabstat ///
	sbac_math_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	& mi_peer_demographic_controls==0 & mi_peer_prior_ela_z_score==0 & mi_peer_prior_math_z_score==0 ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_peer_g11_math.ster, replace

estpost tabstat ///
	sbac_math_z_score ///
	if grade==11 ///
	& (diff_school_prop>=0.95 & !mi(diff_school_prop)) ///
	& first_scores_sample==1 ///
	& mi_ssid_grade_year_school==0 ///
	& conventional_school==1 ///
	& (cohort_size>10 & !mi(cohort_size)) ///
	& mi_sbac_math_z_score==0 ///
	& mi_demographic_controls==0 ///
	& mi_prior_ela_z_score==0 ///
	& mi_prior_math_z_score==0 ///
	& mi_peer_demographic_controls==0 & mi_peer_prior_ela_z_score==0 & mi_peer_prior_math_z_score==0 ///
	& (n_g11_math>=7 & !mi(n_g11_math)) ///
	, stat(mean sd) columns(statistics)
estimates save estimates/sbac/z_score_k12_valid_cohort_size_g11_math.ster, replace


**************** Summary Statistics
******** ELA
**** VA Sample
estpost sum ///
	cohort_size ///
	`va_control_vars' eth_white ///
	sbac_ela_z_score ///
	prior_ela_z_score prior_math_z_score ///
	`peer_demographic_controls' ///
	peer_prior_ela_z_score peer_prior_math_z_score ///
	if touse_g11_ela==1
estimates save estimates/sbac/sum_stats_g11_ela.ster, replace

tab year ///
	if touse_g11_ela==1

**** Dropped from VA Sample
estpost sum ///
	cohort_size ///
	`va_control_vars' eth_white ///
	sbac_ela_z_score ///
	prior_ela_z_score prior_math_z_score ///
	`peer_demographic_controls' ///
	peer_prior_ela_z_score peer_prior_math_z_score ///
	if touse_g11_ela==0 & grade==11
estimates save estimates/sbac/sum_stats_g11_ela_dropped.ster, replace

tab year ///
	if touse_g11_ela==0 & grade==11

******** Math
**** VA Sample
estpost sum ///
	cohort_size ///
	`va_control_vars' eth_white ///
	sbac_math_z_score ///
	prior_ela_z_score prior_math_z_score ///
	`peer_demographic_controls' ///
	peer_prior_ela_z_score peer_prior_math_z_score ///
	if touse_g11_math==1
estimates save estimates/sbac/sum_stats_g11_math.ster, replace

tab year ///
	if touse_g11_math==1

**** Dropped from VA Sample
estpost sum ///
	cohort_size ///
	`va_control_vars' eth_white ///
	sbac_math_z_score ///
	prior_ela_z_score prior_math_z_score ///
	`peer_demographic_controls' ///
	peer_prior_ela_z_score peer_prior_math_z_score ///
	if touse_g11_math==0 & grade==11
estimates save estimates/sbac/sum_stats_g11_math_dropped.ster, replace

tab year ///
	if touse_g11_math==0 & grade==11
































******************************** Postsecondary Outcomes
count if nsc_enr==1 & ccc_enr!=1 & csu_enr!=1
count if nsc_enr_2year_instate==1 & ccc_enr!=1
count if nsc_enr_4year_instate==1 & csu_enr!=1
count if ccc_enr==1 & nsc_enr!=1
count if ccc_enr==1 & nsc_enr_2year_instate!=1
count if csu_enr==1 & nsc_enr!=1
count if csu_enr==1 & nsc_enr_4year_instate!=1

count if nsc_enr_ontime==1 & ccc_enr_ontime!=1 & csu_enr_ontime!=1
count if nsc_enr_ontime_2year_instate==1 & ccc_enr_ontime!=1
count if nsc_enr_ontime_4year_instate==1 & csu_enr_ontime!=1
count if ccc_enr_ontime==1 & nsc_enr_ontime!=1
count if ccc_enr_ontime==1 & nsc_enr_ontime_2year_instate!=1
count if csu_enr_ontime==1 & nsc_enr_ontime!=1
count if csu_enr_ontime==1 & nsc_enr_ontime_4year_instate!=1

**************** Summary Statistics
******** ELA
**** VA Sample
estpost sum ///
	enr_ontime ///
	enr_ontime_2year enr_ontime_4year ///
	enr_ontime_pub enr_ontime_priv ///
	enr_ontime_instate enr_ontime_outstate ///
	if touse_g11_ela==1
estimates save estimates/sbac/sum_stats_g11_ela_college.ster, replace

estpost tabstat ///
	enr_ontime ///
	enr_ontime_2year enr_ontime_4year ///
	enr_ontime_pub enr_ontime_priv ///
	enr_ontime_instate enr_ontime_outstate ///
	if touse_g11_ela==1 ///
	, stat(mean sd n) columns(statistics)
estimates save estimates/sbac/sum_stats_g11_ela_college_tabstat.ster, replace

**** Dropped from VA Sample
estpost sum ///
	enr_ontime ///
	enr_ontime_2year enr_ontime_4year ///
	enr_ontime_pub enr_ontime_priv ///
	enr_ontime_instate enr_ontime_outstate ///
	if touse_g11_ela==0 & grade==11
estimates save estimates/sbac/sum_stats_g11_ela_college_dropped.ster, replace

**** CCC
/*estpost sum ///
	ccc_enrolled ///
	if touse_g11_ela==1
estimates save estimates/sbac/sum_stats_g11_ela_ccc.ster, replace

**** CSU
estpost sum ///
	csu_applied csu_applied_multiple csu_accepted csu_enrolled ///
	if touse_g11_ela==1
estimates save estimates/sbac/sum_stats_g11_ela_csu.ster, replace

**** CCC/CSU
estpost sum ///
	ccc_enrolled ///
	csu_applied csu_applied_multiple csu_accepted csu_enrolled ///
	applied enrolled ///
	if touse_g11_ela==1
estimates save estimates/sbac/sum_stats_g11_ela_ccc_csu.ster, replace

**** Conditional on Enrolling in CSU
estpost sum ///
	csu_eng_remediation csu_math_remediation csu_major_stem ///
	if touse_g11_ela==1
estimates save estimates/sbac/sum_stats_g11_ela_csu_enroll.ster, replace*/

******** Math
**** VA Sample
estpost sum ///
	enr_ontime ///
	enr_ontime_2year enr_ontime_4year ///
	enr_ontime_pub enr_ontime_priv ///
	enr_ontime_instate enr_ontime_outstate ///
	if touse_g11_math==1
estimates save estimates/sbac/sum_stats_g11_math_college.ster, replace

estpost tabstat ///
	enr_ontime ///
	enr_ontime_2year enr_ontime_4year ///
	enr_ontime_pub enr_ontime_priv ///
	enr_ontime_instate enr_ontime_outstate ///
	if touse_g11_math==1 ///
	, stat(mean sd n) columns(statistics)
estimates save estimates/sbac/sum_stats_g11_math_college_tabstat.ster, replace

**** Dropped from VA Sample
estpost sum ///
	enr_ontime ///
	enr_ontime_2year enr_ontime_4year ///
	enr_ontime_pub enr_ontime_priv ///
	enr_ontime_instate enr_ontime_outstate ///
	if touse_g11_math==0 & grade==11
estimates save estimates/sbac/sum_stats_g11_math_college_dropped.ster, replace

**** CCC
/*estpost sum ///
	ccc_enrolled ///
	if touse_g11_math==1
estimates save estimates/sbac/sum_stats_g11_math_ccc.ster, replace

**** CSU
estpost sum ///
	csu_applied csu_applied_multiple csu_accepted csu_enrolled ///
	if touse_g11_math==1
estimates save estimates/sbac/sum_stats_g11_math_csu.ster, replace

**** CCC/CSU
estpost sum ///
	ccc_enrolled ///
	csu_applied csu_applied_multiple csu_accepted csu_enrolled ///
	applied enrolled ///
	if touse_g11_math==1
estimates save estimates/sbac/sum_stats_g11_math_ccc_csu.ster, replace

**** Conditional on Enrolling in CSU
estpost sum ///
	csu_eng_remediation csu_math_remediation csu_major_stem ///
	if touse_g11_math==1
estimates save estimates/sbac/sum_stats_g11_math_csu_enroll.ster, replace*/


timer off 1
timer list
log close
translate log_files/sbac/sum_stats.smcl log_files/sbac/sum_stats.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
