version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on September 08, 2021 *
*****************************************************

if inlist(c(hostname), "sapper", "scribe") {
	global S_ADO BASE;.;PERSONAL;PLUS;SITE;OLDPLACE
	local home "/home/research/ca_ed_lab/msnaven/common_core_va"
	local ca_ed_lab "/home/research/ca_ed_lab"
	local crosswalks "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/crosswalks/"
	local k12_test_scores "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores"
	local k12_public_schools "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools"
}
else if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="naven" {
	local home "/Users/naven/Documents/research/"
	local ca_ed_lab "/Users/naven/Documents/research/ca_ed_lab"
}
else if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="navenm" {
	local home "/Users/navenm/Documents/research/"
	local ca_ed_lab "/Users/navenm/Documents/research/ca_ed_lab"
}
else if c(machine_type)=="Macintosh (Intel 64-bit)" & c(username)=="Naven" {
	local home "/Users/Naven/Documents/research/"
	local ca_ed_lab "/Users/Naven/Documents/research/ca_ed_lab"
}
cd `home'

log using log_files/sbac/sum_stats_k12_nsc_match.smcl, replace

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
This do file calculates summary statistics for the match between K-12 and 
National Student Clearinghouse data.
*/


**********
* Macros *
**********
local demographic_varlist "age econ_disadvantage eth_american_indian eth_asian eth_hispanic eth_black eth_white eth_biracial eth_other male limited_eng_prof disabled"

tempname nsc_varlist
#delimit ;
scalar `nsc_varlist' = "
nsc_enr nsc_enr_4year nsc_enr_2year 
nsc_enr_ontime nsc_enr_ontime_4year nsc_enr_ontime_2year 
nsc_enr_pub nsc_enr_priv 
nsc_enr_ontime_pub nsc_enr_ontime_priv 
nsc_enr_4year_pub nsc_enr_4year_priv nsc_enr_2year_pub nsc_enr_2year_priv 
nsc_enr_ontime_4year_pub nsc_enr_ontime_4year_priv nsc_enr_ontime_2year_pub nsc_enr_ontime_2year_priv 
nsc_enr_instate nsc_enr_outstate 
nsc_enr_ontime_instate nsc_enr_ontime_outstate 
nsc_enr_4year_instate nsc_enr_4year_outstate nsc_enr_2year_instate nsc_enr_2year_outstate 
nsc_enr_ontime_4year_instate nsc_enr_ontime_4year_outstate nsc_enr_ontime_2year_instate nsc_enr_ontime_2year_outstate 
nsc_enr_uc nsc_enr_ucplus 
nsc_enr_ontime_uc nsc_enr_ontime_ucplus 
nsc_persist_year2 nsc_persist_year2_4year nsc_persist_year2_2year 
nsc_persist_year3 nsc_persist_year3_4year nsc_persist_year4 
nsc_persist_year4_4year 
nsc_deg nsc_deg_4year nsc_deg_2year
" ;
#delimit cr

#delimit ;
local esttab_reg
	b(%12.3gc) se(%12.3gc)
	star(* 0.1 ** 0.05 *** 0.01)
	;
local esttab_sum_stats
	main(mean %12.3gc) aux(sd %12.3gc)
	brackets
	nomtitles nonumbers nonotes
	;
local esttab_tab_stat
	cells(mean(fmt(%12.3gc)) sd(fmt(%12.3gc) par([ ])) count(fmt(%12.3gc) par(\{ \})))
	nomtitles nonumbers nonotes collabels(none)
	;
local esttab_scalars
	scalars(
	"N Observations"
	"r2 $ R^2 $"
	)
	sfmt(
	%12.0gc
	%12.3g
	)
	noobs
	;
local esttab_layout
	compress
	label interaction(\times)
	booktabs
	replace
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
macro list


timer on 1
*****************
* Begin Do File *
*****************
******** K-12 Data
use merge_id_k12_test_scores all_students_sample all_scores_sample first_scores_sample ///
	dataset test cdscode school_id state_student_id year grade ///
	/*cohort_size*/ ///
	`demographic_varlist' ///
	/*cst_ela_z_score cst_math_z_score ///
	sbac_ela_z_score sbac_math_z_score*/ ///
	using `k12_test_scores'/k12_test_scores_clean.dta, clear

gen year_grad_hs = year + (12 - grade)
gen year_college = year + (13 - grade)

merge m:1 cdscode using `k12_public_schools'/k12_public_schools_clean.dta ///
	, gen(merge_public_schools) keepusing(conventional_school) keep(1 3)

merge 1:1 merge_id_k12_test_scores using data/sbac/va_samples.dta ///
	, nogen keepusing(touse_*)




******** NSC Data
gen k12_nsc_match = 0
gen k12_nsc_2010_2017_match = 0
gen k12_nsc_2018cde_match = 0
compress

**** 2010-2017
merge m:1 state_student_id ///
	using `crosswalks'/nsc_2010_2017_outcomes_crosswalk_ssid.dta ///
	, gen(merge_k12_nsc_2010_2017_ssid) keepusing(`=scalar(`nsc_varlist')') keep(1 3)
replace k12_nsc_match = 1 if merge_k12_nsc_2010_2017_ssid==3
replace k12_nsc_2010_2017_match = 1 if merge_k12_nsc_2010_2017_ssid==3
drop merge_k12_nsc_2010_2017_ssid

