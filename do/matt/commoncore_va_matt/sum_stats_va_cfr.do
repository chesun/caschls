version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on May 8, 2018 *
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

log using log_files/sbac/sum_stats_va_cfr.smcl, replace

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
This file calculates summary statistics for the value added estimates for the 
SBAC using the CFR methodology.
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
******************************** 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
**************** Kernel Density ELA/Math
foreach subject in ela math {
	use data/sbac/va_g11_`subject'.dta, clear
	sort school_id year
	xtset school_id year

	* Normalize to have mean zero
	foreach v of varlist va_* {
		sum `v', meanonly
		replace `v' = `v' - r(mean)
	}
	
	sum va_cfr_g11_`subject'
	local mean_`subject' = 0
	local sd_`subject' : di %4.3f = r(sd)
	
	sum va_cfr_g11_`subject'_peer
	local mean_`subject'_peer = 0
	local sd_`subject'_peer : di %4.3f = r(sd)
	
	tempfile va_`subject'
	save `va_`subject''
}

use `va_ela'
merge 1:1 cdscode year using `va_math', nogen

**** No Peer Controls
twoway ///
	(kdensity va_cfr_g11_ela) ///
	(kdensity va_cfr_g11_math) ///
	, ytitle("Density") xtitle("Value Added") title("11th Grade Test Score Value Added") ///
	legend(label(1 "ELA") label(2 "Math")) ///
	note("Mean (Standard Deviation) = `mean_ela' (`sd_ela')" ///
	"Mean (Standard Deviation) = `mean_math' (`sd_math')")
graph export figures/sbac/kdensity_va_cfr_g11.pdf, replace

**** Peer Controls
twoway ///
	(kdensity va_cfr_g11_ela_peer) ///
	(kdensity va_cfr_g11_math_peer) ///
	, ytitle("Density") xtitle("Value Added") title("11th Grade Test Score Value Added") ///
	legend(label(1 "ELA") label(2 "Math")) ///
	note("Mean (Standard Deviation) = `mean_ela_peer' (`sd_ela_peer')" ///
	"Mean (Standard Deviation) = `mean_math_peer' (`sd_math_peer')")
graph export figures/sbac/kdensity_va_cfr_g11_peer.pdf, replace








**************** Kernel Density and Specification Test
foreach subject in ela math {
	use data/sbac/va_g11_`subject'.dta, clear
	sort school_id year
	xtset school_id year

	* Normalize to have mean zero
	foreach v of varlist va_* {
		sum `v', meanonly
		replace `v' = `v' - r(mean)
	}

	**************** Kernel Density
	**** No Peer Controls
	sum va_cfr_g11_`subject'
	local mean = 0
	local sd : di %4.3f = r(sd)
	corr sbac_g11_`subject'_r F.sbac_g11_`subject'_r ///
		[aw = n_g11_`subject' + F.n_g11_`subject'] ///
		, cov
	di "sigma^2(`subject' test score VA) = " r(cov_12)
	di "sigma(`subject' test score VA) = " sqrt(r(cov_12))

	twoway ///
		(kdensity va_cfr_g11_`subject') ///
		, ytitle("Density") xtitle("Value Added") title("11th Grade ``subject'_str' Value Added") ///
		note("Mean (Standard Deviation) = `mean' (`sd')")
	graph export figures/sbac/kdensity_va_cfr_g11_`subject'.pdf, replace

	**** Peer Controls
	sum va_cfr_g11_`subject'_peer
	local mean = 0
	local sd : di %4.3f = r(sd)
	corr sbac_g11_`subject'_r_peer F.sbac_g11_`subject'_r_peer ///
		[aw = n_g11_`subject' + F.n_g11_`subject'] ///
		, cov
	di "sigma^2(`subject' test score VA) = " r(cov_12)
	di "sigma(`subject' test score VA) = " sqrt(r(cov_12))

	twoway ///
		(kdensity va_cfr_g11_`subject'_peer) ///
		, ytitle("Density") xtitle("Value Added") title("11th Grade ``subject'_str' Value Added") ///
		note("Mean (Standard Deviation) = `mean' (`sd')")
	graph export figures/sbac/kdensity_va_cfr_g11_`subject'_peer.pdf, replace
	
	
	
	
	**************** Specification Test
	******** No Peer Controls
	estimates use estimates/sbac/spec_test_va_cfr_g11_`subject'.ster
	eststo spec_g11_`subject'
	test _b[va_cfr_g11_`subject'] = 1
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`subject'
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`subject']
	local std_err : di %4.3f _se[va_cfr_g11_`subject']
	binscatter sbac_g11_`subject'_r va_cfr_g11_`subject' ///
		[aw = n_g11_`subject'] ///
		, ytitle("11th Grade Score") xtitle("Value Added") title("11th Grade ``subject'_str' Specification Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/spec_test_va_cfr_g11_`subject'.pdf, replace


	******** Peer Controls
	estimates use estimates/sbac/spec_test_va_cfr_g11_`subject'_peer.ster
	eststo spec_g11_`subject'_peer
	test _b[va_cfr_g11_`subject'_peer] = 1
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`subject'_peer
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`subject'_peer]
	local std_err : di %4.3f _se[va_cfr_g11_`subject'_peer]
	binscatter sbac_g11_`subject'_r_peer va_cfr_g11_`subject'_peer ///
		[aw = n_g11_`subject'] ///
		, ytitle("11th Grade Score") xtitle("Value Added") title("11th Grade ``subject'_str' Specification Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/spec_test_va_cfr_g11_`subject'_peer.pdf, replace
}




**************** ELA/Math
******** No Peer Controls
esttab ///
	spec_g11_ela ///
	spec_g11_math ///
	using tables/sbac/test_va_cfr_g11.tex ///
	, replace `esttab_keep' ///
	cells(b(fmt(%5.3f) /*star*/ pvalue(test_p)) se(fmt(%4.3f) par) ci(fmt(%5.3f) par([ , ]))) ///
	/*star(* 0.1 ** 0.05 *** 0.01)*/ nostar noobs compress label interaction(\times) ///
	booktabs substitute(\_ _) ///
	fragment nomtitles nonumbers nonotes nolines nogaps collabels(none) ///
	rename( ///
		va_cfr_g11_ela "x_var" ///
		va_cfr_g11_math "x_var" ///
	) ///
	varlabels(x_var "VA Specification Test: 11th Grade Score")


******** Peer Controls
esttab ///
	spec_g11_ela_peer ///
	spec_g11_math_peer ///
	using tables/sbac/test_va_cfr_g11_peer.tex ///
	, replace `esttab_keep' ///
	cells(b(fmt(%5.3f) /*star*/ pvalue(test_p)) se(fmt(%4.3f) par) ci(fmt(%5.3f) par([ , ]))) ///
	/*star(* 0.1 ** 0.05 *** 0.01)*/ nostar noobs compress label interaction(\times) ///
	booktabs substitute(\_ _) ///
	fragment nomtitles nonumbers nonotes nolines nogaps collabels(none) ///
	rename( ///
		va_cfr_g11_ela_peer "x_var" ///
		va_cfr_g11_math_peer "x_var" ///
	) ///
	varlabels(x_var "VA Specification Test: 11th Grade Score")


timer off 1
timer list
log close
translate log_files/sbac/sum_stats_va_cfr.smcl log_files/sbac/sum_stats_va_cfr.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
