version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on December 11, 2018 *
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

log using log_files/sbac/reg_va_cfr_sch_char.smcl, replace

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
This do file regresses school value added estimates on school characteristics.
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
foreach subject in ela math {
	di "Subject = `subject'"
	
	use data/sbac/va_g11_`subject'.dta, clear
	
	foreach v of varlist va_* {
		sum `v'
		replace `v' = `v' - r(mean)
		replace `v' = `v' / r(sd)
	}
	
	merge m:1 cdscode year using data/sch_char.dta, keep(1 3) nogen
	replace enr_total = enr_total / 1000
	label var enr_total "Total Enrollment (Thousands)"
	gen ccode = substr(cdscode, 1, 2)
	gen dcode = substr(cdscode, 3, 5)
	merge m:1 ccode dcode year using data/financial.dta, keep(1 3) nogen
	preserve
	
	**************** School Characteristics
	restore, preserve
	foreach v of varlist `sch_char_control_vars' {
		di "Variable = `v'"
		
		sum `v', d
		xtile `v'_xt = `v', nquantiles(100)
		drop if inlist(`v'_xt, 1, 100)
		sum `v', d
	}
			
	******** No Peer Controls
	**** All
	reg va_cfr_g11_`subject' `sch_chars' ///
		, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
	estimates save estimates/sbac/reg_va_cfr_g11_`subject'_sch_char.ster, replace
	
	
	**** All with Demographic Controls
	reg va_cfr_g11_`subject' `sch_chars' `dem_chars' ///
		, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
	estimates save estimates/sbac/reg_va_cfr_g11_`subject'_sch_char_dem.ster, replace
	
	
	**** Bivariate
	foreach control_var in `sch_chars' {
		
		** No Demographic Controls
		reg va_cfr_g11_`subject' `control_var' ///
			, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
		estimates save estimates/sbac/reg_va_cfr_g11_`subject'_`control_var'.ster, replace
		
		** Demographic Controls
		reg va_cfr_g11_`subject' `control_var' `dem_chars' ///
			, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
		estimates save estimates/sbac/reg_va_cfr_g11_`subject'_`control_var'_dem.ster, replace
	}
	
	
	******** Peer Controls
	**** All
	reg va_cfr_g11_`subject'_peer `sch_chars' ///
		, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
	estimates save estimates/sbac/reg_va_cfr_g11_`subject'_peer_sch_char.ster, replace
	
	
	**** All with Demographic Controls
	reg va_cfr_g11_`subject'_peer `sch_chars' `dem_chars' ///
		, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
	estimates save estimates/sbac/reg_va_cfr_g11_`subject'_peer_sch_char_dem.ster, replace
	
	
	**** Bivariate
	foreach control_var in `sch_chars' {

		** No Demographic Controls
		reg va_cfr_g11_`subject'_peer `control_var' ///
			, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
		estimates save estimates/sbac/reg_va_cfr_g11_`subject'_peer_`control_var'.ster, replace

		** Demographic Controls
		reg va_cfr_g11_`subject'_peer `control_var' `dem_chars' ///
			, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
		estimates save estimates/sbac/reg_va_cfr_g11_`subject'_peer_`control_var'_dem.ster, replace
	}
	
	
	
	
	**************** Financial Expenditures
	restore, preserve
	foreach v of varlist `expenditure_vars' /*enr_total*/ {
		di "Variable = `v'"
		
		sum `v', d
		xtile `v'_xt = `v', nquantiles(100)
		drop if inlist(`v'_xt, 1, 100)
		sum `v', d
	}
		
	******** No Peer Controls
	**** All
	reg va_cfr_g11_`subject' `expenditures' ///
		, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
	estimates save estimates/sbac/reg_va_cfr_g11_`subject'_finance.ster, replace
	
	
	**** All with Demographic Controls
	reg va_cfr_g11_`subject' `expenditures' `dem_chars' ///
		, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
	estimates save estimates/sbac/reg_va_cfr_g11_`subject'_finance_dem.ster, replace
	
	
	**** Bivariate
	foreach control_var of varlist `expenditures' {
		
		** No Demographic Controls
		reg va_cfr_g11_`subject' `control_var' ///
			, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
		estimates save estimates/sbac/reg_va_cfr_g11_`subject'_`control_var'.ster, replace
		
		** Demographic Controls
		reg va_cfr_g11_`subject' `control_var' `dem_chars' ///
			, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
		estimates save estimates/sbac/reg_va_cfr_g11_`subject'_`control_var'_dem.ster, replace
	}
	
	
	******** Peer Controls
	**** All
	reg va_cfr_g11_`subject'_peer `expenditures' ///
		, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
	estimates save estimates/sbac/reg_va_cfr_g11_`subject'_peer_finance.ster, replace
	
	
	**** All with Demographic Controls
	reg va_cfr_g11_`subject'_peer `expenditures' `dem_chars' ///
		, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
	estimates save estimates/sbac/reg_va_cfr_g11_`subject'_peer_finance_dem.ster, replace
	
	
	**** Bivariate
	foreach control_var of varlist `expenditures' {
		
		** No Demographic Controls
		reg va_cfr_g11_`subject' `control_var' ///
			, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
		estimates save estimates/sbac/reg_va_cfr_g11_`subject'_peer_`control_var'.ster, replace
		
		** Demographic Controls
		reg va_cfr_g11_`subject' `control_var' `dem_chars' ///
			, vce(bootstrap, cluster(cdscode) reps(1000) seed(1984))
		estimates save estimates/sbac/reg_va_cfr_g11_`subject'_peer_`control_var'_dem.ster, replace
	}
	
	restore, not
}


timer off 1
timer list
log close
translate log_files/sbac/reg_va_cfr_sch_char.smcl log_files/sbac/reg_va_cfr_sch_char.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
