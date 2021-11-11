version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on December 11, 2018 *
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

log using log_files/sbac/reg_va_cfr_sch_char_tab.smcl, replace

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
This do file creates tables of the estimates of school value added on school 
characteristics.
*/


**********
* Macros *
**********
#delimit ;

local sch_chars
	fte_teach_pc fte_pupil_pc /*fte_admin_pc*/
	/*eng_learner_staff_pc*/
	new_teacher_prop
	/*educ_grad_sch_prop educ_associate_prop*/
	/*status_tenured_prop*/
	credential_full_prop
	/*authorization_stem_prop authorization_ela_prop*/
	c.male_prop##c.enr_male_prop
	c.eth_minority_prop##c.enr_minority_prop
	enr_total
	;

local sch_char_vars "`sch_chars'" ;
local sch_char_vars : subinstr local sch_char_vars "i." "", all ;
local sch_char_vars : subinstr local sch_char_vars "c." "", all ;
local sch_char_vars : subinstr local sch_char_vars "##" " ", all ;
local sch_char_vars : subinstr local sch_char_vars "#" " ", all ;
local sch_char_vars : list uniq sch_char_vars ;

local dem_chars
	enr_male_prop
	enr_minority_prop
	frpm_prop el_prop
	enr_total
	;

local dem_char_vars "`dem_chars'" ;
local dem_char_vars : list uniq dem_char_vars ;

local expenditures
	expenditures_instr_pc
	expenditures3000_pc
	expenditures4000_pc
	expenditures_other_pc
	expenditures7000_pc
	;

local expenditure_vars "`expenditures'" ;
local expenditure_vars : list uniq expenditure_vars ;


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
	%12.3gc
	%12.3g
	)
	noobs
	;
local esttab_layout
	compress
	label interaction($ \times $)
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
macro list


timer on 1
*****************
* Begin Do File *
*****************
gen byte fte_teach_pc = .
label var fte_teach_pc "FTE Teachers / Student"
gen byte fte_pupil_pc = .
label var fte_pupil_pc "FTE Pupil Services / Student"
gen byte new_teacher_prop = .
label var new_teacher_prop "Prop. $ \leq $ 3 Years Experience Teachers"
gen byte credential_full_prop = .
label var credential_full_prop "Prop. Full Credential Teachers"
gen byte male_prop = .
label var male_prop "Prop. Male Teachers"
gen byte enr_male_prop = .
label var enr_male_prop "Prop. Male Enrollment"
gen byte eth_minority_prop = .
label var eth_minority_prop "Prop. Minority Teachers"
gen byte enr_minority_prop = .
label var enr_minority_prop "Prop. Minority Enrollment"
gen byte enr_total = .
label var enr_total "Total Enrollment"
gen byte frpm_prop = .
label var frpm_prop  "Prop. FRPM Students"
gen byte el_prop = .
label var el_prop "Prop. English Learner Students"
gen byte expenditures_instr_pc = .
label var expenditures_instr_pc "Instruction Expenditures (\$1,000s) per Student"
gen byte expenditures3000_pc = .
label var expenditures3000_pc "Pupil Services Expenditures (\$1,000s) per Student"
gen byte expenditures4000_pc = .
label var expenditures4000_pc "Ancillary Services Expenditures (\$1,000s) per Student"
gen byte expenditures_other_pc = .
label var expenditures_other_pc "Other Expenditures (\$1,000s) per Student"
gen byte expenditures7000_pc = .
label var expenditures7000_pc "General Administration Expenditures (\$1,000s) per Student"

**************** School Characteristics
******** No Peer Controls
**** All
estimates use estimates/sbac/reg_va_cfr_g11_ela_sch_char.ster
eststo ela
estimates use estimates/sbac/reg_va_cfr_g11_math_sch_char.ster
eststo math
estimates use estimates/sbac/reg_va_cfr_g11_enr_sch_char.ster
eststo enr
estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_sch_char.ster
eststo enr_2year
estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_sch_char.ster
eststo enr_4year
estimates use estimates/sbac/reg_va_cfr_g11_enr_dk_sch_char.ster
eststo enr_dk
estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_dk_sch_char.ster
eststo enr_2year_dk
estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_dk_sch_char.ster
eststo enr_4year_dk

