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

1/25/2023: added code to create outcome dummies for lag1 and lag2 older siblings

07/27/2023: moved the code used to merges the entire k12 test score sample 
onto postsecondary outcomes from createvasamples.do to the beginning of this 
file
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
// VA macros 
include $vaprojdir/do_files/sbac/macros_va.doh

//change directory to common_core_va project directory
cd $vaprojdir

//starting log file
log using $projdir/log/share/siblingvaregs/sibling_out_xwalk.smcl, replace


//set a timer for this do file to see how long it runs
timer on 1

********************************************************************************
*** This merges the entire k12 test score sample onto postsecondary outcomes
//the output dataset is used subsequently
use merge_id_k12_test_scores all_students_sample first_scores_sample ///
  dataset test cdscode school_id state_student_id year grade ///
  cohort_size ///
  using $vaprojdir/data/restricted_access/clean/k12_test_scores/k12_test_scores_clean.dta, clear
// merge on postsecondary Outcomes
do $vaprojdir/do_files/merge_k12_postsecondary.doh enr_only
drop enr enr_2year enr_4year
rename enr_ontime enr
rename enr_ontime_2year enr_2year
rename enr_ontime_4year enr_4year
drop if missing(state_student_id)

//save the merged k12 to postsecondary outcome dataset that has the largest student sample in order to calculate sibling outcomes
compress
label data "Full K-12 test scores merged to postsecondary outcomes"
save $projdir/dta/common_core_va/k12_postsecondary_out_merge, replace




********************************************************************************
//create sibling college outcome vars
//First load the k12 test score sample matched to postsecondary outcome data

use $projdir/dta/common_core_va/k12_postsecondary_out_merge, clear

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


// lag 1 older sibling and lag 2 older sibling
// degenerate interval bound for lag 1 and lag 2 older siblings for rangestat
bysort ufamilyid: gen lag1_bound = birth_order - 1
bysort ufamilyid: gen lag2_bound = birth_order - 2

foreach outcome in enr enr_2year enr_4year {
  // enrollment for lag 1 older sibling
  rangestat (max) `outcome' if has_older_sibling_postsec_match == 1, interval(birth_order, lag1_bound, lag1_bound) by(ufamilyid)
  rename `outcome'_max old1_sib_`outcome'
  label var old1_sib_`outcome' "`outcome' for first older sibling"
  // enrollment for lag 2 older sibling
  rangestat (max) `outcome' if has_older_sibling_postsec_match == 1, interval(birth_order, lag2_bound, lag2_bound) by(ufamilyid)
  rename `outcome'_max old2_sib_`outcome'
  label var old2_sib_`outcome' "`outcome' for second older sibling"

  gen touse_sib_lag1_lag2_`outcome' = 0
  replace touse_sib_lag1_lag2_`outcome' = 1 if !mi(old1_sib_`outcome') & !mi(old2_sib_`outcome')

}

gen touse_sib_lag = 0
replace touse_sib_lag = 1 if touse_sib_lag1_lag2_enr_2year == 1 & touse_sib_lag1_lag2_enr_4year == 1
drop lag1_bound lag2_bound




//create sibling outcomes crosswalk
compress
label data "Sibling enrollment outcomes crosswalk organized by unique families"
save $projdir/dta/siblingxwalk/sibling_out_xwalk, replace




 timer off 1
 timer list
 log close

 //translate the log file to a text log file
 translate $projdir/log/share/siblingvaregs/sibling_out_xwalk.smcl $projdir/log/share/siblingvaregs/sibling_out_xwalk.log, replace
