********************************************************************************
************** build parent survey demographics datasets ********************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* This do file creates parent survey demographics datasets by merging survey demographics
with enrollment data to check the coverage and representativeness of parent surveys. THe main
diagnostic in parent demographics is the grade of the child. The goal is to calculate the response rate
in each grade. Here each household enters one observation (source: Ben from WestEd) */

/* NOTE: parent1415 data do not have grade 7 observations. grade = -8 has 1327 observations which might be 7th grade, but cannot be sure */
cap log close _all
clear all
set more off

log using $projdir/log/build/sample/parentdemographics.smcl, replace

/* The following block of code rename child's grade to be consistent across datasets. THis creates temp datasets to build
demographics datasets from in the following block of code */
local runparentname = 0 //a macro toggle for rename variables
if `runparentname' == 1 {
  use $clndtadir/parent/parent1415, clear
  gen childgr = q6
  label var childgr "grade of the child"
  label define childgr 1 "kindergarten" 2 "grade 1" 3 "grade 2" 4 "grade 3" 5 "grade 4" 6 "grade 5" ///
  7 "grade 6" 8 "grade 7" 9 "grade 8" 10 "grade 9" 11 "grade 10" 12 "grade 11" 13 "grade 12" 14 "other" 15 "ungraded"
  label values childgr childgr //assign value label
  save $projdir/dta/demographics/temp/parent/parent1415temp, replace

  use $clndtadir/parent/parent1516, clear
  gen childgr = p7
  label var childgr "grade of the child"
  label define childgr 1 "kindergarten" 2 "grade 1" 3 "grade 2" 4 "grade 3" 5 "grade 4" 6 "grade 5" ///
  7 "grade 6" 8 "grade 7" 9 "grade 8" 10 "grade 9" 11 "grade 10" 12 "grade 11" 13 "grade 12" 14 "other" 15 "ungraded"
  label values childgr childgr //assign value label
  save $projdir/dta/demographics/temp/parent/parent1516temp, replace

  use $clndtadir/parent/parent1617, clear
  gen childgr = p7
  label var childgr "grade of the child"
  label define childgr 1 "kindergarten" 2 "grade 1" 3 "grade 2" 4 "grade 3" 5 "grade 4" 6 "grade 5" ///
  7 "grade 6" 8 "grade 7" 9 "grade 8" 10 "grade 9" 11 "grade 10" 12 "grade 11" 13 "grade 12" 14 "other" 15 "ungraded"
  label values childgr childgr //assign value label
  save $projdir/dta/demographics/temp/parent/parent1617temp, replace

  use $clndtadir/parent/parent1718, clear
  gen childgr = p7
  label var childgr "grade of the child"
  label define childgr 1 "kindergarten" 2 "grade 1" 3 "grade 2" 4 "grade 3" 5 "grade 4" 6 "grade 5" ///
  7 "grade 6" 8 "grade 7" 9 "grade 8" 10 "grade 9" 11 "grade 10" 12 "grade 11" 13 "grade 12" 14 "other" 15 "ungraded"
  label values childgr childgr //assign value label
  save $projdir/dta/demographics/temp/parent/parent1718temp, replace

  use $clndtadir/parent/parent1819, clear
  gen childgr = p7
  label var childgr "grade of the child"
  label define childgr 1 "kindergarten" 2 "grade 1" 3 "grade 2" 4 "grade 3" 5 "grade 4" 6 "grade 5" ///
  7 "grade 6" 8 "grade 7" 9 "grade 8" 10 "grade 9" 11 "grade 10" 12 "grade 11" 13 "grade 12" 14 "other" 15 "ungraded"
  label values childgr childgr //assign value label
  save $projdir/dta/demographics/temp/parent/parent1819temp, replace
}

/* The following block of code builds parent survey demographics dataset and merges with enrollment dataset */

local years `" "1415" "1516" "1617" "1718" "1819" "' //local macro for dataset years

 foreach year of local years {
   use $projdir/dta/demographics/temp/parent/parent`year'temp, clear

   //generate indicator variables for kids in each grade
   gen byte grk = 0 //dummy for whether kid is in kindergarten
   gen byte gr1 = 0
   gen byte gr2 = 0
   gen byte gr3 = 0
   gen byte gr4 = 0
   gen byte gr5 = 0
   gen byte gr6 = 0
   gen byte gr7 = 0
   gen byte gr8 = 0
   gen byte gr9 = 0
   gen byte gr10 = 0
   gen byte gr11 = 0
   gen byte gr12 = 0

   replace grk = 1 if childgr == 1
   replace gr1 = 1 if childgr == 2
   replace gr2 = 1 if childgr == 3
   replace gr3 = 1 if childgr == 4
   replace gr4 = 1 if childgr == 5
   replace gr5 = 1 if childgr == 6
   replace gr6 = 1 if childgr == 7
   replace gr7 = 1 if childgr == 8
   replace gr8 = 1 if childgr == 9
   replace gr9 = 1 if childgr ==10
   replace gr10 = 1 if childgr == 11
   replace gr11 = 1 if childgr == 12
   replace gr12 = 1 if childgr == 13

   collapse (sum) grk gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9 gr10 gr11 gr12, by(cdscode)

   local grades `" "k" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "' //local macro for kids' grades in parent survey
   foreach i of local grades {
     rename gr`i' svygr`i'
     label var svygr`i' "number of households with child in grade `i'"
   }
   label var svygrk "number of households with child in kindergarten" //relabel for kindergarten

   drop if missing(cdscode) //drop observations with missing cdscode

   merge 1:1 cdscode using $projdir/dta/enrollment/schoollevel/enr`year' //merge with frequency dataset (number of surveys for each school)
   drop if _merge != 3 //drop all observations that are not matched
   drop _merge

   compress //compress dataset to save memory
   save $projdir/dta/demographics/parent/parentdemo`year', replace

   }

   log close
   translate $projdir/log/build/sample/parentdemographics.smcl $projdir/log/build/sample/parentdemographics.log, replace 
