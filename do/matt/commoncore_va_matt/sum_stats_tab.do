version 15.0
cap log close _all

*****************************************************
* First created by Matthew Naven on September 18, 2018 *
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

log using log_files/sbac/sum_stats_tab.smcl, replace

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
This file creates summary statistics tables for the SBAC value added sample and 
college outcome sample.
*/


**********
* Macros *
**********
#delimit ;
local esttab_reg
	b(%12.3gc) se(%12.3gc)
	star(* 0.1 ** 0.05 *** 0.01)
	;
local esttab_sum_stats
	/*main(mean %5.3f) aux(sd %4.3f)*/
	brackets
	/*nomtitles nonumbers nonotes*/
	;
local esttab_tab_stat
	cells(mean(fmt(%12.3gc)) sd(fmt(%12.3gc) par([ ])) count(fmt(%12.3gc) par(\{ \})))
	nomtitles nonumbers nonotes collabels(none)
	;
local esttab_scalars
	scalars(
	"N Observations"
	/*"r2 $ R^2 $"*/
	)
	sfmt(
	%12.3gc
	/*%12.3g*/
	)
	noobs
	;
local esttab_layout
	compress
	label interaction(\times)
	booktabs
	/*replace*/
	;
local esttab_manual
	nolines
	nomtitles nonumbers nonotes
	fragment
	;
