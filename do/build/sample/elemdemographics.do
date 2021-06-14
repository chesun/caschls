********************************************************************************
******************** build elementary survey demographics datasets *************************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* This do file creates elementary survey demographics datasets by merging survey demographics
with enrollment data to check the coverage and representativeness of elementary surveys */


clear
set more off


/* The following block of code rename sex and self reported grade variables to be consistent across datasets. THis creates temp datasets to build
demographics datasets from in the following block of code */
local runelemrename = 0 //a macro toggle for renamign variables
if `runelemrename' == 1 {
  use $clndtadir/elementary/elem1415, clear
  rename ele3 sex
  label var sex "Sex of student"
  rename ele4 selfreportgrade
  label var selfreportgrade "Self-reported grade"
  save $projdir/dta/demographics/temp/elementary/elem1415temp, replace

  use $clndtadir/elementary/elem1516, clear
  rename ele3 sex
  label var sex "Sex of student"
  rename ele4 selfreportgrade
  label var selfreportgrade "Self-reported grade"
  save $projdir/dta/demographics/temp/elementary/elem1516temp, replace

  use $clndtadir/elementary/elem1617, clear
  rename ele2 sex
  label var sex "Sex of student"
  rename ele3 selfreportgrade
  label var selfreportgrade "Self-reported grade"
  save $projdir/dta/demographics/temp/elementary/elem1617temp, replace

  use $clndtadir/elementary/elem1718, clear
  rename ele2 sex
  label var sex "Sex of student"
  rename ele3 selfreportgrade
  label var selfreportgrade "Self-reported grade"
  save $projdir/dta/demographics/temp/elementary/elem1718temp, replace

  use $clndtadir/elementary/elem1819, clear
  rename ele2 sex
  label var sex "Sex of student"
  rename ele3 selfreportgrade
  label var selfreportgrade "Self-reported grade"
  save $projdir/dta/demographics/temp/elementary/elem1819temp, replace

}


/* The following block of code builds elementary survey demographics dataset and merges with enrollment dataset */

local years `" "1415" "1516" "1617" "1718" "1819" "' //local macro for dataset years

 foreach i of local years {
   use $projdir/dta/demographics/temp/elementary/elem`i'temp, clear

   /* gaenerate variables indicating the sex of each student */
   // Note: in elementary datasets the var sex = 1 if female and 2 if male

   gen byte female = 0
   replace female = 1 if sex == 1

   gen byte male = 0
   replace male = 1 if sex == 2

   /* generate variables indicating each grade */
   gen byte gr3 = 0
   gen byte gr4 = 0
   gen byte gr5 = 0
   gen byte gr6 = 0

   replace gr3 = 1 if grade == 3 //note: the grade variable here is adjusted by CBEDS enrollment
   replace gr4 = 1 if grade == 4
   replace gr5 = 1 if grade == 5
   replace gr6 = 1 if grade == 6

   /* generate vars for number of female and male students in each grade */
   gen byte femalegr3 = 0
   replace femalegr3 = 1 if female == 1 & gr3 == 1
   gen byte femalegr4 = 0
   replace femalegr4 = 1 if female == 1 & gr4 == 1
   gen byte femalegr5 = 0
   replace femalegr5 = 1 if female == 1 & gr5 == 1
   gen byte femalegr6 = 0
   replace femalegr6 = 1 if female == 1 & gr6 == 1

   gen byte malegr3 = 0
   replace malegr3 = 1 if male == 1 & gr3 == 1
   gen byte malegr4 = 0
   replace malegr4 = 1 if male == 1 & gr4 == 1
   gen byte malegr5 = 0
   replace malegr5 = 1 if male == 1 & gr5 == 1
   gen byte malegr6 = 0
   replace malegr6 = 1 if male == 1 & gr6 == 1


   collapse (sum) female male gr3 gr4 gr5 gr6 femalegr3 femalegr4 femalegr5 femalegr6 malegr3 malegr4 malegr5 malegr6, by(cdscode)

   rename female svyfemale
   label var svyfemale "number of female students in the survey"
   rename male svymale
   label var svymale "number of male students in the survey"

   rename gr3 svygr3
   rename gr4 svygr4
   rename gr5 svygr5
   rename gr6 svygr6

   label var svygr3 "number of students in grade 3 in survey"
   label var svygr4 "number of students in grade 4 in survey"
   label var svygr5 "number of students in grade 5 in survey"
   label var svygr6 "number of students in grade 6 in survey"

   rename femalegr3 svyfemalegr3
   rename femalegr4 svyfemalegr4
   rename femalegr5 svyfemalegr5
   rename femalegr6 svyfemalegr6

   label var svyfemalegr3 "number of female students in grade 3 in survey"
   label var svyfemalegr4 "number of female students in grade 4 in survey"
   label var svyfemalegr5 "number of female students in grade 5 in survey"
   label var svyfemalegr6 "number of female students in grade 6 in survey"

   rename malegr3 svymalegr3
   rename malegr4 svymalegr4
   rename malegr5 svymalegr5
   rename malegr6 svymalegr6

   label var svymalegr3 "number of male students in grade 3 in survey"
   label var svymalegr4 "number of male students in grade 4 in survey"
   label var svymalegr5 "number of male students in grade 5 in survey"
   label var svymalegr6 "number of male students in grade 6 in survey"


   drop if missing(cdscode) //drop observations with missing cdscode

   merge 1:1 cdscode using $projdir/dta/enrollment/schoollevel/enr`i' //merge with frequency dataset (number of surveys for each school)
   drop if _merge != 3 //drop all observations that are not matched
   drop _merge

   compress //compress dataset to save memory
   save $projdir/dta/demographics/elementary/elemdemo`i', replace

 }
