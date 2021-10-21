********************************************************************************
/* create a sibling enrollment outcomes crosswalk dataset by merging k-12 test scores
to the postsecondary outcomes and then merge to ufamilyxwalk.dta and calculuate
number of older siblings enrolled and proportion of older siblings enrolled
 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on Sep 22, 2021 ***************************

/* to run this do file:
do $projdir/do/share/siblingvaregs/siblingoutxwalk.do
*/


clear all
set more off
set varabbrev off

*** macros for Matt's data directories
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


//starting log file
log using $projdir/log/share/siblingvaregs/sibling_out_xwalk.smcl, replace


//set a timer for this do file to see how long it runs
timer on 1



********************************************************************************
//create sibling college outcome vars
//First load the k12 test score sample matched to postsecondary outcome data

use `k12_postsecondary_out_merge', clear
//collapse to ssid level
collapse (max) enr enr_2year enr_4year, by(state_student_id)

//merge on unique family id
merge 1:1 state_student_id using `ufamilyxwalk'
/*
Result                      Number of obs
    -----------------------------------------
    Not matched                     8,718,171
        from master                 8,590,681  (_merge==1)
        from using                    127,490  (_merge==2)

    Matched                         3,957,189  (_merge==3)
    -----------------------------------------

 */

//keep only the sample of matched siblings
drop if missing(ufamilyid)
//mark sibling sample for merged observations
gen sibling_out_sample = 0
replace sibling_out_sample = 1 if _merge==3
label var sibling_out_sample "Indicator for sibling sample with matched postsecondary outcomes"
drop _merge

/* NEED TO CREATE PROPS ENROLLED FOR OLDER SIBLINGS  */
//number of siblings total in the family ranges from 1 to 10, so max number of older siblings is 9

/* this rangestat command calculates the sum of the variable for observations in
the interval between birth_order - lower_bound and birth_order - 1, which is all the older siblings  */
/* NOTE: rangestat treats missing enr vars as 0 */

sort ufamilyid birth_order
gen lower_bound = -numsiblings_older
local outcomes enr enr_2year enr_4year
foreach i of local outcomes {
  rangestat (sum) `i', interval(birth_order, lower_bound, -1) by(ufamilyid)
  rename `i'_sum numsiblings_older_`i'
  label var numsiblings_older_`i' "Number of older siblings with `i'==1"
  gen propsiblings_older_`i' = numsiblings_older_`i' / numsiblings_older
  label var propsiblings_older_`i' "Proportion of older siblings with `i'==1"
}

drop lower_bound

//create sibling outcomes crosswalk
compress
label data "Sibling enrollment outcomes crosswalk organized by unique families"
save $projdir/dta/siblingxwalk/sibling_out_xwalk, replace




 timer off 1
 timer list
 log close

 //translate the log file to a text log file
 translate $projdir/log/share/siblingvaregs/sibling_out_xwalk.smcl $projdir/log/share/siblingvaregs/sibling_out_xwalk.log, replace
