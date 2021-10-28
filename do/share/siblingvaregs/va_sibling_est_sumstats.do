********************************************************************************
/* sum stats for the test score VA estimates with additional demographic control
off has at least one older sibling who enrolled in college (2 year, 4 year, both)
 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on 10/27, 2021 ***************************

/* To run this do file:
do $projdir/do/share/siblingvaregs/va_sibling_est_sumstats
 */

/* ssc install binscatter, replace */

clear all
graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
//capture log close: Stata should not complain if there is no log open to close
cap log close _all

*** macros for Matt's data directories
local matthomedir "/home/research/ca_ed_lab/msnaven/common_core_va"
local mattdofiles "/home/research/ca_ed_lab/msnaven/common_core_va/do_files/sbac"
local common_core_va "/home/research/ca_ed_lab/msnaven/common_core_va"
local ca_ed_lab "/home/research/ca_ed_lab"
local k12_test_scores "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores"
local public_access "/home/research/ca_ed_lab/data/public_access"
local k12_public_schools "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools"
local k12_test_scores_public "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_test_scores"

*** macros for my own datasets
local va_dataset "$projdir/dta/common_core_va/va_dataset"
local va_g11_dataset "$projdir/dta/common_core_va/va_g11_dataset"
local va_g11_out_dataset "$projdir/dta/common_core_va/va_g11_out_dataset"
local siblingxwalk "$projdir/dta/siblingxwalk/siblingpairxwalk"
local ufamilyxwalk "$projdir/dta/siblingxwalk/ufamilyxwalk"
local k12_postsecondary_out_merge "$projdir/dta/common_core_va/k12_postsecondary_out_merge"
local sibling_out_xwalk "$projdir/dta/siblingxwalk/sibling_out_xwalk"





//change directory to matt directory to reconcile the use of directories in his doh and do file
cd `matthomedir'
//starting log file
log using $projdir/log/share/siblingvaregs/va_sibling_est_sumstats.smcl, replace

//include macros
include do_files/sbac/macros_va.doh

#delimit ;
#delimit cr
macro list


timer on 1

// 11th Grade (8th Grade ELA Controls, 6th Grade Math Controls)
**************** Two Way Kernel Density for ELA and Math
foreach subject in ela math {
  foreach enrvar in enr enr_2year enr_4year {
    use $projdir/dta/common_core_va/test_score_va/va_g11_`subject'_sibling_`enrvar'.dta, clear
    sort school_id year
  	xtset school_id year

    * Normalize to have mean zero
  	foreach v of varlist va_* {
  		sum `v', meanonly
  		replace `v' = `v' - r(mean)
  	}

    sum va_cfr_g11_`subject'
    local mean_`subject'_`enrvar' = 0
    local sd_`subject'_`enrvar' : di %4.3f = r(sd)

    sum va_cfr_g11_`subject'_peer
    local mean_`subject'_`enrvar'_peer = 0
    local sd_`subject'_`enrvar'_peer : di %4.3f = r(sd)

    tempfile va_`subject'_`enrvar'
    save `va_`subject'_`enrvar''
  }
}

