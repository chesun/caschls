********************************************************************************
/* do file to run forecast bias test on sibling test score VA sample, using
census tract variables as leave out variables . */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on April 14. 2022 ***************************

/* To run this do file:

do $projdir/do/share/siblingvaregs/va_sibling_forecast_bias

 */

clear all
set more off
set varabbrev off
set scheme s1color
//capture log close: Stata should not complain if there is no log open to close
cap log close _all

/* set trace on
set tracedepth 1 */

args setlimit

/* file path macros  */
include $projdir/do/share/siblingvaregs/vafilemacros.doh

//change directory to common_core_va project directory
cd $vaprojdir

//starting log file
log using $projdir/log/share/siblingvaregs/va_sibling_forecast_bias.smcl, replace

//run the do helper file to set the local macros
include `vaprojdofiles'/sbac/macros_va.doh

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
*********** VA estimates for sibling VA sample matched to census tract sample
********************************************************************************

local drift_limit = max(`test_score_max_year' - `test_score_min_year' - 1, 1)



foreach subject in ela math {
  /* load the VA g11 subject sample with siblings outcome sample
  (those who have at least one older sibling matched to the postsecondary
  outcomes) */
  use `va_g11_sibling_dataset' if touse_g11_`subject'==1 & sibling_out_sample == 1, clear



}









timer off 1
timer list

log close
translate $projdir/log/share/siblingvaregs/va_sibling_forecast_bias.smcl $projdir/log/share/siblingvaregs/va_sibling_forecast_bias.log, replace