/*merge m:1 cdscode local_student_id ///
	using `crosswalks'/nsc_2010_2017_outcomes_crosswalk_lsid.dta ///
	, gen(merge_k12_nsc_2010_2017_lsid) keepusing(`=scalar(`nsc_varlist')') keep(1 3) update
replace k12_nsc_match = 1 if merge_k12_nsc_2010_2017_lsid==3
replace k12_nsc_2010_2017_match = 1 if merge_k12_nsc_2010_2017_lsid==3
drop merge_k12_nsc_2010_2017_lsid*/

tab year if grade==11 & k12_nsc_2010_2017_match==1 & touse_g11_ela==1

rename nsc_* A_nsc_*

**** 2010-2018
merge m:1 state_student_id ///
	using `crosswalks'/nsc_2018cde_outcomes_crosswalk_ssid.dta ///
	, gen(merge_k12_nsc_2018cde_ssid) keepusing(`=scalar(`nsc_varlist')') keep(1 3)
replace k12_nsc_match = 1 if merge_k12_nsc_2018cde_ssid==3
replace k12_nsc_2018cde_match = 1 if merge_k12_nsc_2018cde_ssid==3
drop merge_k12_nsc_2018cde_ssid

/*merge m:1 cdscode local_student_id ///
	using `crosswalks'/nsc_2018cde_outcomes_crosswalk_lsid.dta ///
	, gen(merge_k12_nsc_2018cde_lsid) keepusing(`=scalar(`nsc_varlist')') keep(1 3) update
replace k12_nsc_match = 1 if merge_k12_nsc_2018cde_lsid==3
replace k12_nsc_2018cde_match = 1 if merge_k12_nsc_2018cde_lsid==3
drop merge_k12_nsc_2018cde_lsid*/

tab year if grade==11 & k12_nsc_2018cde_match==1 & touse_g11_ela==1

rename nsc_* B_nsc_*




******** Summary Statistics
tab year if grade==11 & k12_nsc_match==1 & touse_g11_ela==1

foreach year of numlist 2017 (-1) 2009 {
	di "Year = `year'"
	
	di "Grade 11 `year': Matched to NSC 2010-2017 and NSC 2010-2018"
	
	quiet: count if grade==11 & year==`year' & touse_g11_ela==1 ///
		& k12_nsc_2010_2017_match==1 & k12_nsc_2018cde_match==1
	tempname n_nsc_match
	scalar `n_nsc_match' = r(N)
	
	foreach v in `=scalar(`nsc_varlist')' {
		di "Variable = `v'"
		
		sum A_`v' B_`v' if grade==11 & year==`year' & touse_g11_ela==1 ///
			& k12_nsc_2010_2017_match==1 & k12_nsc_2018cde_match==1
		
		quiet: count if A_`v'!=B_`v' ///
			& grade==11 & year==`year' & touse_g11_ela==1 ///
			& k12_nsc_2010_2017_match==1 & k12_nsc_2018cde_match==1
		tempname n_nsc_diff
		scalar `n_nsc_diff' = r(N)
		di "`v' does not match for " scalar(`n_nsc_diff') "/" scalar(`n_nsc_match') " observations"
	}
	sum conventional_school `demographic_varlist' if grade==11 & year==`year' & touse_g11_ela==1 ///
			& k12_nsc_2010_2017_match==1 & k12_nsc_2018cde_match==1
	
	
	
	
	di "Grade 11 `year': Matched to NSC 2010-2017 Only"
	
	foreach v in `=scalar(`nsc_varlist')' {
		di "Variable = `v'"
		
		sum A_`v' if grade==11 & year==`year' & touse_g11_ela==1 ///
			& k12_nsc_2010_2017_match==1 & k12_nsc_2018cde_match!=1
	}
	sum conventional_school `demographic_varlist' if grade==11 & year==`year' & touse_g11_ela==1 ///
			& k12_nsc_2010_2017_match==1 & k12_nsc_2018cde_match!=1
	/*tab cdscode if grade==11 & year==`year' & touse_g11_ela==1 ///
			& k12_nsc_2010_2017_match==1 & k12_nsc_2018cde_match!=1, mi*/
	
	
	
	
	di "Grade 11 `year': Matched to NSC 2010-2018 Only"
	
	foreach v in `=scalar(`nsc_varlist')' {
		di "Variable = `v'"
		
		sum B_`v' if grade==11 & year==`year' & touse_g11_ela==1 ///
			& k12_nsc_2010_2017_match!=1 & k12_nsc_2018cde_match==1
	}
	sum conventional_school `demographic_varlist' if grade==11 & year==`year' & touse_g11_ela==1 ///
			& k12_nsc_2010_2017_match!=1 & k12_nsc_2018cde_match==1
	/*tab cdscode if grade==11 & year==`year' & touse_g11_ela==1 ///
			& k12_nsc_2010_2017_match!=1 & k12_nsc_2018cde_match==1, mi*/
}


timer off 1
timer list
log close
translate log_files/sum_stats_k12_nsc_match.smcl log_files/sum_stats_k12_nsc_match.log, replace

if inlist(c(hostname), "sapper", "scribe") {
	/*exit, STATA*/ clear
}