local esttab_mgroups
	nomtitles
	mgroups(""
	, pattern()
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
	;
local esttab_keep
	keep(
	
	)
	order(
	
	)
	;
#delimit cr

local label_all "All Students"
local label_if_school_level "+ 9-12 School"
local label_all_scores "+ Nonmissing Test Score"
local label_first_scores "+ First Test Score for Grade"
local label_ssid_grade_year_school "+ Nonmissing Student ID, Grade, Year, and School"
local label_conventional_school "+ Conventional School"
local label_cohort_size "+ 11th Graders per School $ > $ 10"
local label_cst_z_score "+ Nonmissing Subject Test Score"
local label_demographic_controls "+ Nonmissing Demographic Controls"
local label_prior_cst_z_score "+ Nonmissing Prior Test Scores"
local label_peer "+ Nonmissing Peer Controls"
local label_valid_cohort_size "+ School VA Sample Size $ \geq $ 7"

macro list


timer on 1
*****************
* Begin Do File *
*****************
******************************** 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
**************** Mark the sample to use
local save_option "replace"

foreach sample in all if_school_level /*all_scores*/ first_scores /*ssid_grade_year_school*/ ///
	conventional_school cohort_size ///
	cst_z_score demographic_controls prior_cst_z_score /*peer*/ ///
	valid_cohort_size {
	di "Sample = `sample'"
	
	foreach subject in ela math {
		di "Subject = `subject'"
		
		estimates use estimates/sbac/counts_k12_`sample'_g11_`subject'.ster
		eststo g11_`subject'_count
		matrix mat_count_`subject' = e(count)
		estadd matrix mat_stat = mat_count_`subject'
		/*local mat_count_`subject' : di %12.3gc mat_count_`subject'[1, 1]
		matrix mat_count_`subject'[1, 1] = `mat_count_`subject''*/
		
		estimates use estimates/sbac/z_score_k12_`sample'_g11_`subject'.ster
		eststo g11_`subject'_z_score
		matrix mat_z_score_`subject' = e(mean)
		estadd matrix mat_stat = mat_z_score_`subject'
		/*local mat_z_score_`subject' : di %5.3f mat_z_score_`subject'[1, 1]
		matrix mat_z_score_`subject'[1, 1] = `mat_z_score_`subject''*/
		/*matrix z_score = e(mean)
		matrix rownames z_score = pvalue
		matrix colnames z_score = count_var*/
	}
	
	matrix count_z_score = [mat_count_ela[1, 1], mat_z_score_ela[1, 1], mat_count_math[1, 1], mat_z_score_math[1, 1]]
	esttab g11_ela_count g11_ela_z_score g11_math_count g11_math_z_score using tables/sbac/counts_k12.tex ///
		, `save_option' cells(mat_stat(fmt(%12.3gc))) ///
		compress label interaction(\times) booktabs ///
		nonotes ///
		noobs ///
		nomtitles nonumbers nonotes fragment collabels(none) ///
		rename(count_var x sbac_ela_z_score x sbac_math_z_score x) ///
		coeflabel(x "`label_`sample''")
	eststo clear
	
	local save_option "append"
}




**************** Summary Statistics
******** ELA
**** No Peer Controls
** VA Sample
estimates use estimates/sbac/sum_stats_g11_ela.ster
eststo g11_ela

** Dropped from VA Sample
estimates use estimates/sbac/sum_stats_g11_ela_dropped.ster
eststo g11_ela_dropped

******** Math
**** No Peer Controls
** VA Sample
estimates use estimates/sbac/sum_stats_g11_math.ster
eststo g11_math

** Dropped from VA Sample
estimates use estimates/sbac/sum_stats_g11_math_dropped.ster
eststo g11_math_dropped


**** No Peer Controls
esttab g11_ela g11_ela_dropped using tables/sbac/sum_stats_g11.tex ///
	, replace `esttab_sum_stats' main(mean %12.3gc) aux(sd %12.3gc) wide noobs `esttab_layout' `esttab_manual' ///
	keep( ///
		cohort_size ///
	) ///
	coeflabel( ///
		cohort_size "11th Graders per School" ///
	)

esttab g11_ela g11_ela_dropped using tables/sbac/sum_stats_g11.tex ///
	, append `esttab_sum_stats' main(mean %5.1f) aux(sd %4.3f) wide noobs `esttab_layout' `esttab_manual' ///
	keep( ///
		age ///
	) ///
	coeflabel( ///
		age "Age in Years" ///
	)

esttab g11_ela g11_ela_dropped using tables/sbac/sum_stats_g11.tex ///
	, append `esttab_sum_stats' main(mean %5.3f) wide noobs `esttab_layout' `esttab_manual' ///
	keep( ///
		male ///
		eth_hispanic ///
		eth_white ///
		eth_asian ///
		eth_black ///
		eth_other ///
		econ_disadvantage ///
		limited_eng_prof ///
		disabled ///
		 ///
	) ///
	order( ///
		male ///
		eth_hispanic ///
		eth_white ///
		eth_asian ///
		eth_black ///
		eth_other ///
		econ_disadvantage ///
		limited_eng_prof ///
		disabled ///
		 ///
	) ///
	coeflabel( ///
		male "Male" ///
		eth_hispanic "Hispanic or Latino" ///
		eth_white "White" ///
		eth_asian "Asian" ///
		eth_black "Black or African American" ///
		eth_other "Other Race" ///
		econ_disadvantage "Economic Disadvantage" ///
		limited_eng_prof "Limited English Proficiency Status" ///
		disabled "Disabled" ///
	)

esttab g11_ela g11_ela_dropped using tables/sbac/sum_stats_g11.tex ///
	, append `esttab_sum_stats' main(mean %5.3f) aux(sd %4.3f) wide noobs `esttab_layout' `esttab_manual' ///
	keep( ///
		sbac_ela_z_score ///
	) ///
	coeflabel( ///
		sbac_ela_z_score "ELA Z-Score" ///
	)

esttab g11_math g11_math_dropped using tables/sbac/sum_stats_g11.tex ///
	, append `esttab_sum_stats' main(mean %5.3f) aux(sd %4.3f) wide noobs `esttab_layout' `esttab_manual' ///
	keep( ///
		sbac_math_z_score ///
	) ///
	coeflabel( ///
		sbac_math_z_score "Math Z-Score" ///
	)

esttab g11_ela g11_ela_dropped using tables/sbac/sum_stats_g11.tex ///
	, append `esttab_sum_stats' main(mean %5.3f) aux(sd %4.3f) wide `esttab_scalars' `esttab_layout' `esttab_manual' prefoot(\midrule) ///
	keep( ///
		prior_ela_z_score ///
		prior_math_z_score ///
	) ///
	coeflabel( ///
		prior_ela_z_score "Prior ELA Z-Score" ///
		prior_math_z_score "Prior Math Z-Score" ///
	)


esttab g11_ela g11_math using tables/sbac/sum_stats_g11_peer.tex ///
	, replace `esttab_sum_stats' `esttab_scalars' `esttab_layout' `esttab_manual' ///
	coeflabel(cohort_size "11th Graders per School")
































******************************** Postsecondary Outcomes
**************** Summary Statistics
******** ELA
**** All
** VA Sample
estimates use estimates/sbac/sum_stats_g11_ela_college.ster
eststo g11_ela_college

estimates use estimates/sbac/sum_stats_g11_ela_college_tabstat.ster

** Dropped from VA Sample
estimates use estimates/sbac/sum_stats_g11_ela_college_dropped.ster
eststo g11_ela_college_dropped

**** CCC
/*estimates use estimates/sbac/sum_stats_g11_ela_ccc.ster
eststo g11_ela_ccc

**** CSU
estimates use estimates/sbac/sum_stats_g11_ela_csu.ster
eststo g11_ela_csu

**** CCC/CSU
estimates use estimates/sbac/sum_stats_g11_ela_ccc_csu.ster
eststo g11_ela_ccc_csu

**** Conditional on Enrolling in CSU
estimates use estimates/sbac/sum_stats_g11_ela_csu_enroll.ster
eststo g11_ela_csu_enroll*/

******** Math
**** All
** VA Sample
estimates use estimates/sbac/sum_stats_g11_math_college.ster
eststo g11_math_college

estimates use estimates/sbac/sum_stats_g11_math_college_tabstat.ster

** Dropped from VA Sample
estimates use estimates/sbac/sum_stats_g11_math_college_dropped.ster
eststo g11_math_college_dropped

**** CCC
/*estimates use estimates/sbac/sum_stats_g11_math_ccc.ster
eststo g11_math_ccc

**** CSU
estimates use estimates/sbac/sum_stats_g11_math_csu.ster
eststo g11_math_csu

**** CCC/CSU
estimates use estimates/sbac/sum_stats_g11_math_ccc_csu.ster
eststo g11_math_ccc_csu

**** Conditional on Enrolling in CSU
estimates use estimates/sbac/sum_stats_g11_math_csu_enroll.ster
eststo g11_math_csu_enroll*/


esttab g11_ela_college g11_ela_college_dropped using tables/sbac/sum_stats_college.tex ///
	, replace `esttab_sum_stats' main(mean %5.3f) wide `esttab_scalars' `esttab_layout' `esttab_manual' prefoot(\midrule) ///
	coeflabel( ///
		enr_ontime "Enrolled at a Postsecondary Institution" ///
		enr_ontime_2year "Enrolled at a 2-Year College" ///
		enr_ontime_4year "Enrolled at a 4-Year University" ///
		enr_ontime_pub "Enrolled at a Public Institution" ///
		enr_ontime_priv "Enrolled at a Private Institution" ///
		enr_ontime_instate "Enrolled at a CA Institution" ///
		enr_ontime_outstate "Enrolled at an Out-of-State Institution" ///
	)

/*esttab g11_ela_ccc_csu g11_ela_csu_enroll g11_math_ccc_csu g11_math_csu_enroll using tables/sbac/sum_stats_ccc_csu.tex ///
	, replace `esttab_sum_stats' `esttab_scalars' `esttab_layout' `esttab_manual'*/


timer off 1
timer list
log close
translate log_files/sbac/sum_stats_tab.smcl log_files/sbac/sum_stats_tab.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
