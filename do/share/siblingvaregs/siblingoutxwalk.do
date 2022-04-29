********************************************************************************
/* create a sibling enrollment outcomes crosswalk dataset by merging k-12 test scores
to the postsecondary outcomes and then merge to ufamilyxwalk.dta and calculuate
number of older siblings enrolled and proportion of older siblings enrolled
 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on Sep 22, 2021 ***************************
/* CHANGE LOG:
10/22/2021 Corrected wrong values for has sibling matching to postsec indicators.
Problem was caused by Stata treating missing value as greater than any nonmissing
so >0 logic does not work and will return true in case of missing

4/28/2022: Added an indicator for the sibling controls sample for 2 yr and 4 yr
sibling enrollment controls. This sample consists of obs with at least 1 sibling
matched to postsec outcomes, and who have non-missing for 2yr and 4yr enr sibling controls
 */

/* to run this do file:
do $projdir/do/share/siblingvaregs/siblingoutxwalk.do
*/


clear all
set more off
set varabbrev off
set scheme s1color

cap log close _all

/* file path macros  */
include $projdir/do/share/siblingvaregs/vafilemacros.doh

//change directory to common_core_va project directory
cd $vaprojdir

//starting log file
log using $projdir/log/share/siblingvaregs/sibling_out_xwalk.smcl, replace


//set a timer for this do file to see how long it runs
timer on 1



********************************************************************************
//create sibling college outcome vars
//First load the k12 test score sample matched to postsecondary outcome data

use `k12_postsecondary_out_merge', clear

//generate an indicator for observations matched to postsecondary outcomes data
gen k12_postsec_match = 0
replace k12_postsec_match = 1 if k12_nsc_match == 1 | k12_ccc_match == 1 | k12_csu_match == 1
label var k12_postsec_match "Indicator for k12 observation matched to postsecondary data (NSC, CCC, or CSU)"

//collapse to ssid level
collapse (max) enr enr_2year enr_4year k12_postsec_match, by(state_student_id)

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
//mark sibling sample who are matched to postsecondary outcomes for merged observations
gen sibling_out_sample = 0
replace sibling_out_sample = 1 if _merge==3 & k12_postsec_match == 1
label var sibling_out_sample "Indicator for sibling sample that are matched to postsecondary outcomes"
drop _merge

/*

. count if k12_postsec_match == 1
  2,466,979

. count if k12_postsec_match == 1 & sibling_out_sample==1
  2,466,979

All of the k12_postsec matched observations were matched to the sibling sample
 */

//mark students who have older siblings
gen has_older_sibling = 0
replace has_older_sibling = 1 if numsiblings_older > 0
label var has_older_sibling "Has at least 1 older sibling"

/* NEED TO CREATE PROPS ENROLLED FOR OLDER SIBLINGS  */
//number of siblings total in the family ranges from 1 to 10, so max number of older siblings is 9

/* this rangestat command calculates the sum of the variable for observations in
the interval between birth_order - lower_bound and birth_order - 1, which is all the older siblings  */
/* NOTE: rangestat treats missing enr vars as 0 */

/*
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
*/

/* Create dummies for whether the student has an older sibling who was matched to
postsecondary outcomes and who was enrolled in 2 year, and 4 year */
sort ufamilyid birth_order
gen lower_bound = -numsiblings_older
//create a dummy for whether at least one older sibling was matched to postsecondary outcomes
rangestat (sum) k12_postsec_match, interval(birth_order, lower_bound, -1) by(ufamilyid)
rename k12_postsec_match_sum num_older_sibling_postsec_match
label var num_older_sibling_postsec_match "Number of older sibling matched to postsecondary outcomes"

/* SUPER IMPORTANT: STATA TREATS MISSING AS GREATER THAN ANY NONMISSING NUMBER!!!!!! */
gen has_older_sibling_postsec_match = 0
replace has_older_sibling_postsec_match = 1 if !missing(num_older_sibling_postsec_match) & num_older_sibling_postsec_match > 0
label var has_older_sibling_postsec_match "Has at least one older sibling matched to postsecondary outcomes"

local outcomes enr enr_2year enr_4year
foreach i of local outcomes {
  rangestat (sum) `i' if has_older_sibling_postsec_match == 1, interval(birth_order, lower_bound, -1) by(ufamilyid)
  rename `i'_sum numsiblings_older_`i'
  label var numsiblings_older_`i' "Number of older siblings that are matched to postsec outcomes with `i'==1"
  gen has_older_sibling_`i' = 0
  replace has_older_sibling_`i' = 1 if numsiblings_older_`i' > 0 & !missing(numsiblings_older_`i')
  label var has_older_sibling_`i' "Has at least 1 older sibling matched to postsec outcome and with `i' = 1"
}

drop lower_bound

// sample indicator for obs to use in VA with sibling 2 yr and 4 yr enrollment controls
// This sample consists of obs with at least 1 sibling matched to postsec outcomes, and who have non-missing for the sibling controls
gen sibling_2y_4y_controls_sample = 0
replace sibling_2y_4y_controls_sample = 1 if !mi(has_older_sibling_enr_2year) & !mi(has_older_sibling_enr_4year) & sibling_out_sample==1

//create sibling outcomes crosswalk
compress
label data "Sibling enrollment outcomes crosswalk organized by unique families"
save $projdir/dta/siblingxwalk/sibling_out_xwalk, replace




 timer off 1
 timer list
 log close

 //translate the log file to a text log file
 translate $projdir/log/share/siblingvaregs/sibling_out_xwalk.smcl $projdir/log/share/siblingvaregs/sibling_out_xwalk.log, replace
