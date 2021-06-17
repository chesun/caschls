********************************************************************************
/* clean and pull school characteristics from the dataset created by Matt Naven, for use in
VA regressions with index + school characteristics  */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
clear all
set more off

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

  rename el_prop elprop
  label var elprop "proportion of English learners"

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



use $projdir/dta/schoolchar/mattschlchar, clear

// keep observations from 14-15 to 18-19 since year is the year of spring semester
keep if year >= 2015
drop if missing(cdscode)

drop enrtotal fteteach fteadmin ftepupil

collapse *prop fte*, by(cdscode)

label data "Pooled average over 14-15 to 17-18 school characteristics data by Matt Naven"

save $projdir/dta/schoolchar/schlcharpooledmeans, replace
