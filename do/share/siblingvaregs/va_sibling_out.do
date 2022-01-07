********************************************************************************
/* do file to run enrollment outcome VA regressions with sibling effects.
Include as controls the dummies for
1) has an older sibling enrolled in 2 year
2) has an older sibling enrolled in 4 year

Comment on family fixed effects: Too many fixed effects, not enough observations. */
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



/* Change log:
1.6.2022: updated do file to reconcile server file path changes, re-ran
with drift limit = 2. Still produces an error if drift limit = 3 */



//install VAM package to estimate value added models a la Chetty, Freidman, and Rockoff
/* ssc install vam, replace  */
clear all
set more off
set varabbrev off
set scheme s1color
//capture log close: Stata should not complain if there is no log open to close
cap log close _all

args setlimit

/* file path macros  */
include $projdir/do/share/siblingvaregs/vafilemacros.doh

//change directory to common_core_va project directory
cd $vaprojdir

//starting log file
log using $projdir/log/share/siblingvaregs/va_sibling_out.smcl, replace

//run the do helper file to set the local macros
include `mattdofiles'/macros_va.doh

#delimit ;
#delimit cr
macro list


timer on 1


//load the VA grade 11 college outcomes sample
use `va_g11_out_dataset', clear

//merge on to sibling outcomes crosswalk to get sibling enrollment controls
merge m:1 state_student_id using `sibling_out_xwalk', nogen keep(1 3)

drop if mi(has_older_sibling_enr_2year)
drop if mi(has_older_sibling_enr_4year)

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
    ***without sibling college going controls
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


    *** with sibling controls
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


















  **** Peer Controls
	** No TFX
/*
    ***without sibling college going controls
    vam `outcome' ///
      , teacher(school_id) year(year) class(school_id) ///
      controls( ///
        i.year ///
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
    rename tv
    rename score_r  */

    //with sibling controls
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




********************************************************************************
  **************** Specification Test
  **** No Peer Controls
  reg g11_`outcome'_r va_cfr_g11_`outcome', cluster(school_id)
  estimates save $projdir/est/siblingvaregs/outcome_va/spec_test_va_cfr_g11_`outcome'_sibling.ster, replace

  **** Peer Controls
  reg g11_`outcome'_r_peer va_cfr_g11_`outcome'_peer, cluster(school_id)
  estimates save $projdir/est/siblingvaregs/outcome_va/spec_test_va_cfr_g11_`outcome'_peer_sibling.ster, replace



  ****** sibling sample without sibling controls
  *** no peer controls
  reg g11_`outcome'_r_nosibctrl va_cfr_g11_`outcome'_nosibctrl, cluster(school_id)
  estimates save $projdir/est/siblingvaregs/outcome_va/spec_test_va_cfr_g11_`outcome'_sibling_nocontrol.ster, replace

  /* *** with peer controls
  reg g11_`outcome'_r_nosibctrl_peer va_cfr_g11_`outcome'_nosibctrl_peer, cluster(school_id)
  estimates save $projdir/est/siblingvaregs/outcome_va/spec_test_va_cfr_g11_`outcome'_peer_sibling_nocontrol.ster, replace */

  **************Do we need deep knowledge VA with sibling controls??




  ******************************************************************************
  /* CFR Forecast Bias Test */
  ***** leave out variable is sibling controls


  **no peer controls
  gen g11_`outcome'_r_d = g11_`outcome'_r_nosibctrl - g11_`outcome'_r
  reg g11_`outcome'_r_d va_cfr_g11_`outcome'_nosibctrl, cluster(school_id)
  estimates save $projdir/est/siblingvaregs/outcome_va/fb_test_va_cfr_g11_`outcome'_sibling.ster, replace

  /* ** with peer controls
  gen g11_`outcome'_r_d_peer = g11_`outcome'_r_nosibctrl_peer - g11_`outcome'_r_peer
  reg g11_`outcome'_r_d_peer va_cfr_g11_`outcome'_nosibctrl_peer, cluster(school_id)
  estimates save $projdir/est/siblingvaregs/outcome_va/fb_test_va_cfr_g11_`outcome'_sibling_peer.ster, replace
 */



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
cd $projdir

//translate the log file to a text log file
translate $projdir/log/share/siblingvaregs/va_sibling_out.smcl ///
 $projdir/log/share/siblingvaregs/va_sibling_out.log, replace
