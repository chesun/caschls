********************************************************************************
/* regress enrollment outcomes on deep knowledge VA estimates (4 specifications)
from the Sibling acs restricted sample to study test score VA persistence. */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on May 4, 2022 ***************************

/* To run this do file:

do $projdir/do/share/siblingvaregs/reg_out_va_sib_acs_dk

 */

 /* CHANGE LOG

  */

clear all
set more off
set varabbrev off
set scheme s1color
//capture log close: Stata should not complain if there is no log open to close
cap log close _all

/* set trace on
set tracedepth 2 */

//starting log file
log using $projdir/log/share/siblingvaregs/reg_out_va_sib_acs_dk.smcl, replace

/* change directory to common_core_va project directory for all value added
do files because some called subroutines written by Matt may use relative file paths  */
cd $vaprojdir

/* file path macros for datasets */
include $projdir/do/share/siblingvaregs/vafilemacros.doh

//run Matt's do helper file to set the local macros for VA project
include $vaprojdir/do_files/sbac/macros_va.doh

macro list

//startomg timer
timer on 1


********************************************************************************
* begin main code

// load the resctricted outcome sample with sibling and acs controls
use $vaprojdir/data/va_samples/va_sib_acs_out_restr_smp.dta, clear

// merge in dk VA dataset
foreach outcome in enr enr_2year enr_4year {
  //merge to test score VA estimates dataset
  merge m:1 cdscode year using ///
   $vaprojdir/data/sib_acs_restr_smp/outcome_va/va_`outcome'_sib_acs_dk.dta ///
   , nogen keep(1 3) keepusing(va_*)
 // standardize the VA estimates into z scores
 foreach va of varlist va_* {
   sum `va'
   replace `va' = `va' - r(mean)
   replace `va' = `va' / r(sd)
 }
}

********** regress enrollment outcomes on deep knowledge outcome value added
foreach outcome in enr enr_2year enr_4year {
  //regressing on all 3 outcome VA's
  foreach control in og acs sib both {
    di "Deep Knowledge VA with `control' controls"

    reg `outcome' va_enr_`control'_dk va_enr_2year_`control'_dk va_enr_4year_`control'_dk ///
      i.year ///
      `school_controls' ///
      `demographic_controls' ///
      `ela_score_controls' ///
      `math_score_controls' ///
      if touse_enr_dk==1 & touse_enr_2year_dk==1 & touse_enr_4year_dk==1 ///
      , cluster(school_id)
    //add mean of yvar to stored results
    estadd ysumm, mean
    estimates save $vaprojdir/estimates/sib_acs_restr_smp/persistence/reg_`outcome'_va_allenr_`control'.ster, replace
  }
}











timer off 1
timer list

set trace off
cd $projdir
log close
translate $projdir/log/share/siblingvaregs/reg_out_va_sib_acs_dk.smcl $projdir/log/share/siblingvaregs/reg_out_va_sib_acs_dk.log, replace