foreach enrvar in enr enr_2year enr_4year {
  use `va_ela_`enrvar'', clear
  merge 1:1 cdscode year using `va_math_`enrvar'', nogen

  //get around the compound macro problem inside string in notes of the grpah
  local mean_ela =  `mean_ela_`enrvar''
  local sd_ela = `sd_ela_`enrvar''

  local mean_math = `mean_math_`enrvar''
  local sd_math = `sd_math_`enrvar''

  **** No Peer Controls
  twoway ///
  	(kdensity va_cfr_g11_ela) ///
  	(kdensity va_cfr_g11_math) ///
    , ytitle("Density") xtitle("Value Added") ///
    title("11th Grade Test Score VA controlling for has older sibling `ernvar'") ///
  	legend(label(1 "ELA") label(2 "Math")) ///
    note("Mean (Standard Deviation) = `mean_ela' (`sd_ela')" ///
  	"Mean (Standard Deviation) = `mean_math' (`sd_math')")
    graph export $projdir/out/graph/siblingvaregs/test_score_va/kdensity_va_cfr_g11_`enrvar'.pdf, replace


  local mean_ela_peer =  `mean_ela_`enrvar'_peer'
  local sd_ela_peer = `sd_ela_`enrvar'_peer'

  local mean_math_peer = `mean_math_`enrvar'_peer'
  local sd_math_peer = `sd_math_`enrvar'_peer'

  ****  Peer Controls
  twoway ///
  	(kdensity va_cfr_g11_ela_peer) ///
  	(kdensity va_cfr_g11_math_peer) ///
    , ytitle("Density") xtitle("Value Added") ///
    title("11th Grade Test Score VA controlling for has older sibling `ernvar'") ///
  	legend(label(1 "ELA") label(2 "Math")) ///
    note("Mean (Standard Deviation) = `mean_ela_peer' (`sd_ela_peer')" ///
  	"Mean (Standard Deviation) = `mean_math_peer' (`sd_math_peer')")
    graph export $projdir/out/graph/siblingvaregs/test_score_va/kdensity_va_cfr_g11_`enrvar'_peer.pdf, replace

}







***********************
//specification tests
*****No peer controls
foreach subject in ela math {
  foreach enrvar in enr enr_2year enr_4year {
    estimates use $projdir/est/siblingvaregs/test_score_va/spec_test_va_cfr_g11_`subject'_sibling_`enrvar'.ster,

    test _b[va_cfr_g11_`subject'] = 1
    matrix test_p = r(p)
  	matrix rownames test_p = pvalue
  	matrix colnames test_p = va_cfr_g11_`subject'
  	estadd matrix test_p = test_p

    local slope : di %5.3f _b[va_cfr_g11_`subject']
  	local std_err : di %4.3f _se[va_cfr_g11_`subject']
  	binscatter sbac_g11_`subject'_r va_cfr_g11_`subject' ///
  		[aw = n_g11_`subject'] ///
  		, ytitle("11th Grade Score") xtitle("Value Added") ///
      title("11th Grade ``subject'_str' with older sibling `enrvar' control Specification Test") ///
  		yline(0) xline(0) ///
  		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
  		note("Slope (Standard Error) = `slope' (`std_err')")
  	graph export $projdir/out/graph/siblingvaregs/test_score_va/spec_test_va_cfr_g11_`subject'_`enrvar'.pdf, replace


******* with peer controls
    estimates use $projdir/est/siblingvaregs/test_score_va/spec_test_va_cfr_g11_`subject'_peer_sibling_`enrvar'.ster,

    test _b[va_cfr_g11_`subject'_peer] = 1
    matrix test_p = r(p)
  	matrix rownames test_p = pvalue
  	matrix colnames test_p = va_cfr_g11_`subject'_peer
  	estadd matrix test_p = test_p

  	local slope : di %5.3f _b[va_cfr_g11_`subject'_peer]
  	local std_err : di %4.3f _se[va_cfr_g11_`subject'_peer]
  	binscatter sbac_g11_`subject'_r_peer va_cfr_g11_`subject'_peer ///
  		[aw = n_g11_`subject'] ///
  		, ytitle("11th Grade Score") xtitle("Value Added") ///
      title("11th Grade ``subject'_str' with older sibling `enrevar' control Specification Test") ///
  		yline(0) xline(0) ///
  		yscale(range(-.3 .3)) xscale(range(-.3 .3)) ylabel(-.3 (0.1) .3) xlabel(-.3 (0.1) .3) ///
  		note("Slope (Standard Error) = `slope' (`std_err')")
    graph export $projdir/out/graph/siblingvaregs/test_score_va/spec_test_va_cfr_g11_`subject'_`enrvar'_peer.pdf, replace


  }

}









timer off 1
log close

translate $projdir/log/share/siblingvaregs/va_sibling_est_sumstats.smcl ///
$projdir/log/share/siblingvaregs/va_sibling_est_sumstats.log, replace
