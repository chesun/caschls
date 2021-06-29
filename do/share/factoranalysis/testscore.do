********************************************************************************
/* pull SBAC test score data from Matt dataset to create controls for index regressions using 6th and 8th grade test scores  */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
clear all
set more off

// load up the subsample of students Matt is using. This includes grade 11 students in year 2015-2017 (year of the spring semester)
use merge_id_k12_test_scores state_student_id dataset cdscode grade year if grade==11 & dataset=="SBAC" & inrange(year, 2015, 2017) using /home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores/k12_test_scores_clean.dta

// merge with the lagged test score data
merge 1:1 merge_id_k12_test_scores using /home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores/k12_lag_test_scores_clean.dta
//only keep merged observations
keep if _merge == 3
drop _merge

//keep only the 6th grade math score (L5) and 8th grade (L3) ELA score
keep state_student_id grade year cdscode merge_id_k12_test_scores dataset L5_cst_math_z_score L3_cst_ela_z_score

//collapse to get average test scores for each school
collapse L5_cst_math_z_score L3_cst_ela_z_score, by (cdscode year)

//collapse again to average across years
collapse avg_gr6math_zscore=L5_cst_math_z_score avg_gr8ela_zscore=L3_cst_ela_z_score, by(cdscode)

label var avg_gr6math_zscore "pooled avg 6th grade math z score for 11th graders in 2014-15 to 2016-17 "
label var avg_gr8ela_zscore "pooled avg 8th grade ELA z score for 11th graders in 2014-15 to 2016-17"

drop if missing(cdscode)

label data "SBAC 6th grade math and 8th grade ELA test score for 11 graders in 1415-1617"

save $projdir/dta/schoolchar/testscorecontrols, replace
