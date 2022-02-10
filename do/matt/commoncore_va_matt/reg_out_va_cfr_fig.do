version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on June 06, 2019 *
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

log using log_files/sbac/reg_out_va_cfr_fig.smcl, replace

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
This do file creates figures for the regressions of outcomes on school value added.
*/


**********
* Macros *
**********
#delimit ;
#delimit cr
macro list


timer on 1
*****************
* Begin Do File *
*****************
******************************** 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
**************** Regress Outcomes on Value Added
foreach yvar in enr enr_2year enr_4year {
	di "Y Variable = `yvar'"
	
	foreach subject in ela math {
		di "Subject = `subject'"
		
		**** No Peer Controls
		** No TFX
		estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'.ster
		tempname `yvar'_cfr_`subject'
		scalar ``yvar'_cfr_`subject'' = _b[va_cfr_g11_`subject']
		di "``yvar'_cfr_`subject'' = " scalar(``yvar'_cfr_`subject'')

		**** Peer Controls
		** No TFX
		/*estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'_peer.ster
		tempname `yvar'_cfr_`subject'_peer
		scalar ``yvar'_cfr_`subject'' = _b[va_cfr_g11_`subject']*/
	}
	
	**** No Peer Controls
	** No TFX
	estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_ela_math.ster
	tempname `yvar'_cfr_ela_both
	scalar ``yvar'_cfr_ela_both' = _b[va_cfr_g11_ela]
	tempname `yvar'_cfr_math_both
	scalar ``yvar'_cfr_math_both' = _b[va_cfr_g11_math]

	**** Peer Controls
	** No TFX
	/*estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_ela_math_peer.ster
	tempname `yvar'_cfr_ela_both_peer
	scalar ``yvar'_cfr_ela_both_peer' = _b[va_cfr_g11_ela]
	tempname `yvar'_cfr_math_both_peer
	scalar ``yvar'_cfr_math_both_peer' = _b[va_cfr_g11_math]*/
}








