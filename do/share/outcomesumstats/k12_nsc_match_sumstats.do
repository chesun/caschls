********************************************************************************
/* Create summary stats for NSC outcomes merged to K-12 test score data, both for 2010-2017
and 2010-2018 */
********************************************************************************
/*  to run this do file, type:
  do $projdir/do/share/outcomesumstats/k12_nsc_match_sumstats.do 0
  if do not want to merge k12 to nsc again

  type:
  do $projdir/do/share/outcomesumstats/k12_nsc_match_sumstats.do 1
  if want to re-run the k12 nsc merge
 */
********************************************************************************
args dok12nscmerge
if `dok12nscmerge' == 1 {
  local k12_test_scores_dir "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores"
  local crosswalks_dir "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/crosswalks"

  use merge_id_k12_test_scores all_students_sample first_scores_sample dataset ///
  test cdscode state_student_id year grade	///
  using `k12_test_scores_dir'/k12_test_scores_clean.dta, clear
  compress
  tempfile k12
  save `k12'


  **** Merge to NSC 2010-2017 crosswalk
  use `k12', clear
  gen k12_nsc_match = 0


  merge m:1 state_student_id using `crosswalks_dir'/nsc_2010_2017_outcomes_crosswalk_ssid.dta, gen(merge_k12_nsc) keep(1 3)
  replace k12_nsc_match = 1 if merge_k12_nsc==3
  drop merge_k12_nsc
  //merge on conventional school status
  merge m:1 cdscode using /home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools/k12_public_schools_clean.dta, ///
  gen(merge_public_schools) keepusing(conventional_school) keep(1 3)
  compress
  label data "K-12 test score merged to NSC 2010-2017 outcomes"
  save $projdir/dta/outcomesumstats/k12_nsc_2010_2017_merge, replace


  **** merge to NSC 2010-2018 crosswalk
  use `k12', clear
  gen k12_nsc_match = 0

  compress
  merge m:1 state_student_id using `crosswalks_dir'/nsc_2010_2018_outcomes_crosswalk_ssid.dta, gen(merge_k12_nsc) keep(1 3)
  replace k12_nsc_match = 1 if merge_k12_nsc==3
  drop merge_k12_nsc
  //merge on conventional school status
  merge m:1 cdscode using /home/research/ca_ed_lab/msnaven/data/public_access/clean/k12_public_schools/k12_public_schools_clean.dta, ///
  gen(merge_public_schools) keepusing(conventional_school) keep(1 3)
  compress
  label data "K-12 test score merged to NSC 2010-2018 outcomes"
  save $projdir/dta/outcomesumstats/k12_nsc_2010_2018_merge, replace
}




**************sum stats for k12 test scores merged to NSC 2010-2017 outcomes dataset
use $projdir/dta/outcomesumstats/k12_nsc_2010_2017_merge, clear


cls //clear results window
//CDE naming convention for years is the year of spring semester, so 2016 11th graders is the 2017 graduating cohort, etc.
//summary stats for 11th graders in 2016 to 2010 conditional on matching to NSC outcomes 2010-2017
forvalues year = 2016(-1)2010 {
  di `year'
  sum nsc_enr nsc_enr_ontime nsc_enr_4year nsc_enr_2year nsc_enr_ontime_4year nsc_enr_ontime_2year ///
  nsc_enr_pub nsc_enr_priv nsc_enr_ontime_pub nsc_enr_ontime_priv nsc_enr_uc nsc_enr_ucplus ///
  nsc_enr_ontime_uc nsc_enr_ontime_ucplus if k12_nsc_match == 1 & grade == 11 & year == `year' & all_students_sample == 1
}
translate @Results $projdir/out/txt/outcomesumstats/k12_nsc_2010_2017_sumstats_matching.txt, replace
cls
//summary stats for 11th graders in conventional schools in 2016-2010 conditional on matching to NSC outcomes 2010-2017
forvalues year = 2016(-1)2010 {
  di `year'
  sum nsc_enr nsc_enr_ontime nsc_enr_4year nsc_enr_2year nsc_enr_ontime_4year nsc_enr_ontime_2year ///
  nsc_enr_pub nsc_enr_priv nsc_enr_ontime_pub nsc_enr_ontime_priv nsc_enr_uc nsc_enr_ucplus ///
  nsc_enr_ontime_uc nsc_enr_ontime_ucplus if k12_nsc_match == 1 & grade == 11 & year == `year' & all_students_sample == 1 & conventional_school == 1
}
translate @Results $projdir/out/txt/outcomesumstats/k12_nsc_2010_2017_sumstats_matching_convschl.txt, replace
cls
//replace NSC outcomes on unmatched observations with zero
foreach var of varlist nsc_enr-nsc_enr_n_lt2year {
  replace `var' = 0 if k12_nsc_match == 0
}
cls
//summary stats for all 11th graders in 2016-2010 regardless of matching status
forvalues year = 2016(-1)2010 {
  di `year'
  sum nsc_enr nsc_enr_ontime nsc_enr_4year nsc_enr_2year nsc_enr_ontime_4year nsc_enr_ontime_2year ///
  nsc_enr_pub nsc_enr_priv nsc_enr_ontime_pub nsc_enr_ontime_priv nsc_enr_uc nsc_enr_ucplus ///
  nsc_enr_ontime_uc nsc_enr_ontime_ucplus if grade == 11 & year == `year' & all_students_sample == 1
}
translate @Results $projdir/out/txt/outcomesumstats/k12_nsc_2010_2017_sumstats_all.txt, replace
cls
//summary stats for all 11th graders in conventional schools in 2016-2010 regardless of matching status
forvalues year = 2016(-1)2010 {
  di `year'
  sum nsc_enr nsc_enr_ontime nsc_enr_4year nsc_enr_2year nsc_enr_ontime_4year nsc_enr_ontime_2year ///
  nsc_enr_pub nsc_enr_priv nsc_enr_ontime_pub nsc_enr_ontime_priv nsc_enr_uc nsc_enr_ucplus ///
  nsc_enr_ontime_uc nsc_enr_ontime_ucplus if grade == 11 & year == `year' & all_students_sample == 1 & conventional_school == 1
}
translate @Results $projdir/out/txt/outcomesumstats/k12_nsc_2010_2017_sumstats_all_convschl.txt, replace