esttab * using tables/sbac/reg_va_cfr_g11_sch_char.tex ///
	, replace `esttab_reg' `esttab_scalars' `esttab_layout' `esttab_manual' ///
	 prefoot(\midrule)
eststo clear


**** All with Demographic Controls
estimates use estimates/sbac/reg_va_cfr_g11_ela_sch_char_dem.ster
eststo ela
estimates use estimates/sbac/reg_va_cfr_g11_math_sch_char_dem.ster
eststo math
estimates use estimates/sbac/reg_va_cfr_g11_enr_sch_char_dem.ster
eststo enr
estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_sch_char_dem.ster
eststo enr_2year
estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_sch_char_dem.ster
eststo enr_4year
estimates use estimates/sbac/reg_va_cfr_g11_enr_dk_sch_char_dem.ster
eststo enr_dk
estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_dk_sch_char_dem.ster
eststo enr_2year_dk
estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_dk_sch_char_dem.ster
eststo enr_4year_dk

esttab * using tables/sbac/reg_va_cfr_g11_sch_char_dem.tex ///
	, replace `esttab_reg' `esttab_scalars' `esttab_layout' `esttab_manual' ///
	 prefoot(\midrule)
eststo clear


**** Bivariate
local esttab_save "replace"

foreach control_var in `sch_chars' {
	
	** No Demographic Controls
	estimates use estimates/sbac/reg_va_cfr_g11_ela_`control_var'.ster
	eststo ela
	estimates use estimates/sbac/reg_va_cfr_g11_math_`control_var'.ster
	eststo math
	estimates use estimates/sbac/reg_va_cfr_g11_enr_`control_var'.ster
	eststo enr
	estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_`control_var'.ster
	eststo enr_2year
	estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_`control_var'.ster
	eststo enr_4year
	estimates use estimates/sbac/reg_va_cfr_g11_enr_dk_`control_var'.ster
	eststo enr_dk
	estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_dk_`control_var'.ster
	eststo enr_2year_dk
	estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_dk_`control_var'.ster
	eststo enr_4year_dk
	
	esttab * using tables/sbac/reg_va_cfr_g11_sch_char_bivar.tex ///
		, `esttab_save' `esttab_reg' noobs `esttab_layout' `esttab_manual' ///
		drop(_cons)
	eststo clear
	
	** Demographic Controls
	estimates use estimates/sbac/reg_va_cfr_g11_ela_`control_var'_dem.ster
	eststo ela
	estimates use estimates/sbac/reg_va_cfr_g11_math_`control_var'_dem.ster
	eststo math
	estimates use estimates/sbac/reg_va_cfr_g11_enr_`control_var'_dem.ster
	eststo enr
	estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_`control_var'_dem.ster
	eststo enr_2year
	estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_`control_var'_dem.ster
	eststo enr_4year
	estimates use estimates/sbac/reg_va_cfr_g11_enr_dk_`control_var'_dem.ster
	eststo enr_dk
	estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_dk_`control_var'_dem.ster
	eststo enr_2year_dk
	estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_dk_`control_var'_dem.ster
	eststo enr_4year_dk
	
	esttab * using tables/sbac/reg_va_cfr_g11_sch_char_bivar_dem.tex ///
		, `esttab_save' `esttab_reg' noobs `esttab_layout' `esttab_manual' ///
		drop(_cons enr_male_prop enr_minority_prop frpm_prop el_prop enr_total)
	eststo clear
	
	local esttab_save "append"
}


******** Peer Controls
**** All


**** All with Demographic Controls


**** Bivariate
foreach control_var in `sch_chars' {

	** No Demographic Controls

	** Demographic Controls
}




**************** Financial Expenditures
******** No Peer Controls
**** All
estimates use estimates/sbac/reg_va_cfr_g11_ela_finance.ster
eststo ela
estimates use estimates/sbac/reg_va_cfr_g11_math_finance.ster
eststo math
estimates use estimates/sbac/reg_va_cfr_g11_enr_finance.ster
eststo enr
estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_finance.ster
eststo enr_2year
estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_finance.ster
eststo enr_4year
estimates use estimates/sbac/reg_va_cfr_g11_enr_dk_finance.ster
eststo enr_dk
estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_dk_finance.ster
eststo enr_2year_dk
estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_dk_finance.ster
eststo enr_4year_dk

