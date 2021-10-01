********************************************************************************
/* create the VA sample dataset with sibling info merged on to save processing time.
Using doh helpher files each time to recreate the data takes too much time
 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************** First written on Sep 22, 2021 ***************************

/* to run this do file:
do $projdir/do/share/siblingvaregs/createsiblingvasample.do
*/

clear all
set more off
set varabbrev off

local common_core_va "/home/research/ca_ed_lab/msnaven/common_core_va"
local ca_ed_lab "/home/research/ca_ed_lab"
local k12_test_scores "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores"
local public_access "/home/research/ca_ed_lab/data/public_access"
local k12_public_schools "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools"
local k12_test_scores_public "/home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_test_scores"

local va_dataset "$projdir/dta/common_core_va/va_dataset"
local va_g11_dataset "$projdir/dta/common_core_va/va_g11_dataset"
local va_g11_out_dataset "$projdir/dta/common_core_va/va_g11_out_dataset"
local siblingxwalk "$projdir/dta/siblingxwalk/siblingpairxwalk"
local ufamilyxwalk "$projdir/dta/siblingxwalk/ufamilyxwalk"

********************************************************************************
//create sibling college outcome vars
//First load the grade 11 va sample with outcome vars
use `va_g11_out_dataset', clear
//collapse to ssid level
collapse (max) enr enr_2year enr_4year, by(state_student_id)

//merge on unique family id
merge 1:1 state_student_id using `ufamilyxwalk', keep(match)
//mark sibling sample for merged observations
gen touse_g11_sibling = 1
drop _merge

/* NEED TO CREATE PROPS ENROLLED FOR OLDER SIBLINGS  */

//create vars for number of kids in each type of enrollment in each family and
//also the number of kids in each type of enrollment
foreach i in enr enr_2year enr_4year {
  bysort ufamilyid: egen numkids_`i' = total(`i')
  label var numkids_`i' "number of kids with `i' equal to 1 in each family"
  gen numsiblings_`i' = numkids_`i' - 1
  replace numsiblings_`i' = numkids_`i' if `i'==0
  label var numsiblings_`i' "number of siblings with `i' equal to 1"
  gen propsiblings_`i' = numsiblings_`i'/numsiblings
}
//create sibling enrollment proportions

compress
tempfile sibling_enr_xwalk
save `sibling_enr_xwalk'






//merge sibling info to grade 11 va dataset
 use $projdir/dta/common_core_va/va_g11_dataset, clear