**************sum stats for k12 test scores merged to NSC 2010-2018 outcomes dataset
use $projdir/dta/outcomesumstats/k12_nsc_2010_2018_merge, clear
cls //clear results window

//summary stats for 11th graders in 2017-2010 conditional on matching to NSC outcomes 2010-2018
forvalues year = 2017(-1)2010 {
  di `year'
  sum nsc_enr nsc_enr_ontime nsc_enr_4year nsc_enr_2year nsc_enr_ontime_4year nsc_enr_ontime_2year ///
  nsc_enr_pub nsc_enr_priv nsc_enr_ontime_pub nsc_enr_ontime_priv nsc_enr_uc nsc_enr_ucplus ///
  nsc_enr_ontime_uc nsc_enr_ontime_ucplus if k12_nsc_match == 1 & grade == 11 & year == `year' & all_students_sample == 1
}
translate @Results $projdir/out/txt/outcomesumstats/k12_nsc_2010_2018_sumstats_matching.txt, replace
cls
//summary stats for 11th graders in conventional schools in 2017-2010 conditional on matching to NSC outcomes 2010-2018
forvalues year = 2017(-1)2010 {
  di `year'
  sum nsc_enr nsc_enr_ontime nsc_enr_4year nsc_enr_2year nsc_enr_ontime_4year nsc_enr_ontime_2year ///
  nsc_enr_pub nsc_enr_priv nsc_enr_ontime_pub nsc_enr_ontime_priv nsc_enr_uc nsc_enr_ucplus ///
  nsc_enr_ontime_uc nsc_enr_ontime_ucplus if k12_nsc_match == 1 & grade == 11 & year == `year' & all_students_sample == 1 & conventional_school == 1
}
translate @Results $projdir/out/txt/outcomesumstats/k12_nsc_2010_2018_sumstats_matching_convschl.txt, replace
cls

//replace NSC outcomes on unmatched observations with zero
foreach var of varlist nsc_enr-nsc_enr_n_lt2year {
  replace `var' = 0 if k12_nsc_match == 0
}
cls
//summary stats for all 11th graders in 2017-2010 regardless of matching status
forvalues year = 2017(-1)2010 {
  di `year'
  sum nsc_enr nsc_enr_ontime nsc_enr_4year nsc_enr_2year nsc_enr_ontime_4year nsc_enr_ontime_2year ///
  nsc_enr_pub nsc_enr_priv nsc_enr_ontime_pub nsc_enr_ontime_priv nsc_enr_uc nsc_enr_ucplus ///
  nsc_enr_ontime_uc nsc_enr_ontime_ucplus if grade == 11 & year == `year' & all_students_sample == 1
}
translate @Results $projdir/out/txt/outcomesumstats/k12_nsc_2010_2018_sumstats_all.txt, replace
cls
//summary stats for all 11th graders in conventional schools in 2017-2010 regardless of matching status
forvalues year = 2017(-1)2010 {
  di `year'
  sum nsc_enr nsc_enr_ontime nsc_enr_4year nsc_enr_2year nsc_enr_ontime_4year nsc_enr_ontime_2year ///
  nsc_enr_pub nsc_enr_priv nsc_enr_ontime_pub nsc_enr_ontime_priv nsc_enr_uc nsc_enr_ucplus ///
  nsc_enr_ontime_uc nsc_enr_ontime_ucplus if grade == 11 & year == `year' & all_students_sample == 1 & conventional_school == 1
}
translate @Results $projdir/out/txt/outcomesumstats/k12_nsc_2010_2018_sumstats_all_convschl.txt, replace
