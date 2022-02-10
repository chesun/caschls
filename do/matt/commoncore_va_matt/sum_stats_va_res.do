version 16.1
cap log close _all

*****************************************************
* First created by Matthew Naven on January 17, 2019 *
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

log using log_files/sbac/sum_stats_va_res.smcl, replace

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
	substitute(\_ _)
	;
local esttab_manual
	nolines
	nomtitles nonumbers nonotes
	collabels(none)
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
matrix res_method = J(6, 6, .)
matrix rownames res_method = sigma2lambda sigmalambda ///
	rho2_sigma2lambda_sigma2beta ///
	sigma2beta sigmabeta ///
	rho_sigma2lambda
matrix colnames res_method = enr_ela enr_math ///
	enr_2year_ela enr_2year_math ///
	enr_4year_ela enr_4year_math




******************************** 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
foreach subject in ela math {
	**************** Kernel Density
	use data/sbac/va_g11_`subject'.dta, clear
	sort school_id year
	xtset school_id year

	* Normalize to have mean zero
	foreach v of varlist va_* {
		sum `v', meanonly
		replace `v' = `v' - r(mean)
	}

	**** No Peer Controls
	corr sbac_g11_`subject'_r F.sbac_g11_`subject'_r ///
		[aw = n_g11_`subject' + F.n_g11_`subject'] ///
		, cov
	matrix res_method[rownumb(res_method, "sigma2lambda"), colnumb(res_method, "enr_`subject'")] = r(cov_12)
	matrix res_method[rownumb(res_method, "sigma2lambda"), colnumb(res_method, "enr_2year_`subject'")] = r(cov_12)
	matrix res_method[rownumb(res_method, "sigma2lambda"), colnumb(res_method, "enr_4year_`subject'")] = r(cov_12)
	di "sigma^2(`subject' test score VA) = " r(cov_12)
	matrix res_method[rownumb(res_method, "sigmalambda"), colnumb(res_method, "enr_`subject'")] = sqrt(r(cov_12))
	matrix res_method[rownumb(res_method, "sigmalambda"), colnumb(res_method, "enr_2year_`subject'")] = sqrt(r(cov_12))
	matrix res_method[rownumb(res_method, "sigmalambda"), colnumb(res_method, "enr_4year_`subject'")] = sqrt(r(cov_12))
	di "sigma(`subject' test score VA) = " sqrt(r(cov_12))

	**** Peer Controls
	corr sbac_g11_`subject'_r_peer F.sbac_g11_`subject'_r_peer ///
		[aw = n_g11_`subject' + F.n_g11_`subject'] ///
		, cov
	di "sigma^2(`subject' test score VA) = " r(cov_12)
	di "sigma(`subject' test score VA) = " sqrt(r(cov_12))
}
















******************************** 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
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
	corr g11_`outcome'_r F.g11_`outcome'_r ///
		[aw = n_g11_`outcome' + F.n_g11_`outcome'] ///
		, cov
	matrix res_method[rownumb(res_method, "rho2_sigma2lambda_sigma2beta"), colnumb(res_method, "`outcome'_ela")] = r(cov_12)
	matrix res_method[rownumb(res_method, "rho2_sigma2lambda_sigma2beta"), colnumb(res_method, "`outcome'_math")] = r(cov_12)
	di "rho^2 * sigma^2(test score VA) + sigma^2(`outcome' deep knowledge VA) = " r(cov_12)
	di "sqrt(rho^2 * sigma^2(test score VA) + sigma^2(`outcome' deep knowledge VA)) = " sqrt(r(cov_12))

	**** Peer Controls
	corr g11_`outcome'_r_peer F.g11_`outcome'_r_peer ///
		[aw = n_g11_`outcome' + F.n_g11_`outcome'] ///
		, cov
	di "rho^2 * sigma^2(test score VA) + sigma^2(`outcome' deep knowledge VA) = " r(cov_12)
	di "sqrt(rho^2 * sigma^2(test score VA) + sigma^2(`outcome' deep knowledge VA)) = " sqrt(r(cov_12))
	
	
	
	
	******** Deep Knowledge Value Added
	foreach subject in ela math {
		merge m:1 cdscode year using data/sbac/va_g11_`subject'.dta, nogen
		sort school_id year
		xtset school_id year
		
		**** No Peer Controls
		corr g11_`outcome'_`subject'_r F.g11_`outcome'_`subject'_r ///
			[aw = n_g11_`outcome'_`subject' + F.n_g11_`outcome'_`subject'] ///
			, cov
		matrix res_method[rownumb(res_method, "sigma2beta"), colnumb(res_method, "`outcome'_`subject'")] = r(cov_12)
		di "sigma^2(`outcome' deep knowledge VA controlling for `subject' test score VA) = " r(cov_12)
		matrix res_method[rownumb(res_method, "sigmabeta"), colnumb(res_method, "`outcome'_`subject'")] = sqrt(r(cov_12))
		di "sigma(`outcome' deep knowledge VA controlling for `subject' test score VA) = " sqrt(r(cov_12))
		
		corr g11_`outcome'_r F.sbac_g11_`subject'_r ///
			[aw = n_g11_`outcome' + F.n_g11_`subject'] ///
			, cov
		matrix res_method[rownumb(res_method, "rho_sigma2lambda"), colnumb(res_method, "`outcome'_`subject'")] = r(cov_12)
		di "rho * sigma^2(`subject' test score VA) = " r(cov_12)
		di "sqrt(rho) * sigma(`subject' test score VA) = " sqrt(r(cov_12))

		**** Peer Controls
		corr g11_`outcome'_`subject'_r_peer F.g11_`outcome'_`subject'_r_peer ///
			[aw = n_g11_`outcome'_`subject' + F.n_g11_`outcome'_`subject'] ///
			, cov
		di "sigma^2(`outcome' deep knowledge VA controlling for `subject' test score VA) = " r(cov_12)
		di "sigma(`outcome' deep knowledge VA controlling for `subject' test score VA) = " sqrt(r(cov_12))
		
		corr g11_`outcome'_r_peer F.sbac_g11_`subject'_r_peer ///
			[aw = n_g11_`outcome' + F.n_g11_`subject'] ///
			, cov
		di "rho * sigma^2(`subject' test score VA) = " r(cov_12)
		di "sqrt(rho) * sigma(`subject' test score VA) = " sqrt(r(cov_12))
	}
	
	
	
	
		
	**** No Peer Controls
	corr g11_`outcome'_dk_r F.g11_`outcome'_dk_r ///
		[aw = n_g11_`outcome'_dk + F.n_g11_`outcome'_dk] ///
		, cov
	di "sigma^2(`outcome' deep knowledge VA controlling for both test score VA) = " r(cov_12)
	di "sigma(`outcome' deep knowledge VA controlling for both test score VA) = " sqrt(r(cov_12))
	
	/*corr g11_`outcome'_r F.sbac_g11_dk_r ///
		[aw = n_g11_`outcome' + F.n_g11_dk] ///
		, cov
	di "rho * sigma^2(both test score VA) = " r(cov_12)
	di "sqrt(rho) * sigma(both test score VA) = " sqrt(r(cov_12))*/

	**** Peer Controls
	corr g11_`outcome'_dk_r_peer F.g11_`outcome'_dk_r_peer ///
		[aw = n_g11_`outcome'_dk + F.n_g11_`outcome'_dk] ///
		, cov
	di "sigma^2(`outcome' deep knowledge VA controlling for both test score VA) = " r(cov_12)
	di "sigma(`outcome' deep knowledge VA controlling for both test score VA) = " sqrt(r(cov_12))
	
	/*corr g11_`outcome'_r_peer F.sbac_g11_dk_r_peer ///
		[aw = n_g11_`outcome' + F.n_g11_dk] ///
		, cov
	di "rho * sigma^2(both test score VA) = " r(cov_12)
	di "sqrt(rho) * sigma(both test score VA) = " sqrt(r(cov_12))*/
}




esttab matrix(res_method, fmt(%4.3f)) using tables/sbac/va_res.tex ///
	, `esttab_layout' `esttab_manual' ///
	varlabel( ///
		sigma2lambda "$ \sigma^2_{\lambda} $" ///
		sigmalambda "$ \sigma_{\lambda} $" ///
		rho2_sigma2lambda_sigma2beta "$ \rho^2 \sigma^2_{\lambda} + \sigma^2_{\beta} $" ///
		sigma2beta "$ \sigma^2_{\beta} $" ///
		sigmabeta "$ \sigma_{\beta} $" ///
		rho_sigma2lambda "$ \rho \sigma^2_{\lambda} $" ///
	)


timer off 1
timer list
log close
translate log_files/sbac/sum_stats_va_res.smcl log_files/sbac/sum_stats_va_res.log, replace

if inlist(c(hostname), "sapper", "scribe") {
	/*exit, STATA*/ clear
}
