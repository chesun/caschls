version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on June 09, 2020 *
*****************************************************

if inlist(c(hostname), "sapper", "scribe") {
	global S_ADO BASE;.;PERSONAL;PLUS;SITE;OLDPLACE
	local home "/home/research/ca_ed_lab/msnaven/common_core_va"
	local ca_ed_lab "/home/research/ca_ed_lab"
	local k12_test_scores "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores"
	local public_access "/home/research/ca_ed_lab/data/public_access"
	local k12_public_schools "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools"
	local k12_test_scores_public "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_test_scores"
	local acs "/home/research/ca_ed_lab/msnaven/data/public_access/clean/acs"
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

log using log_files/sbac/sum_stats_va_cfr_forecast_bias.smcl, replace

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
foreach subject in ela math {
	use data/sbac/bias_va_g11_`subject'_L4_cst_ela_z_score.dta, clear

	* Normalize to have mean zero
	foreach v of varlist va_* {
		sum `v', meanonly
		replace `v' = `v' - r(mean)
	}

	**************** Binscatter
	******** No Peer Controls
	estimates use estimates/sbac/bias_test_va_cfr_g11_`subject'_L4_cst_ela_z_score.ster
	eststo bias_g11_`subject'
	test _b[va_cfr_g11_`subject'] = 0
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`subject'
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`subject']
	local std_err : di %4.3f _se[va_cfr_g11_`subject']
	binscatter sbac_g11_`subject'_r_d va_cfr_g11_`subject' ///
		[aw = n_g11_`subject'] ///
		, ytitle("Predicted Score using 7th Grade ELA Score") xtitle("Value Added") title("11th Grade ``subject'_str' Forecast Bias Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/bias_test_va_cfr_g11_`subject'_L4_cst_ela_z_score.pdf, replace


	******** Peer Controls
	estimates use estimates/sbac/bias_test_va_cfr_g11_`subject'_L4_cst_ela_z_score_peer.ster
	eststo bias_g11_`subject'_peer
	test _b[va_cfr_g11_`subject'_peer] = 0
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`subject'_peer
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`subject'_peer]
	local std_err : di %4.3f _se[va_cfr_g11_`subject'_peer]
	binscatter sbac_g11_`subject'_r_d_peer va_cfr_g11_`subject'_peer ///
		[aw = n_g11_`subject'] ///
		, ytitle("Predicted Score using 7th Grade ELA Score") xtitle("Value Added") title("11th Grade ``subject'_str' Forecast Bias Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/bias_test_va_cfr_g11_`subject'_L4_cst_ela_z_score_peer.pdf, replace
}


**************** Tables ELA/Math
******** No Peer Controls
esttab ///
	bias_g11_ela ///
	bias_g11_math ///
	using tables/sbac/test_va_cfr_g11.tex ///
	, append `esttab_keep' ///
	cells(b(fmt(%5.3f) /*star*/ pvalue(test_p)) se(fmt(%4.3f) par) ci(fmt(%5.3f) par([ , ]))) ///
	/*star(* 0.1 ** 0.05 *** 0.01)*/ nostar noobs compress label interaction(\times) ///
	booktabs substitute(\_ _) ///
	fragment nomtitles nonumbers nonotes nolines nogaps collabels(none) ///
	rename( ///
		va_cfr_g11_ela "x_var" ///
		va_cfr_g11_math "x_var" ///
	) ///
	varlabels(x_var "VA Forecast Bias Test: Predicted Score using 7th Grade ELA Score")


******** Peer Controls
esttab ///
	bias_g11_ela_peer ///
	bias_g11_math_peer ///
	using tables/sbac/test_va_cfr_g11_peer.tex ///
	, append `esttab_keep' ///
	cells(b(fmt(%5.3f) /*star*/ pvalue(test_p)) se(fmt(%4.3f) par) ci(fmt(%5.3f) par([ , ]))) ///
	/*star(* 0.1 ** 0.05 *** 0.01)*/ nostar noobs compress label interaction(\times) ///
	booktabs substitute(\_ _) ///
	fragment nomtitles nonumbers nonotes nolines nogaps collabels(none) ///
	rename( ///
		va_cfr_g11_ela "x_var" ///
		va_cfr_g11_math "x_var" ///
	) ///
	varlabels(x_var "VA Forecast Bias Test: Predicted Score using 7th Grade ELA Score")

eststo clear
















**************** Census Tract Forecast Bias Test
foreach subject in ela math {
	use data/sbac/bias_va_g11_`subject'_census.dta, clear

	* Normalize to have mean zero
	foreach v of varlist va_* {
		sum `v', meanonly
		replace `v' = `v' - r(mean)
	}

	**************** Binscatter
	******** No Peer Controls
	estimates use estimates/sbac/bias_test_va_cfr_g11_`subject'_census.ster
	eststo bias_g11_`subject'
	test _b[va_cfr_g11_`subject'] = 0
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`subject'
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`subject']
	local std_err : di %4.3f _se[va_cfr_g11_`subject']
	binscatter sbac_g11_`subject'_r_d va_cfr_g11_`subject' ///
		[aw = n_g11_`subject'] ///
		, ytitle("Predicted Score using ACS Census Tract Demographics") xtitle("Value Added") title("11th Grade ``subject'_str' Forecast Bias Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/bias_test_va_cfr_g11_`subject'_census.pdf, replace


	******** Peer Controls
	estimates use estimates/sbac/bias_test_va_cfr_g11_`subject'_census_peer.ster
	eststo bias_g11_`subject'_peer
	test _b[va_cfr_g11_`subject'_peer] = 0
	matrix test_p = r(p)
	matrix rownames test_p = pvalue
	matrix colnames test_p = va_cfr_g11_`subject'_peer
	estadd matrix test_p = test_p

	local slope : di %5.3f _b[va_cfr_g11_`subject'_peer]
	local std_err : di %4.3f _se[va_cfr_g11_`subject'_peer]
	binscatter sbac_g11_`subject'_r_d_peer va_cfr_g11_`subject'_peer ///
		[aw = n_g11_`subject'] ///
		, ytitle("Predicted Score using ACS Census Tract Demographics") xtitle("Value Added") title("11th Grade ``subject'_str' Forecast Bias Test") ///
		yline(0) xline(0) ///
		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
		note("Slope (Standard Error) = `slope' (`std_err')")
	graph export figures/sbac/bias_test_va_cfr_g11_`subject'_census_peer.pdf, replace
	
	
	
	
	**************** VA comparison with/without excluded observables
	******** No Peer Controls
	corr va_cfr_g11_`subject' va_fb_g11_`subject'
	local corr : di %4.3f r(rho)
	twoway ///
		(scatter va_fb_g11_`subject' va_cfr_g11_`subject' ///
			, mcolor(navy) msize(tiny)) ///
		(function y = x, range(va_cfr_g11_`subject')) ///
		, ytitle("VA Controlling for ACS Variables") xtitle("VA") title("VA Comparison") ///
		legend(off) ///
		note("Correlation = `corr'")
	graph export figures/sbac/scatter_va_cfr_g11_`subject'_census.pdf, replace
	
	
	
	
	**************** VA difference with/without excluded observables
	******** No Peer Controls
	gen va_fb_g11_`subject'_diff = va_fb_g11_`subject' - va_cfr_g11_`subject'
	twoway ///
		(histogram va_fb_g11_`subject'_diff ///
			, frequency color(navy)) ///
		, ytitle("Frequency") xtitle("Difference") title("VA Difference with/without ACS Variables")
	graph export figures/sbac/hist_va_cfr_g11_`subject'_diff_census.pdf, replace
	
	
	
	
	**************** VA rank comparison with/without excluded observables
	******** No Peer Controls
	bysort year: egen rank_va_cfr_g11_`subject' = rank(va_cfr_g11_`subject'), field
	bysort year: egen rank_va_fb_g11_`subject' = rank(va_fb_g11_`subject'), field
	corr rank_va_cfr_g11_`subject' rank_va_fb_g11_`subject'
	local corr : di %4.3f r(rho)
	twoway ///
		(scatter rank_va_fb_g11_`subject' rank_va_cfr_g11_`subject' ///
			, mcolor(navy) msize(tiny)) ///
		(function y = x, range(rank_va_cfr_g11_`subject')) ///
		, ytitle("VA Rank Controlling for ACS Variables") xtitle("VA Rank") title("VA Rank Comparison") ///
		legend(off) ///
		note("Correlation = `corr'")
	graph export figures/sbac/scatter_rank_va_cfr_g11_`subject'_census.pdf, replace
}


**************** Tables ELA/Math
******** No Peer Controls
esttab ///
	bias_g11_ela ///
	bias_g11_math ///
	using tables/sbac/test_va_cfr_g11.tex ///
	, append `esttab_keep' ///
	cells(b(fmt(%5.3f) /*star*/ pvalue(test_p)) se(fmt(%4.3f) par) ci(fmt(%5.3f) par([ , ]))) ///
	/*star(* 0.1 ** 0.05 *** 0.01)*/ nostar noobs compress label interaction(\times) ///
	booktabs substitute(\_ _) ///
	fragment nomtitles nonumbers nonotes nolines nogaps collabels(none) ///
	rename( ///
		va_cfr_g11_ela "x_var" ///
		va_cfr_g11_math "x_var" ///
	) ///
	varlabels(x_var "VA Forecast Bias Test: Predicted Score using ACS Census Tract Demographics")


******** Peer Controls
esttab ///
	bias_g11_ela_peer ///
	bias_g11_math_peer ///
	using tables/sbac/test_va_cfr_g11_peer.tex ///
	, append `esttab_keep' ///
	cells(b(fmt(%5.3f) /*star*/ pvalue(test_p)) se(fmt(%4.3f) par) ci(fmt(%5.3f) par([ , ]))) ///
	/*star(* 0.1 ** 0.05 *** 0.01)*/ nostar noobs compress label interaction(\times) ///
	booktabs substitute(\_ _) ///
	fragment nomtitles nonumbers nonotes nolines nogaps collabels(none) ///
	rename( ///
		va_cfr_g11_ela_peer "x_var" ///
		va_cfr_g11_math_peer "x_var" ///
	) ///
	varlabels(x_var "VA Forecast Bias Test: Predicted Score using ACS Census Tract Demographics")


timer off 1
timer list
log close
translate log_files/sbac/sum_stats_va_cfr_forecast_bias.smcl log_files/sbac/sum_stats_va_cfr_forecast_bias.log, replace

if inlist(c(hostname), "sapper", "scribe") {
	/*exit, STATA*/ clear
}
