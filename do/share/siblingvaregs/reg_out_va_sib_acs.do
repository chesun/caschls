********************************************************************************
/* regress enrollment outcomes on test score VA estimates (4 specifications)
from the Sibling acs restricted sample to study test score VA persistence. */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on May 4, 2022 ***************************

/* To run this do file:

do $projdir/do/share/siblingvaregs/reg_out_va_sib_acs

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
log using $projdir/log/share/siblingvaregs/reg_out_va_sib_acs.smcl, replace

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

foreach subject in ela math {
  //merge to test score VA estimates dataset
  merge m:1 cdscode year using ///
   $vaprojdir/data/sib_acs_restr_smp/test_score_va/va_`subject'_sib_acs.dta ///
   , nogen keep(1 3) keepusing(va_*)

  // standardize the VA estimates into z scores
  foreach va of varlist va_* {
    sum `va'
    replace `va' = `va' - r(mean)
    replace `va' = `va' / r(sd)
  }
}


********** regress enrollment outcomes on test score value added
/* no peer effectsm no tfx, using the standard controls in primary VA specification */

foreach outcome in enr enr_2year enr_4year {
  // regress outcomes on each test score VA individually
  di "Dependent Var = `outcome'"

  // regressing on single subject VA, 4 VA specifications
  foreach subject in ela math {
    di "Subject = `subject'"

    foreach control in og acs sib both {
      di "test score VA with `control' controls"

      reg `outcome' va_`subject'_`control' ///
        i.year ///
        `school_controls' ///
        `demographic_controls' ///
        `ela_score_controls' ///
        `math_score_controls' ///
        if touse_g11_`subject'==1 ///
        , cluster(school_id)
      //add mean of yvar to stored results
      estadd ysumm, mean
      estimates save $vaprojdir/estimates/sib_acs_restr_smp/persistence/reg_`outcome'_va_`subject'_`control'.ster, replace
    }
  }

  //regressing on both subject VAs, 4 VA specifications
  foreach control in og acs sib both {
    di "test score VA with `control' controls"

    reg `outcome' va_ela_`control' va_math_`control' ///
      i.year ///
      `school_controls' ///
      `demographic_controls' ///
      `ela_score_controls' ///
      `math_score_controls' ///
      if touse_g11_ela==1 & touse_g11_math==1 ///
      , cluster(school_id)
    //add mean of yvar to stored results
    estadd ysumm, mean
    estimates save $vaprojdir/estimates/sib_acs_restr_smp/persistence/reg_`outcome'_va_ela_math_`control'.ster, replace
  }

}









timer off 1
timer list

set trace off
cd $projdir

log close
translate $projdir/log/share/siblingvaregs/reg_out_va_sib_acs.smcl $projdir/log/share/siblingvaregs/reg_out_va_sib_acs.log, replace
