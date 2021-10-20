version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on June 11, 2020 *
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

log using log_files/sbac/sum_stats_va_cfr_out_forecast_bias.smcl, replace

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
This do file calculates summary statistics for the school value added on long-run 
outcomes forecast bias tests.
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
**************** Four Grade Prior Test Score Forecast Bias Test
foreach outcome in enr enr_2year enr_4year {
	use data/sbac/bias_va_g11_`outcome'_L4_cst_ela_z_score.dta, clear

	* Normalize to have mean zero
	foreach v of varlist va_* {
		sum `v', meanonly
		replace `v' = `v' - r(mean)
	}

	**************** Binscatter
	******** No Peer Controls
	estimates use estimates/sbac/bias_test_va_cfr_g11_`outcome'_L4_cst_ela_z_score.ster
	eststo bias_g11_`outcome'
	test _b[va_cfr_g11_`outcome'] = 0
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`outcome'
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`outcome']
	local std_err : di %4.3f _se[va_cfr_g11_`outcome']
	binscatter g11_`outcome'_r_d va_cfr_g11_`outcome' ///
		[aw = n_g11_`outcome'] ///
		, ytitle("Predicted ``outcome'_str' using 7th Grade ELA Score") xtitle("Value Added") title("11th Grade ``outcome'_str' Forecast Bias Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/bias_test_va_cfr_g11_`outcome'_L4_cst_ela_z_score.pdf, replace


	******** Peer Controls
	/*estimates use estimates/sbac/bias_test_va_cfr_g11_`outcome'_L4_cst_ela_z_score_peer.ster
	eststo bias_g11_`outcome'_peer
	test _b[va_cfr_g11_`outcome'_peer] = 0
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`outcome'_peer
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`outcome'_peer]
	local std_err : di %4.3f _se[va_cfr_g11_`outcome'_peer]
	binscatter g11_`outcome'_r_d_peer va_cfr_g11_`outcome'_peer ///
		[aw = n_g11_`outcome'] ///
		, ytitle("Predicted ``outcome'_str' using 7th Grade ELA Score") xtitle("Value Added") title("11th Grade ``outcome'_str' Forecast Bias Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/bias_test_va_cfr_g11_`outcome'_L4_cst_ela_z_score_peer.pdf, replace*/
	
	
	
	
	******** Deep Knowledge Value Added
	foreach subject in ela math {
		merge 1:1 cdscode year using data/sbac/bias_va_g11_`subject'_L4_cst_ela_z_score.dta, nogen
		
		******** No Peer Controls
		estimates use estimates/sbac/bias_test_va_cfr_g11_`outcome'_`subject'_L4_cst_ela_z_score.ster
		eststo bias_g11_`outcome'_`subject'
		test _b[va_cfr_g11_`outcome'_`subject'] = 0
		matrix test_p = r(p)
		matrix rownames test_p = pvalue
		matrix colnames test_p = va_cfr_g11_`outcome'_`subject'
		estadd matrix test_p = test_p

		local slope : di %5.3f _b[va_cfr_g11_`outcome'_`subject']
		local std_err : di %4.3f _se[va_cfr_g11_`outcome'_`subject']
		binscatter g11_`outcome'_`subject'_r_d va_cfr_g11_`outcome'_`subject' ///
			[aw = n_g11_`outcome'_`subject'] ///
			, ytitle("Predicted ``outcome'_str' using 7th Grade ELA Score") xtitle("Value Added") title("11th Grade ``outcome'_str' Forecast Bias Test") ///
			yline(0) xline(0) ///
			yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
			note("Slope (Standard Error) = `slope' (`std_err')")
		graph export figures/sbac/bias_test_va_cfr_g11_`outcome'_`subject'_L4_cst_ela_z_score.pdf, replace


		******** Peer Controls
		/*estimates use estimates/sbac/bias_test_va_cfr_g11_`outcome'_`subject'_L4_cst_ela_z_score_peer.ster
		eststo bias_g11_`outcome'_`subject'_peer
		test _b[va_cfr_g11_`outcome'_`subject'_peer] = 0
		matrix test_p = r(p)
		matrix rownames test_p = pvalue
		matrix colnames test_p = va_cfr_g11_`outcome'_`subject'_peer
		estadd matrix test_p = test_p

		local slope : di %5.3f _b[va_cfr_g11_`outcome'_`subject'_peer]
		local std_err : di %4.3f _se[va_cfr_g11_`outcome'_`subject'_peer]
		binscatter g11_`outcome'_`subject'_r_d_peer va_cfr_g11_`outcome'_`subject'_peer ///
			[aw = n_g11_`outcome'_`subject'] ///
			, ytitle("Predicted ``outcome'_str' using 7th Grade ELA Score") xtitle("Value Added") title("11th Grade ``outcome'_str' Forecast Bias Test") ///
			yline(0) xline(0) ///
			yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
			note("Slope (Standard Error) = `slope' (`std_err')")
		graph export figures/sbac/bias_test_va_cfr_g11_`outcome'_`subject'_L4_cst_ela_z_score_peer.pdf, replace*/
	}
	
	
	
		
	******** No Peer Controls
	estimates use estimates/sbac/bias_test_va_cfr_g11_`outcome'_dk_L4_cst_ela_z_score.ster
	eststo bias_g11_`outcome'_dk
	test _b[va_cfr_g11_`outcome'_dk] = 0
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`outcome'_dk
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`outcome'_dk]
	local std_err : di %4.3f _se[va_cfr_g11_`outcome'_dk]
	binscatter g11_`outcome'_dk_r_d va_cfr_g11_`outcome'_dk ///
		[aw = n_g11_`outcome'_dk] ///
		, ytitle("Predicted ``outcome'_str' using 7th Grade ELA Score") xtitle("Value Added") title("11th Grade ``outcome'_str' Forecast Bias Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/bias_test_va_cfr_g11_`outcome'_dk_L4_cst_ela_z_score.pdf, replace


	******** Peer Controls
	/*estimates use estimates/sbac/bias_test_va_cfr_g11_`outcome'_dk_L4_cst_ela_z_score_peer.ster
	eststo bias_g11_`outcome'_dk_peer
	test _b[va_cfr_g11_`outcome'_dk_peer] = 0
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`outcome'_dk_peer
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`outcome'_dk_peer]
	local std_err : di %4.3f _se[va_cfr_g11_`outcome'_dk_peer]
	binscatter g11_`outcome'_dk_r_d_peer va_cfr_g11_`outcome'_dk_peer ///
		[aw = n_g11_`outcome'_dk] ///
		, ytitle("Predicted ``outcome'_str' using 7th Grade ELA Score") xtitle("Value Added") title("11th Grade ``outcome'_str' Forecast Bias Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/bias_test_va_cfr_g11_`outcome'_dk_L4_cst_ela_z_score_peer.pdf, replace*/
	
	
	
	
	**************** Tables
	******** No Peer Controls
	esttab ///
		bias_g11_`outcome' ///
		bias_g11_`outcome'_ela ///
		bias_g11_`outcome'_math ///
		bias_g11_`outcome'_dk ///
		using tables/sbac/test_va_cfr_g11_`outcome'.tex ///
		, append `esttab_keep' ///
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
		varlabels(x_var "VA Forecast Bias Test: Predicted Score using 7th Grade ELA Score")


	******** Peer Controls
	/*esttab ///
		bias_g11_`outcome'_peer ///
		bias_g11_`outcome'_ela_peer ///
		bias_g11_`outcome'_math_peer ///
		bias_g11_`outcome'_dk_peer ///
		using tables/sbac/test_va_cfr_g11_`outcome'_peer.tex ///
		, append `esttab_keep' ///
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
		varlabels(x_var "VA Forecast Bias Test: Predicted Score using 7th Grade ELA Score")*/

	eststo clear
}
















**************** Census Tract Forecast Bias Test
foreach outcome in enr enr_2year enr_4year {
	use data/sbac/bias_va_g11_`outcome'_census.dta, clear

	* Normalize to have mean zero
	foreach v of varlist va_* {
		sum `v', meanonly
		replace `v' = `v' - r(mean)
	}

	**************** Binscatter
	******** No Peer Controls
	estimates use estimates/sbac/bias_test_va_cfr_g11_`outcome'_census.ster
	eststo bias_g11_`outcome'
	test _b[va_cfr_g11_`outcome'] = 0
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`outcome'
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`outcome']
	local std_err : di %4.3f _se[va_cfr_g11_`outcome']
	binscatter g11_`outcome'_r_d va_cfr_g11_`outcome' ///
		[aw = n_g11_`outcome'] ///
		, ytitle("Predicted ``outcome'_str' using ACS Census Tract Demographics") xtitle("Value Added") title("11th Grade ``outcome'_str' Forecast Bias Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/bias_test_va_cfr_g11_`outcome'_census.pdf, replace


	******** Peer Controls
	/*estimates use estimates/sbac/bias_test_va_cfr_g11_`outcome'_census_peer.ster
	eststo bias_g11_`outcome'_peer
	test _b[va_cfr_g11_`outcome'_peer] = 0
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`outcome'_peer
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`outcome'_peer]
	local std_err : di %4.3f _se[va_cfr_g11_`outcome'_peer]
	binscatter g11_`outcome'_r_d_peer va_cfr_g11_`outcome'_peer ///
		[aw = n_g11_`outcome'] ///
		, ytitle("Predicted ``outcome'_str' using ACS Census Tract Demographics") xtitle("Value Added") title("11th Grade ``outcome'_str' Forecast Bias Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/bias_test_va_cfr_g11_`outcome'_census_peer.pdf, replace*/
	
	
	
	
	**************** VA rank comparison with excluded observables
	******** No Peer Controls
	bysort year: egen rank_va_cfr_g11_`outcome' = rank(va_cfr_g11_`outcome'), field
	bysort year: egen rank_va_fb_g11_`outcome' = rank(va_fb_g11_`outcome'), field
	corr rank_va_cfr_g11_`outcome' rank_va_fb_g11_`outcome'
	local corr : di %4.3f r(rho)
	twoway ///
		(scatter rank_va_fb_g11_`outcome' rank_va_cfr_g11_`outcome' ///
			, mcolor(navy) msize(tiny)) ///
		(function y = x, range(rank_va_cfr_g11_`outcome')) ///
		, ytitle("VA Rank Controlling for ACS Variables") xtitle("VA Rank") title("VA Rank Comparison") ///
		legend(off) ///
		note("Correlation = `corr'")
	graph export figures/sbac/scatter_rank_va_cfr_g11_`outcome'_census.pdf, replace
	
	
	
	
	******** Deep Knowledge Value Added
	foreach subject in ela math {
		merge 1:1 cdscode year using data/sbac/bias_va_g11_`subject'_census.dta, nogen
		
		******** No Peer Controls
		estimates use estimates/sbac/bias_test_va_cfr_g11_`outcome'_`subject'_census.ster
		eststo bias_g11_`outcome'_`subject'
		test _b[va_cfr_g11_`outcome'_`subject'] = 0
		matrix test_p = r(p)
		matrix rownames test_p = pvalue
		matrix colnames test_p = va_cfr_g11_`outcome'_`subject'
		estadd matrix test_p = test_p

		local slope : di %5.3f _b[va_cfr_g11_`outcome'_`subject']
		local std_err : di %4.3f _se[va_cfr_g11_`outcome'_`subject']
		binscatter g11_`outcome'_`subject'_r_d va_cfr_g11_`outcome'_`subject' ///
			[aw = n_g11_`outcome'_`subject'] ///
			, ytitle("Predicted ``outcome'_str' using ACS Census Tract Demographics") xtitle("Value Added") title("11th Grade ``outcome'_str' Forecast Bias Test") ///
			yline(0) xline(0) ///
			yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
			note("Slope (Standard Error) = `slope' (`std_err')")
		graph export figures/sbac/bias_test_va_cfr_g11_`outcome'_`subject'_census.pdf, replace


		******** Peer Controls
		/*estimates use estimates/sbac/bias_test_va_cfr_g11_`outcome'_`subject'_census_peer.ster
		eststo bias_g11_`outcome'_`subject'_peer
		test _b[va_cfr_g11_`outcome'_`subject'_peer] = 0
		matrix test_p = r(p)
		matrix rownames test_p = pvalue
		matrix colnames test_p = va_cfr_g11_`outcome'_`subject'_peer
		estadd matrix test_p = test_p

		local slope : di %5.3f _b[va_cfr_g11_`outcome'_`subject'_peer]
		local std_err : di %4.3f _se[va_cfr_g11_`outcome'_`subject'_peer]
		binscatter g11_`outcome'_`subject'_r_d_peer va_cfr_g11_`outcome'_`subject'_peer ///
			[aw = n_g11_`outcome'_`subject'] ///
			, ytitle("Predicted ``outcome'_str' using ACS Census Tract Demographics") xtitle("Value Added") title("11th Grade ``outcome'_str' Forecast Bias Test") ///
			yline(0) xline(0) ///
			yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
			note("Slope (Standard Error) = `slope' (`std_err')")
		graph export figures/sbac/bias_test_va_cfr_g11_`outcome'_`subject'_census_peer.pdf, replace*/
		
		
		
		
		**************** VA rank comparison with excluded observables
		******** No Peer Controls
		bysort year: egen rank_va_cfr_g11_`outcome'_`subject' = rank(va_cfr_g11_`outcome'_`subject'), field
		bysort year: egen rank_va_fb_g11_`outcome'_`subject' = rank(va_fb_g11_`outcome'_`subject'), field
		corr rank_va_cfr_g11_`outcome'_`subject' rank_va_fb_g11_`outcome'_`subject'
		local corr : di %4.3f r(rho)
		twoway ///
			(scatter rank_va_fb_g11_`outcome'_`subject' rank_va_cfr_g11_`outcome'_`subject' ///
				, mcolor(navy) msize(tiny)) ///
			(function y = x, range(rank_va_cfr_g11_`outcome'_`subject')) ///
			, ytitle("VA Rank Controlling for ACS Variables") xtitle("VA Rank") title("VA Rank Comparison") ///
			legend(off) ///
			note("Correlation = `corr'")
		graph export figures/sbac/scatter_rank_va_cfr_g11_`outcome'_`subject'_census.pdf, replace
	}
	
	
	
		
	******** No Peer Controls
	estimates use estimates/sbac/bias_test_va_cfr_g11_`outcome'_dk_census.ster
	eststo bias_g11_`outcome'_dk
	test _b[va_cfr_g11_`outcome'_dk] = 0
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`outcome'_dk
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`outcome'_dk]
	local std_err : di %4.3f _se[va_cfr_g11_`outcome'_dk]
	binscatter g11_`outcome'_dk_r_d va_cfr_g11_`outcome'_dk ///
		[aw = n_g11_`outcome'_dk] ///
		, ytitle("Predicted ``outcome'_str' using ACS Census Tract Demographics") xtitle("Value Added") title("11th Grade ``outcome'_str' Forecast Bias Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/bias_test_va_cfr_g11_`outcome'_dk_census.pdf, replace


	******** Peer Controls
	/*estimates use estimates/sbac/bias_test_va_cfr_g11_`outcome'_dk_census_peer.ster
	eststo bias_g11_`outcome'_dk_peer
	test _b[va_cfr_g11_`outcome'_dk_peer] = 0
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`outcome'_dk_peer
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`outcome'_dk_peer]
	local std_err : di %4.3f _se[va_cfr_g11_`outcome'_dk_peer]
	binscatter g11_`outcome'_dk_r_d_peer va_cfr_g11_`outcome'_dk_peer ///
		[aw = n_g11_`outcome'_dk] ///
		, ytitle("Predicted ``outcome'_str' using ACS Census Tract Demographics") xtitle("Value Added") title("11th Grade ``outcome'_str' Forecast Bias Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/bias_test_va_cfr_g11_`outcome'_dk_census_peer.pdf, replace*/
	
	
	
	
	**************** VA rank comparison with excluded observables
	******** No Peer Controls
	bysort year: egen rank_va_cfr_g11_`outcome'_dk = rank(va_cfr_g11_`outcome'_dk), field
	bysort year: egen rank_va_fb_g11_`outcome'_dk = rank(va_fb_g11_`outcome'_dk), field
	corr rank_va_cfr_g11_`outcome'_dk rank_va_fb_g11_`outcome'_dk
	local corr : di %4.3f r(rho)
	twoway ///
		(scatter rank_va_fb_g11_`outcome'_dk rank_va_cfr_g11_`outcome'_dk ///
			, mcolor(navy) msize(tiny)) ///
		(function y = x, range(rank_va_cfr_g11_`outcome'_dk)) ///
		, ytitle("VA Rank Controlling for ACS Variables") xtitle("VA Rank") title("VA Rank Comparison") ///
		legend(off) ///
		note("Correlation = `corr'")
	graph export figures/sbac/scatter_rank_va_cfr_g11_`outcome'_dk_census.pdf, replace
	
	
	
	
	**************** Tables
	******** No Peer Controls
	esttab ///
		bias_g11_`outcome' ///
		bias_g11_`outcome'_ela ///
		bias_g11_`outcome'_math ///
		bias_g11_`outcome'_dk ///
		using tables/sbac/test_va_cfr_g11_`outcome'.tex ///
		, append `esttab_keep' ///
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
		varlabels(x_var "VA Forecast Bias Test: Predicted Score using ACS Census Tract Demographics")


	******** Peer Controls
	/*esttab ///
		bias_g11_`outcome'_peer ///
		bias_g11_`outcome'_ela_peer ///
		bias_g11_`outcome'_math_peer ///
		bias_g11_`outcome'_dk_peer ///
		using tables/sbac/test_va_cfr_g11_`outcome'_peer.tex ///
		, append `esttab_keep' ///
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
		varlabels(x_var "VA Forecast Bias Test: Predicted Score using ACS Census Tract Demographics")*/

	eststo clear
}


timer off 1
timer list
log close
translate log_files/sbac/sum_stats_va_cfr_out_forecast_bias.smcl log_files/sbac/sum_stats_va_cfr_out_forecast_bias.log, replace

if inlist(c(hostname), "sapper", "scribe") {
	/*exit, STATA*/ clear
}
