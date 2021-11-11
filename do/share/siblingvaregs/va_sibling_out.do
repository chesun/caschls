********************************************************************************
/* do file to run enrollment outcome VA regressions with sibling effects.
Include as controls the dummies for
1) has an older sibling enrolled in 2 year
2) has an older sibling enrolled in 4 year

Comment on family fixed effects: Too many fixed effects, not enough observations.

 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on Nov 3, 2021 ***************************

/* To run this do file:
for origianl drift limit
do $projdir/do/share/siblingvaregs/va_sibling_out 0

otherwise set a number if encounting an error

do $projdir/do/share/siblingvaregs/va_sibling_out 2

 */


//install VAM package to estimate value added models a la Chetty, Freidman, and Rockoff
/* ssc install vam, replace  */
clear all
set more off
set varabbrev off
set scheme s1color
//capture log close: Stata should not complain if there is no log open to close
cap log close _all

args setlimit

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
log using $projdir/log/share/siblingvaregs/va_sibling_out.smcl, replace

//include macros
include do_files/sbac/macros_va.doh

#delimit ;
#delimit cr
macro list


timer on 1


//load the VA grade 11 college outcomes sample
use `va_g11_out_dataset', clear

//merge on to sibling outcomes crosswalk to get sibling enrollment controls
merge m:1 state_student_id using `sibling_out_xwalk'
drop _merge

compress
tempfile va_g11_out_sibling_dataset
save `va_g11_out_sibling_dataset'


********************************************************************************
*********** VA estimates for VA samples matched to siblings sample
********************************************************************************
if `setlimit' == 0 {
  local drift_limit = max(`test_score_max_year' - `test_score_min_year' - 1, 1)
}
else {
  local drift_limit = `setlimit'
}

foreach outcome in enr enr_2year enr_4year {
  use `va_g11_out_sibling_dataset' if touse_g11_`outcome'==1 & sibling_out_sample == 1, clear

  ***********************Overall value added
  **** No Peer Controls
  ** No TFX
  vam `outcome' ///
    , teacher(school_id) year(year) class(school_id) ///
    controls( ///
      i.year ///
      i.has_older_sibling_enr_2year ///
      i.has_older_sibling_enr_4year ///
      `school_controls' ///
      `demographic_controls' ///
      `ela_score_controls' ///
      `math_score_controls' ///
    ) ///
    data(merge tv score_r) ///
    driftlimit(`drift_limit')
  rename tv va_cfr_g11_`outcome'
  rename score_r g11_`outcome'_r


  ** TFX
	vam `outcome' ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
      i.has_older_sibling_enr_2year ///
      i.has_older_sibling_enr_4year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
		) ///
		tfx_resid(school_id) ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_tfx_g11_`outcome'
	drop score_r

  corr va_cfr_g11_`outcome' va_tfx_g11_`outcome'


  *** No TFX, without sibling college going controls
  vam `outcome' ///
    , teacher(school_id) year(year) class(school_id) ///
    controls( ///
      i.year ///
      `school_controls' ///
      `demographic_controls' ///
      `ela_score_controls' ///
      `math_score_controls' ///
    ) ///
    data(merge tv score_r) ///
    driftlimit(`drift_limit')
  rename tv va_cfr_g11_`outcome'_nosibctrl
  rename score_r g11_`outcome'_r_nosibctrl















  **** Peer Controls
	** No TFX
	vam `outcome' ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
      i.has_older_sibling_enr_2year ///
      i.has_older_sibling_enr_4year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			`peer_demographic_controls' ///
			`peer_ela_score_controls' ///
			`peer_math_score_controls' ///
		) ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_cfr_g11_`outcome'_peer
	rename score_r g11_`outcome'_r_peer

	** TFX
	vam `outcome' ///
		, teacher(school_id) year(year) class(school_id) ///
		controls( ///
			i.year ///
      i.has_older_sibling_enr_2year ///
      i.has_older_sibling_enr_4year ///
			`school_controls' ///
			`demographic_controls' ///
			`ela_score_controls' ///
			`math_score_controls' ///
			`peer_demographic_controls' ///
			`peer_ela_score_controls' ///
			`peer_math_score_controls' ///
		) ///
		tfx_resid(school_id) ///
		data(merge tv score_r) ///
		driftlimit(`drift_limit')
	rename tv va_tfx_g11_`outcome'_peer
	drop score_r

	corr va_cfr_g11_`outcome'_peer va_tfx_g11_`outcome'_peer





  **************** Specification Test
  **** No Peer Controls
  reg g11_`outcome'_r va_cfr_g11_`outcome', cluster(school_id)
  estimates save $projdir/est/siblingvaregs/outcome_va/spec_test_va_cfr_g11_`outcome'_sibling.ster, replace

  **** Peer Controls
  reg g11_`outcome'_r_peer va_cfr_g11_`outcome'_peer, cluster(school_id)
  estimates save $projdir/est/siblingvaregs/outcome_va/spec_test_va_cfr_g11_`outcome'_peer_sibling.ster, replace



  ****** sibling sample without sibling controls
  reg g11_`outcome'_r_nosibctrl va_cfr_g11_`outcome'_nosibctrl, cluster(school_id)
  estimates save $projdir/est/siblingvaregs/outcome_va/spec_test_va_cfr_g11_`outcome'_sibling_nocontrol.ster, replace




  **************Do we need deep knowledge VA with sibling controls??








  **************** Save Value Added Estimates
  collapse (firstnm) va_* ///
    (mean) g11_`outcome'* ///
    (sum) n_g11_`outcome' = touse_g11_`outcome' ///
    , by(school_id cdscode grade year)

  save $projdir/dta/common_core_va/outcome_va/va_g11_`outcome'_sibling.dta, replace


}









timer off 1
timer list
log close

//change directory back
cd "/home/research/ca_ed_lab/chesun/gsr/caschls"

//translate the log file to a text log file
translate $projdir/log/share/siblingvaregs/va_sibling_out.smcl ///
 $projdir/log/share/siblingvaregs/va_sibling_out.log, replace
