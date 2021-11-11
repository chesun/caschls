********************************************************************************
/* check the discrepancy in matched 2016 11th grader students between the 2010-2017 NSC data and
the 2010-2018 NSC data, and produce their outcome summary stats
 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

clear all
set more off



********************************************************************************
/* creating a crosswalk dataset for 2017 data matching indicator and 2018 data matching indicator */

// create a dummy for matching in the 2010-2018 dataset
use $projdir/dta/outcomesumstats/k12_nsc_2010_2018_merge, clear
rename k12_nsc_match match_2018
keep state_student_id match_2018
//keep one copy per student
duplicates drop state_student_id, force
tempfile nsc2018students
save `nsc2018students'

// create a dummy for matching in the 2010-2017 dataset
use $projdir/dta/outcomesumstats/k12_nsc_2010_2017_merge, clear
rename k12_nsc_match match_2017
keep state_student_id match_2017
duplicates drop state_student_id, force

merge 1:1 state_student_id using `nsc2018students'
drop _merge

//create a dummy for matching in both 2017 and 2018 datasets
gen match_both=0
replace match_both=1 if match_2017==1 & match_2018==1

label data "indicators for matching status between k-12 test score and 2 NSC datasets"
compress
save $projdir/dta/outcomesumstats/k12_nsc_match_status_xwalk, replace


********************************************************************************
/* check the outcome sum stats for those who matched in 2017 but not 2018 */
use $projdir/dta/outcomesumstats/k12_nsc_2010_2017_merge, clear
merge m:1 state_student_id using $projdir/dta/outcomesumstats/k12_nsc_match_status_xwalk
drop _merge

cls
//sum stats for 2016 11th grader students matched to 2017 NSC but not 2018 NSC
sum nsc_enr nsc_enr_ontime nsc_enr_4year nsc_enr_2year nsc_enr_ontime_4year nsc_enr_ontime_2year ///
nsc_enr_pub nsc_enr_priv nsc_enr_ontime_pub nsc_enr_ontime_priv nsc_enr_uc nsc_enr_ucplus ///
nsc_enr_ontime_uc nsc_enr_ontime_ucplus if match_2017==1 & match_2018==0 & grade == 11 & year == 2016 & all_students_sample == 1

translate @Results $projdir/out/txt/outcomesumstats/k12_nsc_matchdiscrep_2017_2018.txt, replace
