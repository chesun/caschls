version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on May 23, 2018 *
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

log using log_files/sbac/reg_out_va_cfr_tab.smcl, replace

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
This do file creates tables for the regressions of outcomes on school value added.
*/


**********
* Macros *
**********
#delimit ;

local esttab_reg
	b(%12.3gc) se(%12.3gc)
	/*star(* 0.1 ** 0.05 *** 0.01)*/ nostar
	;
local esttab_sum_stats
	main(mean %12.3gc) aux(sd %12.3gc)
	brackets
	nomtitles nonumbers nonotes
	;
local esttab_tab_stat
	cells(mean(fmt(%12.3gc)) sd(fmt(%12.3gc) par([ ])) count(fmt(%12.3gc) par({ })))
	nomtitles nonumbers nonotes collabels(none)
	;
local esttab_scalars
	scalars(
	"ymean Y Mean"
	"N Observations"
	"r2 $ R^2 $"
	)
	sfmt(
	%12.3gc
	%12.3gc
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
local estab_mgroups
	mgroups(""
	, pattern()
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
	;
local esttab_keep
	keep(
		va_cfr_g*_*
	)
	order(
		va_cfr_g*_*
	)
	;
#delimit cr
macro list


timer on 1
*****************
* Begin Do File *
*****************
gen enr_ontime = .
label var enr_ontime "Enrolled"

gen enr_ontime_2year = .
label var enr_ontime_2year "Enrolled 2-Year"

gen enr_ontime_4year = .
label var enr_ontime_4year "Enrolled 4-Year"

gen csu_accepted = .
label var csu_accepted "CSU Accepted"

gen csu_eng_remediation = .
label var csu_eng_remediation "CSU Eng. Rem."

gen csu_math_remediation = .
label var csu_math_remediation "CSU Math Rem."

gen csu_major_stem = .
label var csu_major_stem "CSU STEM"




******************************** 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
**** Regress postsecondary outcomes on value added
foreach yvar of varlist enr_ontime enr_ontime_2year enr_ontime_4year {
	di "Y Variable = `yvar'"
	
	**** Enrollment
	** No Peer Controls
	* No TFX
	foreach subject in ela math {
		di "Subject = `subject'"
		
		estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'.ster
		eststo `yvar'_`subject'
	}
	
	/*estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_dk.ster
	eststo `yvar'_dk*/
	
	esttab * using tables/sbac/reg_`yvar'_va_cfr_g11.tex ///
		, `esttab_reg' `esttab_scalars' `esttab_layout' `esttab_keep' ///
		coeflabel( ///
			va_cfr_g11_ela "ELA VA" ///
			va_cfr_g11_math "Math VA" ///
		)


	** Peer Controls
	* No TFX
	foreach subject in ela math {
		di "Subject = `subject'"
		
		estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'_peer.ster
		eststo `yvar'_`subject'_peer
	}
	
	/*estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_dk_peer.ster
	eststo `yvar'_dk_peer*/
	
	esttab * using tables/sbac/reg_`yvar'_va_cfr_g11_peer.tex ///
		, `esttab_reg' `esttab_scalars' `esttab_layout' `esttab_keep' ///
		coeflabel( ///
			va_cfr_g11_ela "ELA VA" ///
			va_cfr_g11_math "Math VA" ///
		)
}

esttab enr_ontime_ela enr_ontime_math /*enr_ontime_dk*/ enr_ontime_2year_ela enr_ontime_2year_math /*enr_ontime_2year_dk*/ enr_ontime_4year_ela enr_ontime_4year_math /*enr_ontime_4year_dk*/ using tables/sbac/reg_enr_va_cfr_g11.tex ///
	, `esttab_reg' `esttab_scalars' `esttab_layout' `esttab_keep' ///
	coeflabel( ///
		va_cfr_g11_ela "ELA VA" ///
		va_cfr_g11_math "Math VA" ///
	)
eststo clear








**** Regress CCC conditional outcomes on value added
/*foreach yvar of varlist  {
	di "Y Variable = `yvar'"
	
	** No Peer Controls
	* No TFX
	foreach subject in ela math {
		di "Subject = `subject'"
		
		estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'.ster
		eststo `yvar'_`subject'
	}
	
	/*estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_dk.ster
	eststo `yvar'_dk*/
	
	esttab * using tables/sbac/reg_`yvar'_va_cfr_g11.tex ///
		, `esttab_reg' `esttab_scalars' `esttab_layout' `esttab_keep' ///
		coeflabel( ///
			va_cfr_g11_ela "ELA VA" ///
			va_cfr_g11_math "Math VA" ///
		)


	** Peer Controls
	* No TFX
	foreach subject in ela math {
		di "Subject = `subject'"
		
		estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'_peer.ster
		eststo `yvar'_`subject'_peer
	}
	
	/*estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_dk_peer.ster
	eststo `yvar'_dk_peer*/
	
	esttab * using tables/sbac/reg_`yvar'_va_cfr_g11_peer.tex ///
		, `esttab_reg' `esttab_scalars' `esttab_layout' `esttab_keep' ///
		coeflabel( ///
			va_cfr_g11_ela "ELA VA" ///
			va_cfr_g11_math "Math VA" ///
		)
}

esttab  using tables/sbac/reg_ccc_va_cfr_g11.tex ///
	, `esttab_reg' `esttab_scalars' `esttab_layout' `esttab_keep' ///
	coeflabel( ///
		va_cfr_g11_ela "ELA VA" ///
		va_cfr_g11_math "Math VA" ///
	)
eststo clear*/








**** Regress CSU conditional outcomes on value added
/*foreach yvar of varlist  {
	di "Y Variable = `yvar'"
	
	** No Peer Controls
	* No TFX
	foreach subject in ela math {
		di "Subject = `subject'"
		
		estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'.ster
		eststo `yvar'_`subject'
	}
	
	/*estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_dk.ster
	eststo `yvar'_dk*/
	
	esttab * using tables/sbac/reg_`yvar'_va_cfr_g11.tex ///
		, `esttab_reg' `esttab_scalars' `esttab_layout' `esttab_keep' ///
		coeflabel( ///
			va_cfr_g11_ela "ELA VA" ///
			va_cfr_g11_math "Math VA" ///
		)


	** Peer Controls
	* No TFX
	foreach subject in ela math {
		di "Subject = `subject'"
		
		estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_`subject'_peer.ster
		eststo `yvar'_`subject'_peer
	}
	
	/*estimates use estimates/sbac/reg_`yvar'_va_cfr_g11_dk_peer.ster
	eststo `yvar'_dk_peer*/
	
	esttab * using tables/sbac/reg_`yvar'_va_cfr_g11_peer.tex ///
		, `esttab_reg' `esttab_scalars' `esttab_layout' `esttab_keep' ///
		coeflabel( ///
			va_cfr_g11_ela "ELA VA" ///
			va_cfr_g11_math "Math VA" ///
		)
}

esttab  using tables/sbac/reg_csu_va_cfr_g11.tex ///
	, `esttab_reg' `esttab_scalars' `esttab_layout' `esttab_keep' ///
	coeflabel( ///
		va_cfr_g11_ela "ELA VA" ///
		va_cfr_g11_math "Math VA" ///
	)
eststo clear*/


timer off 1
timer list
log close
translate log_files/sbac/reg_out_va_cfr_tab.smcl log_files/sbac/reg_out_va_cfr_tab.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
