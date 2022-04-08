********************************************************************************
/* clean and pull school characteristics from the dataset created by Matt Naven, for use in
VA regressions with index + school characteristics  */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
cap log close _all
clear all
set more off

log using $projdir/log/share/factoranalysis/mattschlchar.smcl, replace

// a macro toggle for cleaning the raw data from Matt's folder
local clean = 0
if `clean' == 1 {
  use /home/research/ca_ed_lab/msnaven/common_core_va/data/sch_char, clear

  rename enr_total enrtotal
  label var enrtotal "total enrollment"

  rename enr_minority_prop minorityenrprop
  label var minorityenrprop "proportion of minority enrollment"

  rename enr_male_prop maleenrprop
  label var maleenrprop "proportion of male enrollment"

  rename frpm_prop freemealprop
  label var freemealprop "proportion eleigible for free or reduced price meals"

  drop el_prop

  rename male_prop maleteachprop
  label var maleteachprop "proportion of male teachers"

  rename eth_minority_prop minoritystaffprop
  label var minoritystaffprop "proportion of minority staff"

  rename new_teacher_prop newteachprop
  label var newteachprop "proportion of teachers with less than or equal to 3 years experience"

  rename credential_full_prop fullcredprop
  label var fullcredprop "proprotion of full credential"

  rename fte_teach fteteach
  label var fteteach "number of FTE teachers"

  rename fte_admin fteadmin
  label var fteadmin "number of FTE administrators"

  rename fte_pupil ftepupil
  label var ftepupil "number of FTE pupils"

  rename fte_teach_pc fteteachperstudent
  label var fteteachperstudent "FTE teacher per student"

  rename fte_admin_pc fteadminperstudent
  label var fteadminperstudent "FTE admin per student"

  rename fte_pupil_pc fteserviceperstudent
  label var fteserviceperstudent "FTE pupil service per student"

  label data "School Characterstics data by Matt Naven, cleaned by Che Sun"

  save $projdir/dta/schoolchar/mattschlchar, replace
}

//create elprop by collapsing student test score data to avoid missing data problem in the CDE school level dataset
use cdscode year limited_eng_prof all_students_sample ///
if all_students_sample==1 & inrange(year, 2015, 2017) ///
using $vaprojdir/data/restricted_access/clean/k12_test_scores/k12_test_scores_clean.dta, clear
collapse elprop = limited_eng_prof, by(cdscode year)
collapse elprop, by(cdscode)
drop if missing(cdscode)
label var elprop "proportion of English Leaners"
compress
label data "Proportion of English Learners from collapsing student level test score dataset"
save $projdir/dta/schoolchar/elprop, replace



use $projdir/dta/schoolchar/mattschlchar, clear

// keep observations from 14-15 to 16-17 to condition on the same year as VA estimates since year is the year of spring semester
keep if inrange(year, 2015, 2017)
drop if missing(cdscode)

drop enrtotal fteteach fteadmin ftepupil

collapse *prop fte*, by(cdscode)

merge 1:1 cdscode using $projdir/dta/schoolchar/elprop
//keep only merged obs
keep if _merge==3
drop _merge

label data "Pooled average over 14-15 to 16-17 school characteristics data"
compress
save $projdir/dta/schoolchar/schlcharpooledmeans, replace


log close
translate $projdir/log/share/factoranalysis/mattschlchar.smcl $projdir/log/share/factoranalysis/mattschlchar.log, replace
