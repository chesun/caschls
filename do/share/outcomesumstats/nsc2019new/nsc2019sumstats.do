********************************************************************************
/* Compare the NSC 2019 provisional and final daatasets outcome sum stats  */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
*****************************10/13/2021****************************************

/*  to run this do file, type:
  do $projdir/do/share/outcomesumstats/nsc2019new/nsc2019sumstats.do 0
  if do not want to merge k12 to nsc again

  type:
  do $projdir/do/share/outcomesumstats/nsc2019new/nsc2019sumstats.do 1
  if want to re-run the k12 nsc merge
 */

args dok12nscmerge
clear all
set more off
set varabbrev off, perm

local nsc2019provisonalxwalk "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/crosswalks/nsc_2019cde_provisional_outcomes_crosswalk_ssid.dta"
local nsc2019finalxwalk "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/crosswalks/nsc_2019cde_final_outcomes_crosswalk_ssid.dta"
local k12_test_scores_dir "/home/research/ca_ed_lab/msnaven/data/restricted_access/clean/k12_test_scores"



if `dok12nscmerge' == 1 {
  include $projdir/do/share/outcomesumstats/nsc2019new/k12_nsc2019_merge.doh
}

local k12_nsc_2019_provisional_merge "$projdir/dta/outcomesumstats/k12_nsc_2019_provisional_merge"
local k12_nsc_2019_final_merge "$projdir/dta/outcomesumstats/k12_nsc_2019_final_merge"


********************************************************************************
***** sum stats for NSC 2019 provisional and final dataset outcomes
local nsc2019datasets provisional final
foreach dataset of local nsc2019datasets {
  use $projdir/dta/outcomesumstats/k12_nsc_2019_`dataset'_merge, clear

  //CDE naming convention for years is the year of spring semester, so 2016 11th graders is the 2017 graduating cohort, etc.
  //note: this 2019 dataset is for 2018 11th graders (2019 graduating cohort)
  cls
  local year 2018
  //summary stats for 11th graders in 2019 conditional on matching to NSC outcomes 2019 provisional dataset

    //year == 2018, i.e. 2018 11th graders and 2019 graduating cohort
    di `year'
    sum nsc* if k12_nsc_match == 1 & grade == 11 & year == `year' & all_students_sample == 1

  translate @Results $projdir/out/txt/outcomesumstats/nsc2019new/nsc_2019_`dataset'_sumstats_matching.txt, replace
  cls

  //summary stats for 11th graders in conventional schools in 2019 to 2010 conditional on matching to NSC outcomes 2019 provisional dataset

  di `year'
    sum nsc* if k12_nsc_match == 1 & grade == 11 & year == `year' & all_students_sample == 1 & conventional_school == 1

  translate @Results $projdir/out/txt/outcomesumstats/nsc2019new/nsc_2019_`dataset'_sumstats_matching_convschl.txt, replace
  cls

  //replace NSC outcomes on unmatched observations with zero
  foreach var of varlist nsc* {
    replace `var' = 0 if k12_nsc_match == 0
  }
  cls

  /* summary stats for 11th graders in 2019 to 2010 in merged k12 NSC outcomes 2019 provisional dataset regardless of matching status
  after replacing unmatched observations with 0 */
  di `year'
    sum nsc* if grade == 11 & year == `year' & all_students_sample == 1

  translate @Results $projdir/out/txt/outcomesumstats/nsc2019new/nsc_2019_`dataset'_sumstats_all.txt, replace
  cls

  /* summary stats for 11th graders in conventional schools in 2019 to 2010 in merged k12 NSC outcomes 2019 provisional dataset regardless of matching status
  after replacing unmatched observations with 0 */

    di `year'
    sum nsc* if grade == 11 & year == `year' & all_students_sample == 1 & conventional_school == 1

  translate @Results $projdir/out/txt/outcomesumstats/nsc2019new/nsc_2019_`dataset'_sumstats_all_convschl.txt, replace
  cls

  /* //summary stats for 11th graders in 2019 to 2010 conditional on matching to NSC outcomes 2019 provisional dataset
  forvalues year = 2019(-1)2010 {
    di `year'
    sum nsc* if k12_nsc_match == 1 & grade == 11 & year == `year' & all_students_sample == 1
  }
  translate @Results $projdir/out/txt/outcomesumstats/nsc2019new/nsc_2019_`dataset'_sumstats_matching.txt, replace
  cls

  //summary stats for 11th graders in conventional schools in 2019 to 2010 conditional on matching to NSC outcomes 2019 provisional dataset
  forvalues year = 2019(-1)2010 {
    di `year'
    sum nsc* if k12_nsc_match == 1 & grade == 11 & year == `year' & all_students_sample == 1 & conventional_school == 1
  }
  translate @Results $projdir/out/txt/outcomesumstats/nsc2019new/nsc_2019_`dataset'_sumstats_matching_convschl.txt, replace
  cls

  //replace NSC outcomes on unmatched observations with zero
  foreach var of varlist nsc* {
    replace `var' = 0 if k12_nsc_match == 0
  }
  cls

  /* summary stats for 11th graders in 2019 to 2010 in merged k12 NSC outcomes 2019 provisional dataset regardless of matching status
  after replacing unmatched observations with 0 */
  forvalues year = 2019(-1)2010 {
    di `year'
    sum nsc* if grade == 11 & year == `year' & all_students_sample == 1
  }
  translate @Results $projdir/out/txt/outcomesumstats/nsc2019new/nsc_2019_`dataset'_sumstats_all.txt, replace
  cls

  /* summary stats for 11th graders in conventional schools in 2019 to 2010 in merged k12 NSC outcomes 2019 provisional dataset regardless of matching status
  after replacing unmatched observations with 0 */
  forvalues year = 2019(-1)2010 {
    di `year'
    sum nsc* if grade == 11 & year == `year' & all_students_sample == 1 & conventional_school == 1
  }
  translate @Results $projdir/out/txt/outcomesumstats/nsc2019new/nsc_2019_`dataset'_sumstats_all_convschl.txt, replace
  cls */
}
