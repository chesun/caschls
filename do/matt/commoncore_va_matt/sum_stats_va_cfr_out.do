version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on August 16, 2018 *
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

log using log_files/sbac/sum_stats_va_cfr_out.smcl, replace

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
This do file calculates summary statistics for the school value added on 
long-run outcomes estimates.
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
	x_var	
	)
	order(
	x_var	
	)
	;
#delimit cr
macro list


timer on 1
*****************
* Begin Do File *
*****************
******************************** 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
foreach outcome in enr enr_2year enr_4year {
	use data/sbac/va_g11_`outcome'.dta, clear
	sort school_id year
	xtset school_id year

	* Normalize to have mean zero
	foreach v of varlist va_* {
		sum `v', meanonly
		replace `v' = `v' - r(mean)
	}
	sum va_cfr_g11_`outcome'
	local mean_`outcome' = 0
	local sd_`outcome' : di %4.3f = r(sd)
	
	sum va_cfr_g11_`outcome'_peer
	local mean_`outcome'_peer = 0
	local sd_`outcome'_peer : di %4.3f = r(sd)
	
	foreach subject in ela math {
		sum va_cfr_g11_`outcome'_`subject'
		local mean_`outcome'_`subject' = 0
		local sd_`outcome'_`subject' : di %4.3f = r(sd)
		
		sum va_cfr_g11_`outcome'_`subject'_peer
		local mean_`outcome'_`subject'_peer = 0
		local sd_`outcome'_`subject'_peer : di %4.3f = r(sd)
	}
	
	sum va_cfr_g11_`outcome'_dk
	local mean_`outcome'_dk = 0
	local sd_`outcome'_dk : di %4.3f = r(sd)
	
	sum va_cfr_g11_`outcome'_dk_peer
	local mean_`outcome'_dk_peer = 0
	local sd_`outcome'_dk_peer : di %4.3f = r(sd)
	
	tempfile va_`outcome'
	save `va_`outcome''
}

use `va_enr'
merge 1:1 cdscode year using `va_enr_2year', nogen
merge 1:1 cdscode year using `va_enr_4year', nogen

**************** Kernel Density
******** Overall Value Added
**** No Peer Controls
twoway ///
	(kdensity va_cfr_g11_enr) ///
	(kdensity va_cfr_g11_enr_2year) ///
	(kdensity va_cfr_g11_enr_4year) ///
	, ytitle("Density") xtitle("Value Added") title("Postsecondary Overall Value Added") ///
	legend(label(1 "Enroll Any") label(2 "Enroll 2-Year") label(3 "Enroll 4-Year")) ///
	note("Enroll Any Mean (Standard Deviation) = `mean_enr' (`sd_enr')" ///
	"Enroll 2-Year Mean (Standard Deviation) = `mean_enr_2year' (`sd_enr_2year')" ///
	"Enroll 4-Year Mean (Standard Deviation) = `mean_enr_4year' (`sd_enr_4year')")
graph export figures/sbac/kdensity_va_cfr_g11_enrollment.pdf, replace

**** Peer Controls
twoway ///
	(kdensity va_cfr_g11_enr_peer) ///
	(kdensity va_cfr_g11_enr_2year_peer) ///
	(kdensity va_cfr_g11_enr_4year_peer) ///
	, ytitle("Density") xtitle("Value Added") title("Postsecondary Overall Value Added") ///
	legend(label(1 "Enroll Any") label(2 "Enroll 2-Year") label(3 "Enroll 4-Year")) ///
	note("Enroll Any Mean (Standard Deviation) = `mean_enr_peer' (`sd_enr_peer')" ///
	"Enroll 2-Year Mean (Standard Deviation) = `mean_enr_2year_peer' (`sd_enr_2year_peer')" ///
	"Enroll 4-Year Mean (Standard Deviation) = `mean_enr_4year_peer' (`sd_enr_4year_peer')")
