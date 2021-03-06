********************************************************************************
/* pull SBAC test score data from Matt dataset to create controls for index regressions using 6th and 8th grade test scores  */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
cap log close _all
clear all
set more off

log using $projdir/log/share/factoranalysis/testscore.smcl, replace


// load up the subsample of students Matt is using. This includes grade 11 students in year 2015-2017 (year of the spring semester)
use merge_id_k12_test_scores state_student_id dataset cdscode grade year all_scores_sample ///
if grade==11 & dataset=="CAASPP" & inrange(year, 2015, 2017) & all_scores_sample==1 ///
using $vaprojdir/data/restricted_access/clean/k12_test_scores/k12_test_scores_clean.dta, clear

// merge with the lagged test score data
merge 1:1 merge_id_k12_test_scores using $vaprojdir/data/restricted_access/clean/k12_test_scores/k12_lag_test_scores_clean.dta
//only keep merged observations
keep if _merge == 3
drop _merge

/* use grade 7 ELA score for grade 8 in year 2017 due to missing data */
gen prior_gr8_zscore = L3_cst_ela_z_score if inrange(year, 2015, 2016)
replace prior_gr8_zscore = L4_cst_ela_z_score if year==2017

//keep only the 6th grade math score (L5) and 8th grade (L3) ELA score
keep state_student_id grade year cdscode merge_id_k12_test_scores dataset L5_cst_math_z_score prior_gr8_zscore

//collapse to get average test scores for each school per year
collapse L5_cst_math_z_score prior_gr8_zscore, by (cdscode year)

//collapse again to average across years
collapse avg_gr6math_zscore=L5_cst_math_z_score avg_gr8ela_zscore=prior_gr8_zscore, by(cdscode)

label var avg_gr6math_zscore "pooled avg 6th grade math z score for 11th graders in 2014-15 to 2016-17 "
label var avg_gr8ela_zscore "pooled avg 8th grade ELA z score for 11th graders in 2014-15 to 2016-17"

drop if missing(cdscode)

label data "SBAC 6th grade math and 8th grade ELA test score for 11 graders in 1415-1617"

save $projdir/dta/schoolchar/testscorecontrols, replace


log close
translate $projdir/log/share/factoranalysis/testscore.smcl $projdir/log/share/factoranalysis/testscore.log, replace
