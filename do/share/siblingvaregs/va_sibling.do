********************************************************************************
/* do file to run test score VA regressions with sibling effects.
Include as controls the dummies for
1) has an older sibling enrolled in 2 year
2) has an older sibling enrolled in 4 year

Comment on family fixed effects: Too many fixed effects, not enough observations.
Stata returns an error "attempted to fit a model with too many variables"
Only 749488 obs but 600210 families, too many variables from family fixed effects

 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on Sep 22, 2021 ***************************

/* To run this do file:
for origianl drift limit
do $projdir/do/share/siblingvaregs/va_sibling 0

otherwise set a number

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

/* file path macros  */
include $projdir/do/share/siblingvaregs/vafilemacros.doh

//change directory to common_core_va project directory
cd $vaprojdir

//starting log file
log using $projdir/log/share/siblingvaregs/va_sibling.smcl, replace

//run the do helper file to set the local macros
include `mattdofiles'/macros_va.doh

#delimit ;
#delimit cr
macro list


timer on 1

********************************************************************************


//load the VA grade 11 sample
use `va_g11_dataset', clear

//merge on to sibling outcomes crosswalk to get sibling enrollment controls
merge m:1 state_student_id using `sibling_out_xwalk', nogen keep(1 3)

drop if mi(has_older_sibling_enr_2year)
drop if mi(has_older_sibling_enr_4year)

compress
tempfile va_g11_sibling_dataset
save `va_g11_sibling_dataset'




********************************************************************************
*********** VA estimates for VA samples matched to siblings sample
********************************************************************************


if `setlimit' == 0 {
  local drift_limit = max(`test_score_max_year' - `test_score_min_year' - 1, 1)
}
else {
  local drift_limit = `setlimit'
}

foreach subject in ela math {


    /* load the VA g11 subject sample with siblings outcome sample
     (those who have at least one older sibling matched to the postsecondary
   outcomes) */
    use `va_g11_sibling_dataset' if touse_g11_`subject'==1 & sibling_out_sample == 1, clear

    ******************************************************************************
    ************ Value added estimation with no peer controls ********************
    ****** No TFX, without sibling college going controls
    vam sbac_`subject'_z_score ///
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
    rename tv va_cfr_g11_`subject'_nosibctrl
    rename score_r sbac_g11_`subject'_r_nosibctrl
    label var va_cfr_g11_`subject'_nosibctrl "`subject' VA with family FE without TFX without sibling control"
    label var sbac_g11_`subject'_r_nosibctrl "`subject' score residual with family FE without TFX without sibling control"

    ****** No TFX (teacher fixed effects), include sibling controls
    vam sbac_`subject'_z_score ///
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
  	rename tv va_cfr_g11_`subject'
  	rename score_r sbac_g11_`subject'_r
    label var va_cfr_g11_`subject' "`subject' VA with family FE without TFX"
    label var sbac_g11_`subject'_r "`subject' score residual with family FE without TFX"


    ****** With TFX, and TFX is added back in the the VA estimates
    vam sbac_`subject'_z_score ///
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
    rename tv va_tfx_g11_`subject'
    drop score_r
    label var va_tfx_g11_`subject' "`subject' VA with family FE with TFX"










    ******************************************************************************
    ************ Value added estimation with peer controls ********************
    ****** No TFX (teacher fixed effects)
    vam sbac_`subject'_z_score ///
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
    rename tv va_cfr_g11_`subject'_peer
    rename score_r sbac_g11_`subject'_r_peer
    label var va_cfr_g11_`subject'_peer "`subject' VA with family FE with TFX"
    label var sbac_g11_`subject'_r_peer "`subject' score residual with family FE with TFX"


    ****** With TFX
    vam sbac_`subject'_z_score ///
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
    rename tv va_tfx_g11_`subject'_peer
    drop score_r


    ******************************************************************************
    ************ specification test: regressing score residuals on VA estimates
    ******* No peer controls
    reg sbac_g11_`subject'_r va_cfr_g11_`subject', cluster(school_id)
    estimates save $projdir/est/siblingvaregs/test_score_va/spec_test_va_cfr_g11_`subject'_sibling.ster, replace


    ******* With peer controls
    reg sbac_g11_`subject'_r_peer va_cfr_g11_`subject'_peer, cluster(school_id)
    estimates save $projdir/est/siblingvaregs/test_score_va/spec_test_va_cfr_g11_`subject'_peer_sibling.ster, replace


    ******** sibling sample without sibling controls
    reg sbac_g11_`subject'_r_nosibctrl va_cfr_g11_`subject'_nosibctrl, cluster(school_id)
    estimates save $projdir/est/siblingvaregs/test_score_va/spec_test_va_cfr_g11_`subject'_sibling_nocontrol.ster, replace




    ******************************************************************************
    /* CFR Forecast Bias Test */
    ***** leave out variable is sibling controls


    **no peer controls
    gen sbac_g11_`subject'_r_d = sbac_g11_`subject'_r_nosibctrl - sbac_g11_`subject'_r
    reg sbac_g11_`subject'_r_d va_cfr_g11_`subject'_nosibctrl,	cluster(school_id)
    estimates save $projdir/est/siblingvaregs/test_score_va/fb_test_va_cfr_g11_`subject'_sibling.ster, replace 




    **************** Save Value Added Estimates
    collapse (firstnm) va_* ///
  		(mean) sbac_*_r* ///
  		(sum) n_g11_`subject' = touse_g11_`subject' ///
      if sibling_full_sample == 1 & sibling_out_sample == 1 ///
  		, by(school_id cdscode grade year)
  	save $projdir/dta/common_core_va/test_score_va/va_g11_`subject'_sibling.dta, replace


}








timer off 1
timer list
log close

//change directory back
cd $projdir

//translate the log file to a text log file
translate $projdir/log/share/siblingvaregs/va_sibling.smcl ///
 $projdir/log/share/siblingvaregs/va_sibling.log, replace
