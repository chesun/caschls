/* Test the VAM ado file by Matt */

********************************************************************************
/* do file to run VA regressions with sibling effects. See VA to do list doc for details.
Current models:
1. Sibling FE as an additional demographic control in our value added estimation.
2. Proportion of older siblings that attended college as an additional demographic control in our value added estimation.
3. Specification test with sibling FE
4. Proportion of older siblings that attended college as a leave-out variable to use for a forecast bias test.
5. Sibling FE as an additional control for regressions of long-run outcomes on value added.
6. Proportion of older siblings that attended college as an additional control for regressions of long-run outcomes on value added.
 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on Sep 22, 2021 ***************************

/* To run this do file:
do $projdir/do/share/siblingvaregs/vamtest
 */


//install VAM package to estimate value added models a la Chetty, Freidman, and Rockoff
/* ssc install vam, replace  */
clear all
set more off
set varabbrev off
set maxvar 32767, permanently
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
log using $projdir/log/share/siblingvaregs/vamtest.smcl, replace

//include macros
include do_files/sbac/macros_va.doh

#delimit ;
#delimit cr
macro list


timer on 1

********************************************************************************
/* Add family fixed effects as an additional demographic control in SBAC
VA estimation */

//load the VA grade 11 sample
use `va_g11_dataset', clear

//merge on to ufamilyxwalk in order to use unique family ID for FE
merge m:1 state_student_id using `sibling_out_xwalk'
drop _merge
/*
Result                      Number of obs
    -----------------------------------------
    Not matched                     4,360,629
        from master                 1,252,476  (_merge==1)
        from using                  3,108,153  (_merge==2)

    Matched                         1,169,409  (_merge==3)
    -----------------------------------------

 */

compress
tempfile va_g11_sibling_dataset
save `va_g11_sibling_dataset'




********************************************************************************
*********** VA estimates for VA samples matched to siblings sample
********************************************************************************
local drift_limit = max(`test_score_max_year' - `test_score_min_year' - 1, 1)

foreach subject in ela math {
  //load the VA g11 subject sample that are matched to the sibling sample
  use `va_g11_sibling_dataset' if touse_g11_`subject'==1 & sibling_out_sample == 1, clear
/* Only 749488 obs but 600210 families, too many variables from family fixed effects */
  ******************************************************************************
  ************ Value added estimation with no peer controls ********************
  ****** No TFX (teacher fixed effects)
  local test1 = 0
  if `test1' == 1 {
    vam sbac_`subject'_z_score ///
      , teacher(school_id) year(year) class(school_id) ///
      controls( ///
        i.year ///
        i.ufamilyid ///
        `school_controls' ///
        `demographic_controls' ///
        `ela_score_controls' ///
        `math_score_controls' ///
      ) ///
      data(merge tv score_r) ///
      driftlimit(`drift_limit')
    rename tv va_cfr_g11_`subject'_sibling
    rename score_r sbac_g11_`subject'_r_sibling
    label var va_cfr_g11_`subject'_sibling "`subject' VA with family FE without TFX"
    label var sbac_g11_`subject'_r_sibling "`subject' score residual with family FE without TFX"

  }

//test vam with dummy for older sibling enrollment
  vam sbac_`subject'_z_score ///
    , teacher(school_id) year(year) class(school_id) ///
    controls( ///
      i.year ///
      i.has_older_sibling_enr ///
      `school_controls' ///
      `demographic_controls' ///
      `ela_score_controls' ///
      `math_score_controls' ///
    ) ///
    data(merge tv score_r) ///
    driftlimit(`drift_limit')
  rename tv va_cfr_g11_`subject'_sibling
  rename score_r sbac_g11_`subject'_r_sibling
  label var va_cfr_g11_`subject'_sibling "`subject' VA with family FE without TFX"
  label var sbac_g11_`subject'_r_sibling "`subject' score residual with family FE without TFX"




}













timer off 1
timer list
log close

//change directory back
cd "/home/research/ca_ed_lab/chesun/gsr/caschls"

//translate the log file to a text log file
translate $projdir/log/share/siblingvaregs/vamtest.smcl ///
$projdir/log/share/siblingvaregs/vamtest.log, replace