**************** Regress Outcomes on Value Added: Heterogeneity by Predicted College
foreach subject in ela math {
	di "Subject = `subject'"
	
	**** No Peer Controls
	** No TFX
	* 2 Year
	estimates use estimates/sbac/reg_enr_2year_va_cfr_g11_`subject'_hetero_enr_prob.ster
	parmest, norestore
	keep if strpos(parm, "enr_2year_prob_diff_xtile#c.va_cfr_g11_`subject'")!=0
	gen xtile = subinstr(substr(parm, 1, strpos(parm, ".") - 1), "b", "", .)
	destring xtile, replace
	
	twoway ///
		(bar estimate xtile) ///
		(rcap min95 max95 xtile) ///
		, yline(`=`enr_2year_cfr_`subject''') legend(off)
	graph export figures/sbac/reg_enr_2year_va_cfr_g11_`subject'_hetero_enr_prob.pdf, replace
	
	* 4 Year
	estimates use estimates/sbac/reg_enr_4year_va_cfr_g11_`subject'_hetero_enr_prob.ster
	parmest, norestore
	keep if strpos(parm, "enr_4year_prob_diff_xtile#c.va_cfr_g11_`subject'")!=0
	gen xtile = subinstr(substr(parm, 1, strpos(parm, ".") - 1), "b", "", .)
	destring xtile, replace
	
	twoway ///
		(bar estimate xtile) ///
		(rcap min95 max95 xtile) ///
		, yline(`=`enr_4year_cfr_`subject''') legend(off)
	graph export figures/sbac/reg_enr_4year_va_cfr_g11_`subject'_hetero_enr_prob.pdf, replace
}

**** No Peer Controls
** No TFX
* 2 Year
estimates use estimates/sbac/reg_enr_2year_va_cfr_g11_ela_math_hetero_enr_prob.ster
parmest, norestore
keep if strpos(parm, "enr_2year_prob_diff_xtile#c.va_cfr_g11_ela")!=0 | strpos(parm, "enr_2year_prob_diff_xtile#c.va_cfr_g11_math")!=0
gen xtile = subinstr(substr(parm, 1, strpos(parm, ".") - 1), "b", "", .)
destring xtile, replace

twoway ///
	(bar estimate xtile) ///
	(rcap min95 max95 xtile) ///
	, yline(`=`enr_2year_cfr_ela_both'') yline(`=`enr_2year_cfr_math_both'') legend(off)
graph export figures/sbac/reg_enr_2year_va_cfr_g11_ela_math_hetero_enr_prob.pdf, replace

* 4 Year
estimates use estimates/sbac/reg_enr_4year_va_cfr_g11_ela_math_hetero_enr_prob.ster
parmest, norestore
keep if strpos(parm, "enr_4year_prob_diff_xtile#c.va_cfr_g11_ela")!=0 | strpos(parm, "enr_4year_prob_diff_xtile#c.va_cfr_g11_math")!=0
gen xtile = subinstr(substr(parm, 1, strpos(parm, ".") - 1), "b", "", .)
destring xtile, replace

twoway ///
	(bar estimate xtile) ///
	(rcap min95 max95 xtile) ///
	, yline(`=`enr_4year_cfr_ela_both'') yline(`=`enr_4year_cfr_math_both'') legend(off)
graph export figures/sbac/reg_enr_4year_va_cfr_g11_ela_math_hetero_enr_prob.pdf, replace








**************** Regress Outcomes on Value Added: Heterogeneity by Prior Score
foreach yvar in enr enr_2year enr_4year {
	di "Y Variable = `yvar'"
	
	foreach subject in ela math {
		di "Subject = `subject'"
		di "`=``yvar'_cfr_`subject''' = " scalar(`=``yvar'_cfr_`subject''')
		
		**** No Peer Controls
		** No TFX
		* Prior ELA Score
		estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'_hetero_prior_ela.ster
		parmest, norestore
		keep if strpos(parm, "prior_ela_z_score_xtile#c.va_cfr_g11_`subject'")!=0
		gen xtile = subinstr(substr(parm, 1, strpos(parm, ".") - 1), "b", "", .)
		destring xtile, replace
		
		twoway ///
			(bar estimate xtile) ///
			(rcap min95 max95 xtile) ///
			, yline(`=``yvar'_cfr_`subject''') legend(off) ///
			ytitle("Coefficient Estimate") xtitle("Prior ELA Score Decile")
		graph export figures/sbac/reg_`yvar'_va_cfr_g11_`subject'_hetero_prior_ela.pdf, replace
		
		* Prior Math Score
		estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'_hetero_prior_math.ster
		parmest, norestore
		keep if strpos(parm, "prior_math_z_score_xtile#c.va_cfr_g11_`subject'")!=0
		gen xtile = subinstr(substr(parm, 1, strpos(parm, ".") - 1), "b", "", .)
		destring xtile, replace
		
		twoway ///
			(bar estimate xtile) ///
			(rcap min95 max95 xtile) ///
			, yline(`=``yvar'_cfr_`subject''') legend(off) ///
			ytitle("Coefficient Estimate") xtitle("Prior Math Score Decile")
		graph export figures/sbac/reg_`yvar'_va_cfr_g11_`subject'_hetero_prior_math.pdf, replace
	}
	
	**** No Peer Controls
	** No TFX
	* Prior ELA Score
	estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_ela_math_hetero_prior_ela.ster
	parmest, norestore
	keep if strpos(parm, "prior_ela_z_score_xtile#c.va_cfr_g11_ela")!=0 | strpos(parm, "prior_ela_z_score_xtile#c.va_cfr_g11_math")!=0
	gen xtile = subinstr(substr(parm, 1, strpos(parm, ".") - 1), "b", "", .)
	destring xtile, replace

	twoway ///
		(bar estimate xtile) ///
		(rcap min95 max95 xtile) ///
		, yline(`=``yvar'_cfr_ela_both'') yline(`=``yvar'_cfr_math_both'') legend(off) ///
		ytitle("Coefficient Estimate") xtitle("Prior ELA Score Decile")
	graph export figures/sbac/reg_`yvar'_va_cfr_g11_ela_math_hetero_prior_ela.pdf, replace
	
	* Prior Math Score
	estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_ela_math_hetero_prior_math.ster
	parmest, norestore
	keep if strpos(parm, "prior_math_z_score_xtile#c.va_cfr_g11_ela")!=0 | strpos(parm, "prior_math_z_score_xtile#c.va_cfr_g11_math")!=0
	gen xtile = subinstr(substr(parm, 1, strpos(parm, ".") - 1), "b", "", .)
	destring xtile, replace

	twoway ///
		(bar estimate xtile) ///
		(rcap min95 max95 xtile) ///
		, yline(`=``yvar'_cfr_ela_both'') yline(`=``yvar'_cfr_math_both'') legend(off) ///
		ytitle("Coefficient Estimate") xtitle("Prior Math Score Decile")
	graph export figures/sbac/reg_`yvar'_va_cfr_g11_ela_math_hetero_prior_math.pdf, replace
}


timer off 1
timer list
log close
translate log_files/sbac/reg_out_va_cfr_fig.smcl log_files/sbac/reg_out_va_cfr_fig.log, replace

if inlist(c(hostname), "sapper", "scribe") {
	/*exit, STATA*/ clear
}
