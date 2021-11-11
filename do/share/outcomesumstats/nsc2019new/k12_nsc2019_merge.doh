********************************************************************************
/* Merge K-12 data with the NSC 2019 provisional and final outcome crosswalk daatasets */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
*****************************10/13/2021****************************************

********************************************************************************

use merge_id_k12_test_scores all_students_sample first_scores_sample dataset ///
test cdscode state_student_id year grade	///
using `k12_test_scores_dir'/k12_test_scores_clean.dta, clear
compress
tempfile k12
save `k12'

/* merge k-12 test score with NSC 2019 provisional outcome crosswalk */
use `k12', clear
gen k12_nsc_match = 0

merge m:1 state_student_id using `nsc2019provisonalxwalk', gen(merge_k12_nsc) keep(1 3)
replace k12_nsc_match = 1 if merge_k12_nsc==3
drop merge_k12_nsc

//merge on conventional school status
merge m:1 cdscode using /home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools/k12_public_schools_clean.dta, ///
gen(merge_public_schools) keepusing(conventional_school) keep(1 3)
compress
label data "K-12 test score merged to NSC 2019 Provisional dataset outcomes"
save $projdir/dta/outcomesumstats/k12_nsc_2019_provisional_merge, replace

/* merge k-12 test score with NSC 2019 final outcome crosswalk */
use `k12', clear
gen k12_nsc_match = 0

merge m:1 state_student_id using `nsc2019finalxwalk', gen(merge_k12_nsc) keep(1 3)
replace k12_nsc_match = 1 if merge_k12_nsc==3
drop merge_k12_nsc

//merge on conventional school status
merge m:1 cdscode using /home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools/k12_public_schools_clean.dta, ///
gen(merge_public_schools) keepusing(conventional_school) keep(1 3)
compress
label data "K-12 test score merged to NSC 2019 final dataset outcomes"
save $projdir/dta/outcomesumstats/k12_nsc_2019_final_merge, replace
