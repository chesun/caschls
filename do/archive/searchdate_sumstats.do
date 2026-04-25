********************************************************************************
/* check how many cohorts of 11th graders have a search_date of May 15th 2017
and 2010-2018 */
********************************************************************************



******************** check cohorts with search date of May 15th 2017

use merge_id_k12_test_scores all_students_sample first_scores_sample dataset ///
test cdscode state_student_id year grade	///
using `k12_test_scores_dir'/k12_test_scores_clean.dta, clear
//keep one observation per student-grade
duplicates drop state_student_id grade, force

gen k12_nsc_match = 0

compress
merge 1:m state_student_id using $nscdtadir/nsc_2010_2018_clean, gen(merge_k12_nsc) keep(1 3)
replace k12_nsc_match = 1 if merge_k12_nsc==3
drop merge_k12_nsc

duplicates drop state_student_id grade, force 