esttab * using tables/sbac/reg_va_cfr_g11_finance.tex ///
	, replace `esttab_reg' `esttab_scalars' `esttab_layout' `esttab_manual' ///
	 prefoot(\midrule)
eststo clear


**** All with Demographic Controls
estimates use estimates/sbac/reg_va_cfr_g11_ela_finance_dem.ster
eststo ela
estimates use estimates/sbac/reg_va_cfr_g11_math_finance_dem.ster
eststo math
estimates use estimates/sbac/reg_va_cfr_g11_enr_finance_dem.ster
eststo enr
estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_finance_dem.ster
eststo enr_2year
estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_finance_dem.ster
eststo enr_4year
estimates use estimates/sbac/reg_va_cfr_g11_enr_dk_finance_dem.ster
eststo enr_dk
estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_dk_finance_dem.ster
eststo enr_2year_dk
estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_dk_finance_dem.ster
eststo enr_4year_dk

esttab * using tables/sbac/reg_va_cfr_g11_finance_dem.tex ///
	, replace `esttab_reg' `esttab_scalars' `esttab_layout' `esttab_manual' ///
	 prefoot(\midrule)
eststo clear


**** Bivariate
foreach control_var in `expenditures' {
	
	** No Demographic Controls
	estimates use estimates/sbac/reg_va_cfr_g11_ela_`control_var'.ster
	eststo ela
	estimates use estimates/sbac/reg_va_cfr_g11_math_`control_var'.ster
	eststo math
	estimates use estimates/sbac/reg_va_cfr_g11_enr_`control_var'.ster
	eststo enr
	estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_`control_var'.ster
	eststo enr_2year
	estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_`control_var'.ster
	eststo enr_4year
	estimates use estimates/sbac/reg_va_cfr_g11_enr_dk_`control_var'.ster
	eststo enr_dk
	estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_dk_`control_var'.ster
	eststo enr_2year_dk
	estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_dk_`control_var'.ster
	eststo enr_4year_dk
	
	esttab * using tables/sbac/reg_va_cfr_g11_finance_bivar.tex	///
		, `esttab_save' `esttab_reg' noobs `esttab_layout' `esttab_manual' ///
		drop(_cons)
	eststo clear
	
	** Demographic Controls
	estimates use estimates/sbac/reg_va_cfr_g11_ela_`control_var'_dem.ster
	eststo ela
	estimates use estimates/sbac/reg_va_cfr_g11_math_`control_var'_dem.ster
	eststo math
	estimates use estimates/sbac/reg_va_cfr_g11_enr_`control_var'_dem.ster
	eststo enr
	estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_`control_var'_dem.ster
	eststo enr_2year
	estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_`control_var'_dem.ster
	eststo enr_4year
	estimates use estimates/sbac/reg_va_cfr_g11_enr_dk_`control_var'_dem.ster
	eststo enr_dk
	estimates use estimates/sbac/reg_va_cfr_g11_enr_2year_dk_`control_var'_dem.ster
	eststo enr_2year_dk
	estimates use estimates/sbac/reg_va_cfr_g11_enr_4year_dk_`control_var'_dem.ster
	eststo enr_4year_dk
	
	esttab * using tables/sbac/reg_va_cfr_g11_finance_bivar.tex	///
		, `esttab_save' `esttab_reg' noobs `esttab_layout' `esttab_manual' ///
		drop(_cons enr_male_prop enr_minority_prop frpm_prop el_prop enr_total)
	eststo clear
}


******** Peer Controls
**** All


**** All with Demographic Controls


**** Bivariate
foreach control_var in `expenditures' {
	
	** No Demographic Controls
	
	** Demographic Controls
}


timer off 1
timer list
log close
translate log_files/sbac/reg_va_cfr_sch_char_tab.smcl log_files/sbac/reg_va_cfr_sch_char_tab.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