graph export figures/sbac/kdensity_va_cfr_g11_enrollment_peer.pdf, replace




******** Deep Knowledge Value Added
foreach subject in ela math {
	**** No Peer Controls
	twoway ///
		(kdensity va_cfr_g11_enr_`subject') ///
		(kdensity va_cfr_g11_enr_2year_`subject') ///
		(kdensity va_cfr_g11_enr_4year_`subject') ///
		, ytitle("Density") xtitle("Value Added") title("Postsecondary Non-Test Score Value Added") ///
		legend(label(1 "Enroll Any") label(2 "Enroll 2-Year") label(3 "Enroll 4-Year")) ///
		note("Enroll Any Mean (Standard Deviation) = `mean_enr_`subject'' (`sd_enr_`subject'')" ///
		"Enroll 2-Year Mean (Standard Deviation) = `mean_enr_2year_`subject'' (`sd_enr_2year_`subject'')" ///
		"Enroll 4-Year Mean (Standard Deviation) = `mean_enr_4year_`subject'' (`sd_enr_4year_`subject'')")
	graph export figures/sbac/kdensity_va_cfr_g11_enrollment_`subject'.pdf, replace

	**** Peer Controls
	twoway ///
		(kdensity va_cfr_g11_enr_`subject'_peer) ///
		(kdensity va_cfr_g11_enr_2year_`subject'_peer) ///
		(kdensity va_cfr_g11_enr_4year_`subject'_peer) ///
		, ytitle("Density") xtitle("Value Added") title("Postsecondary Non-Test Score Value Added") ///
		legend(label(1 "Enroll Any") label(2 "Enroll 2-Year") label(3 "Enroll 4-Year")) ///
		note("Enroll Any Mean (Standard Deviation) = `mean_`subject'_peer' (`sd_`subject'_peer')" ///
		"Enroll 2-Year Mean (Standard Deviation) = `mean_enr_2year_`subject'_peer' (`sd_enr_2year_`subject'_peer')" ///
		"Enroll 4-Year Mean (Standard Deviation) = `mean_enr_4year_`subject'_peer' (`sd_enr_4year_`subject'_peer')")
	graph export figures/sbac/kdensity_va_cfr_g11_enrollment_`subject'_peer.pdf, replace
}

**** No Peer Controls
twoway ///
	(kdensity va_cfr_g11_enr_dk) ///
	(kdensity va_cfr_g11_enr_2year_dk) ///
	(kdensity va_cfr_g11_enr_4year_dk) ///
	, ytitle("Density") xtitle("Value Added") title("Postsecondary Non-Test Score Value Added") ///
	legend(label(1 "Enroll Any") label(2 "Enroll 2-Year") label(3 "Enroll 4-Year")) ///
	note("Enroll Any Mean (Standard Deviation) = `mean_enr_dk' (`sd_enr_dk')" ///
	"Enroll 2-Year Mean (Standard Deviation) = `mean_enr_2year_dk' (`sd_enr_2year_dk')" ///
	"Enroll 4-Year Mean (Standard Deviation) = `mean_enr_4year_dk' (`sd_enr_4year_dk')")
graph export figures/sbac/kdensity_va_cfr_g11_enrollment_dk.pdf, replace

**** Peer Controls
twoway ///
	(kdensity va_cfr_g11_enr_dk_peer) ///
	(kdensity va_cfr_g11_enr_2year_dk_peer) ///
	(kdensity va_cfr_g11_enr_4year_dk_peer) ///
	, ytitle("Density") xtitle("Value Added") title("Postsecondary Non-Test Score Value Added") ///
	legend(label(1 "Enroll Any") label(2 "Enroll 2-Year") label(3 "Enroll 4-Year")) ///
	note("Enroll Any Mean (Standard Deviation) = `mean_dk_peer' (`sd_dk_peer')" ///
	"Enroll 2-Year Mean (Standard Deviation) = `mean_enr_2year_dk_peer' (`sd_enr_2year_dk_peer')" ///
	"Enroll 4-Year Mean (Standard Deviation) = `mean_enr_4year_dk_peer' (`sd_enr_4year_dk_peer')")
graph export figures/sbac/kdensity_va_cfr_g11_enrollment_dk_peer.pdf, replace




foreach outcome in enr enr_2year enr_4year {
	**************** Kernel Density
	use data/sbac/va_g11_`outcome'.dta, clear
	sort school_id year
	xtset school_id year

	* Normalize to have mean zero
	foreach v of varlist va_* {
		sum `v', meanonly
		replace `v' = `v' - r(mean)
	}

	******** Overall Value Added
	**** No Peer Controls
	sum va_cfr_g11_`outcome'
	local mean = 0
	local sd : di %4.3f = r(sd)

	twoway ///
		(kdensity va_cfr_g11_`outcome') ///
		, ytitle("Density") xtitle("Value Added") title("``outcome'_str'") ///
		note("Mean (Standard Deviation) = `mean' (`sd')")
	graph export figures/sbac/kdensity_va_cfr_g11_`outcome'.pdf, replace

	**** Peer Controls
	sum va_cfr_g11_`outcome'_peer
	local mean = 0
	local sd : di %4.3f = r(sd)

	twoway ///
		(kdensity va_cfr_g11_`outcome'_peer) ///
		, ytitle("Density") xtitle("Value Added") title("``outcome'_str'") ///
		note("Mean (Standard Deviation) = `mean' (`sd')")
	graph export figures/sbac/kdensity_va_cfr_g11_`outcome'_peer.pdf, replace
	
	
	
	
	******** Specification Test
	**** No Peer Controls
	estimates use estimates/sbac/spec_test_va_cfr_g11_`outcome'.ster
	eststo spec_g11_`outcome'
	test _b[va_cfr_g11_`outcome'] = 1
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`outcome'
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`outcome']
	local std_err : di %4.3f _se[va_cfr_g11_`outcome']
	binscatter g11_`outcome'_r va_cfr_g11_`outcome' ///
		[aw = n_g11_`outcome'] ///
		, ytitle("``outcome'_str'") xtitle("Value Added") title("``outcome'_str' Specification Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/spec_test_va_cfr_g11_`outcome'.pdf, replace


	**** Peer Controls
	estimates use estimates/sbac/spec_test_va_cfr_g11_`outcome'_peer.ster
	eststo spec_g11_`outcome'_peer
	test _b[va_cfr_g11_`outcome'_peer] = 1
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`outcome'_peer
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`outcome'_peer]
	local std_err : di %4.3f _se[va_cfr_g11_`outcome'_peer]
	binscatter g11_`outcome'_r_peer va_cfr_g11_`outcome'_peer ///
		[aw = n_g11_`outcome'] ///
		, ytitle("``outcome'_str'") xtitle("Value Added") title("``outcome'_str' Specification Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/spec_test_va_cfr_g11_`outcome'_peer.pdf, replace
	
	
	
	
	******** Deep Knowledge Value Added
	foreach subject in ela math {
		merge m:1 cdscode year using data/sbac/va_g11_`subject'.dta, nogen
		sort school_id year
		xtset school_id year
		
		**** No Peer Controls
		sum va_cfr_g11_`outcome'_`subject'
		local mean = 0
		local sd : di %4.3f = r(sd)

		twoway ///
			(kdensity va_cfr_g11_`outcome'_`subject') ///
			, ytitle("Density") xtitle("Value Added") title("``outcome'_str'") ///
			note("Mean (Standard Deviation) = `mean' (`sd')")
		graph export figures/sbac/kdensity_va_cfr_g11_`outcome'_`subject'.pdf, replace

		**** Peer Controls
		sum va_cfr_g11_`outcome'_`subject'_peer
		local mean = 0
		local sd : di %4.3f = r(sd)

		twoway ///
			(kdensity va_cfr_g11_`outcome'_`subject'_peer) ///
			, ytitle("Density") xtitle("Value Added") title("``outcome'_str'") ///
			note("Mean (Standard Deviation) = `mean' (`sd')")
		graph export figures/sbac/kdensity_va_cfr_g11_`outcome'_`subject'_peer.pdf, replace
		
		
		
		
		******** Specification Test
		**** No Peer Controls
		estimates use estimates/sbac/spec_test_va_cfr_g11_`outcome'_`subject'.ster
		eststo spec_g11_`outcome'_`subject'
		test _b[va_cfr_g11_`outcome'_`subject'] = 1
		matrix test_p = r(p)
		matrix rownames test_p = pvalue
		matrix colnames test_p = va_cfr_g11_`outcome'_`subject'
		estadd matrix test_p = test_p

		local slope : di %5.3f _b[va_cfr_g11_`outcome'_`subject']
		local std_err : di %4.3f _se[va_cfr_g11_`outcome'_`subject']
		binscatter g11_`outcome'_`subject'_r va_cfr_g11_`outcome'_`subject' ///
			[aw = n_g11_`outcome'_`subject'] ///
			, ytitle("``outcome'_str'") xtitle("Value Added") title("``outcome'_str' Specification Test") ///
			yline(0) xline(0) ///
			yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
			note("Slope (Standard Error) = `slope' (`std_err')")
		graph export figures/sbac/spec_test_va_cfr_g11_`outcome'_`subject'.pdf, replace


		**** Peer Controls
		/*estimates use estimates/sbac/spec_test_va_cfr_g11_`outcome'_`subject'_peer.ster
		eststo spec_g11_`outcome'_`subject'_peer
		test _b[va_cfr_g11_`outcome'_`subject'_peer] = 1
		matrix test_p = r(p)
		matrix rownames test_p = pvalue
		matrix colnames test_p = va_cfr_g11_`outcome'_`subject'_peer
		estadd matrix test_p = test_p

		local slope : di %5.3f _b[va_cfr_g11_`outcome'_`subject'_peer]
		local std_err : di %4.3f _se[va_cfr_g11_`outcome'_`subject'_peer]
		binscatter g11_`outcome'_`subject'_r_peer va_cfr_g11_`outcome'_`subject'_peer ///
			[aw = n_g11_`outcome'_`subject'] ///
			, ytitle("``outcome'_str'") xtitle("Value Added") title("``outcome'_str' Specification Test") ///
			yline(0) xline(0) ///
			yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
			note("Slope (Standard Error) = `slope' (`std_err')")
		graph export figures/sbac/spec_test_va_cfr_g11_`outcome'_`subject'_peer.pdf, replace*/
	}
	
	
	
	
		
	**** No Peer Controls
	sum va_cfr_g11_`outcome'_dk
	local mean = 0
	local sd : di %4.3f = r(sd)

	twoway ///
		(kdensity va_cfr_g11_`outcome'_dk) ///
		, ytitle("Density") xtitle("Value Added") title("``outcome'_str'") ///
		note("Mean (Standard Deviation) = `mean' (`sd')")
	graph export figures/sbac/kdensity_va_cfr_g11_`outcome'_dk.pdf, replace

	**** Peer Controls
	sum va_cfr_g11_`outcome'_dk_peer
	local mean = 0
	local sd : di %4.3f = r(sd)

	twoway ///
		(kdensity va_cfr_g11_`outcome'_dk_peer) ///
		, ytitle("Density") xtitle("Value Added") title("``outcome'_str'") ///
		note("Mean (Standard Deviation) = `mean' (`sd')")
	graph export figures/sbac/kdensity_va_cfr_g11_`outcome'_dk_peer.pdf, replace
	
	
	
	
	******** Specification Test
	**** No Peer Controls
	estimates use estimates/sbac/spec_test_va_cfr_g11_`outcome'_dk.ster
	eststo spec_g11_`outcome'_dk
	test _b[va_cfr_g11_`outcome'_dk] = 1
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`outcome'_dk
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`outcome'_dk]
	local std_err : di %4.3f _se[va_cfr_g11_`outcome'_dk]
	binscatter g11_`outcome'_dk_r va_cfr_g11_`outcome'_dk ///
		[aw = n_g11_`outcome'_dk] ///
		, ytitle("``outcome'_str'") xtitle("Value Added") title("``outcome'_str' Specification Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/spec_test_va_cfr_g11_`outcome'_dk.pdf, replace


	**** Peer Controls
	estimates use estimates/sbac/spec_test_va_cfr_g11_`outcome'_dk_peer.ster
	eststo spec_g11_`outcome'_dk_peer
	test _b[va_cfr_g11_`outcome'_dk_peer] = 1
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`outcome'_dk_peer
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`outcome'_dk_peer]
	local std_err : di %4.3f _se[va_cfr_g11_`outcome'_dk_peer]
	binscatter g11_`outcome'_dk_r_peer va_cfr_g11_`outcome'_dk_peer ///
		[aw = n_g11_`outcome'_dk] ///
		, ytitle("``outcome'_str'") xtitle("Value Added") title("``outcome'_str' Specification Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/spec_test_va_cfr_g11_`outcome'_dk_peer.pdf, replace
	
	
	
	
	
	
	
	
	**************** Tables
	******** No Peer Controls
	esttab ///
		spec_g11_`outcome' ///
		spec_g11_`outcome'_ela ///
		spec_g11_`outcome'_math ///
		spec_g11_`outcome'_dk ///
		using tables/sbac/test_va_cfr_g11_`outcome'.tex ///
		, replace `esttab_keep' ///
		cells(b(fmt(%5.3f) /*star*/ pvalue(test_p)) se(fmt(%4.3f) par) ci(fmt(%5.3f) par([ , ]))) ///
		/*star(* 0.1 ** 0.05 *** 0.01)*/ nostar noobs compress label interaction(\times) ///
		booktabs substitute(\_ _) ///
		fragment nomtitles nonumbers nonotes nolines nogaps collabels(none) ///
		rename( ///
			va_cfr_g11_`outcome' "x_var" ///
			va_cfr_g11_`outcome'_ela "x_var" ///
			va_cfr_g11_`outcome'_math "x_var" ///
			va_cfr_g11_`outcome'_dk "x_var" ///
		) ///
		varlabels(x_var "VA Specification Test: ``outcome'_str'")


	******** Peer Controls
	/*esttab ///
		spec_g11_`outcome'_peer ///
		spec_g11_`outcome'_ela_peer ///
		spec_g11_`outcome'_math_peer ///
		spec_g11_`outcome'_dk_peer ///
		using tables/sbac/test_va_cfr_g11_`outcome'_peer.tex ///
		, replace `esttab_keep' ///
		cells(b(fmt(%5.3f) /*star*/ pvalue(test_p)) se(fmt(%4.3f) par) ci(fmt(%5.3f) par([ , ]))) ///
		/*star(* 0.1 ** 0.05 *** 0.01)*/ nostar noobs compress label interaction(\times) ///
		booktabs substitute(\_ _) ///
		fragment nomtitles nonumbers nonotes nolines nogaps collabels(none) ///
		rename( ///
			va_cfr_g11_`outcome'_peer "x_var" ///
			va_cfr_g11_`outcome'_ela_peer "x_var" ///
			va_cfr_g11_`outcome'_math_peer "x_var" ///
			va_cfr_g11_`outcome'_dk_peer "x_var" ///
		) ///
		varlabels(x_var "VA Specification Test: ``outcome'_str'")*/
	
	
	
	
	
	
	
	
	**************** Scatter Plots
	foreach subject in ela math {
		merge 1:1 cdscode year using data/sbac/va_g11_`subject'.dta, nogen
		sum va_cfr_g11_`subject'
		replace va_cfr_g11_`subject' = va_cfr_g11_`subject' / r(sd)
		
		******** Overall Value Added
		reg va_cfr_g11_`outcome' va_cfr_g11_`subject' ///
			[aw = n_g11_`outcome' + n_g11_`subject'] ///
			, cluster(school_id)
		local slope : di %5.3f = _b[va_cfr_g11_`subject']
		local se : di %4.3f = _se[va_cfr_g11_`subject']
		local r2 : di %4.3f = e(r2)
		
		twoway ///
			(scatter va_cfr_g11_`outcome' va_cfr_g11_`subject' ///
				, msymbol(oh)) ///
			(lfit va_cfr_g11_`outcome' va_cfr_g11_`subject' ///
				[aw = n_g11_`outcome' + n_g11_`subject']) ///
			, ytitle("``outcome'_str'") xtitle("SBAC 11th Grade ``subject'_str'") ///
			yline(0) xline(0) ///
			legend(off) ///
			note("Slope (Standard Error) = `slope' (`se')" ///
				"R{superscript:2} = `r2'")
		graph export figures/sbac/scatter_va_cfr_g11_`outcome'_`subject'.pdf, replace
		
		
		
		
		******** Deep Knowledge Value Added
		reg va_cfr_g11_`outcome'_`subject' va_cfr_g11_`subject' ///
			[aw = n_g11_`outcome'_`subject' + n_g11_`subject'] ///
			, cluster(school_id)
		local slope : di %5.3f = _b[va_cfr_g11_`subject']
		local se : di %4.3f = _se[va_cfr_g11_`subject']
		local r2 : di %4.3f = e(r2)
		
		twoway ///
			(scatter va_cfr_g11_`outcome'_`subject' va_cfr_g11_`subject' ///
				, msymbol(oh)) ///
			(lfit va_cfr_g11_`outcome'_`subject' va_cfr_g11_`subject' ///
				[aw = n_g11_`outcome'_`subject' + n_g11_`subject']) ///
			, ytitle("Long-Run ``outcome'_str'") xtitle("SBAC 11th Grade ``subject'_str'") ///
			yline(0) xline(0) ///
			legend(off) ///
			note("Slope (Standard Error) = `slope' (`se')" ///
				"R{superscript:2} = `r2'")
		graph export figures/sbac/scatter_va_cfr_g11_`outcome'_`subject'_`subject'.pdf, replace
		
		
		reg g11_`outcome'_`subject'_r sbac_g11_`subject'_r ///
			[aw = n_g11_`outcome'_`subject' + n_g11_`subject'] ///
			, cluster(school_id)
		local slope : di %5.3f = _b[sbac_g11_`subject'_r]
		local se : di %4.3f = _se[sbac_g11_`subject'_r]
		local r2 : di %4.3f = e(r2)
		
		twoway ///
			(scatter g11_`outcome'_`subject'_r sbac_g11_`subject'_r ///
				, msymbol(oh)) ///
			(lfit g11_`outcome'_`subject'_r sbac_g11_`subject'_r ///
				[aw = n_g11_`outcome'_`subject' + n_g11_`subject']) ///
			, ytitle("Long-Run ``outcome'_str'") xtitle("SBAC 11th Grade ``subject'_str'") ///
			yline(0) xline(0) ///
			legend(off) ///
			note("Slope (Standard Error) = `slope' (`se')" ///
				"R{superscript:2} = `r2'")
		graph export figures/sbac/scatter_g11_`outcome'_`subject'_`subject'.pdf, replace
	}
}


timer off 1
timer list
log close
translate log_files/sbac/sum_stats_va_cfr_out.smcl log_files/sbac/sum_stats_va_cfr_out.log, replace

if c(hostname)=="sapper" {
	exit, STATA clear
}
