/* check to see what might be casuing the issue of no duplicates in terms of
state_student_id and year in the SBAC data, but having lots of duplicates in terms
of state_student_id grade and year in the all students sample
See Matt's email on September 7, 2021 */

//load the dataset
use merge_id_k12_test_scores all_students_sample all_scores_sample first_scores_sample dataset test cdscode school_id state_student_id year grade using /home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores/k12_test_scores_clean.dta, clear
gen count_var=1

tab year if grade==11 & all_students_sample==1


duplicates report state_student_id if grade==11 & all_students_sample==1 & year==2018

duplicates report year state_student_id if grade==11 & all_students_sample==1

duplicates tag state_student_id grade year if !mi(state_student_id), gen(dup_ssid_grade_year)

tab year dup_ssid_grade_year if grade==11 & all_students_sample==1

sum if all_students_sample==1 & grade==11 & (year==2015 | year==2016 | year==2017)
sum if all_students_sample==1 & grade==11 & year>=2015 & test=="SBAC"


duplicates tag state_student_id grade year if !mi(state_student_id)&all_students_sample==1, gen(dup_allstudents)
tab year dup_allstudents if grade==11 & all_students_sample==1

duplicates tag state_student_id grade year if !mi(state_student_id)&all_scores_sample==1, gen(dup_allsocres)
tab year dup_allsocres if grade==11 & all_scores_sample==1

duplicates tag state_student_id grade year if !mi(state_student_id)&first_scores_sample==1, gen(dup_firstsocres)
tab year dup_firstsocres if grade==11 & first_scores_sample==1

gen all_students_all_scores_discrep = 0
replace all_students_all_scores_discrep=1 if grade==11&all_students_sample==1&all_scores_sample==0
sort all_students_all_scores_discrep state_student_id
