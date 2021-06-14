********************************************************************************
************** build secondary survey demographics datasets ********************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* This do file creates secondary survey demographics datasets by merging survey demographics
with enrollment data to check the coverage and representativeness of secondary surveys */


clear
set more off

********************************************************************************
/* the following block renames variables in the secondary datasets. THis creates temp datasets to build
demographics datasets from in the following block of code */

local runsecblock = 0
if `runsecblock' == 1 {
  use $clndtadir/secondary/sec1415, clear
  rename a4 sex
  label var sex "sex of student"
  rename a5 selfreportgrade
  label var selfreportgrade "self-reported grade"
  rename a6 hispanic
  label var hispanic "the student is hispanic or latino"
  rename a7 race
  label var race "race of student"
  save $projdir/dta/demographics/temp/secondary/sec1415temp, replace


  use $clndtadir/secondary/sec1516, clear
  rename a4 sex
  label var sex "sex of student"
  rename a5 selfreportgrade
  label var selfreportgrade "self-reported grade"
  rename a6 hispanic
  label var hispanic "the student is hispanic or latino"
  rename a7 race
  label var race "race of student"
  save $projdir/dta/demographics/temp/secondary/sec1516temp, replace


  use $clndtadir/secondary/sec1617, clear
  rename a3 sex
  label var sex "sex of student"
  rename a4 selfreportgrade
  label var selfreportgrade "self-reported grade"
  rename a5 hispanic
  label var hispanic "the student is hispanic or latino"
  rename a6 race
  label var race "race of student"
  save $projdir/dta/demographics/temp/secondary/sec1617temp, replace


  /* note: sec1718 and 1819 also  has a self reported gender variable, includes trans,nb, or questioning as an option */

  use $clndtadir/secondary/sec1718, clear
  rename a3 sex
  label var sex "sex of student"
  rename a4 selfreportgrade
  label var selfreportgrade "self-reported grade"
  rename a5 hispanic
  label var hispanic "the student is hispanic or latino"
  rename a6 race
  label var race "race of student"
  save $projdir/dta/demographics/temp/secondary/sec1718temp, replace


  use $clndtadir/secondary/sec1819, clear
  rename a3 sex
  label var sex "sex of student"
  rename a4 selfreportgrade
  label var selfreportgrade "self-reported grade"
  rename a5 hispanic
  label var hispanic "the student is hispanic or latino"
  rename a6 race
  label var race "race of student"
  save $projdir/dta/demographics/temp/secondary/sec1819temp, replace

}







********************************************************************************
/* The following block of code builds secondary survey demographics dataset and merges with enrollment dataset */

local years `" "1415" "1516" "1617" "1718" "1819" "' //local macro for dataset years, only care about last 5 years right now

foreach year of local years {
  use $clndtadir/demographics/temp/secondary/sec`year'temp, clear

  /* gaenerate variables indicating the sex of each student */

  // NOte: in secondary datasets the var sex equals 1 if male and 2 if female
  gen byte female = 0
  replace female = 1 if sex == 2

  gen byte male = 0
  replace male = 1 if sex == 1

  /* generate variables indicating each grade */
  /* value label of grade var:
  6: 6th grade
  7: 7th grade
  8: 8th grade
  9: 9th grade
  10: 10th grade
  11: 11th grade
  12: 12th grade
  13: non traditional  */

  gen byte gr6 = 0
  gen byte gr7 = 0
  gen byte gr8 = 0
  gen byte gr9 = 0
  gen byte gr10 = 0
  gen byte gr11 = 0
  gen byte gr12 = 0
  gen byte grnt = 0

  replace gr6 = 1 if grade == 6 //note: the grade variable here is adjusted by CBEDS enrollment
  replace gr7 = 1 if grade == 7
  replace gr8 = 1 if grade == 8
  replace gr9 = 1 if grade == 9
  replace gr10 = 1 if grade == 10
  replace gr11 = 1 if grade == 11
  replace gr12 = 1 if grade == 12
  replace grnt = 1 if grade == 13 //grnt is a dummy var for non traditioanl student

  /* generate vars for number of female and male students in each grade */
  gen byte femalegr6 = 0
  replace femalegr6 = 1 if female == 1 & gr6 == 1
  gen byte femalegr7 = 0
  replace femalegr7 = 1 if female == 1 & gr7 == 1
  gen byte femalegr8 = 0
  replace femalegr8 = 1 if female == 1 & gr8 == 1
  gen byte femalegr9 = 0
  replace femalegr9 = 1 if female == 1 & gr9 == 1
  gen byte femalegr10 = 0
  replace femalegr10 = 1 if female == 1 & gr10 == 1
  gen byte femalegr11 = 0
  replace femalegr11 = 1 if female == 1 & gr11 == 1
  gen byte femalegr12 = 0
  replace femalegr12 = 1 if female == 1 & gr12 == 1
  gen byte femalegrnt = 0
  replace femalegrnt = 1 if female == 1 & grnt == 1

  gen byte malegr6 = 0
  replace malegr6 = 1 if male == 1 & gr6 == 1
  gen byte malegr7 = 0
  replace malegr7 = 1 if male == 1 & gr7 == 1
  gen byte malegr8 = 0
  replace malegr8 = 1 if male == 1 & gr8 == 1
  gen byte malegr9 = 0
  replace malegr9 = 1 if male == 1 & gr9 == 1
  gen byte malegr10 = 0
  replace malegr10 = 1 if male == 1 & gr10 == 1
  gen byte malegr11 = 0
  replace malegr11 = 1 if male == 1 & gr11 == 1
  gen byte malegr12 = 0
  replace malegr12 = 1 if male == 1 & gr12 == 1
  gen byte malegrnt = 0
  replace malegrnt = 1 if male == 1 & grnt == 1

  /* generate vars for number of students by race in each grade */

  /* value label for hispanic:
  1: No
  2: Yes
  value label for race:
  1: American Indian or Alaska Native
  2: Asian
  3: Black or African American
  4: Native Hawaiian or Pacific Islander
  5: White
  6: Mixed (two or more) races */

  local grades `" "6" "7" "8" "9" "10" "11" "12" "nt" "' //generate a local macro for grades in the dataset
  foreach i of local grades {
    gen byte hispanicgr`i' = 0 // a dummy var for hispanic students in grade i
    replace hispanicgr`i' = 1 if hispanic == 2 & gr`i' == 1
    gen byte nativegr`i' = 0 //a dummy var for american indian or alaskan native students in grade i
    replace nativegr`i' = 1 if race == 1 & gr`i' == 1
    gen byte asiangr`i' = 0 //dummy var for asian students in grade i
    replace asiangr`i' = 1 if race == 2 & gr`i' == 1
    gen byte blackgr`i' = 0 //dummy var for black or african american students in grade i
    replace blackgr`i' = 1 if race == 3 & gr`i' == 1
    gen byte pacificgr`i' = 0 //dummy var for native hawaiian or pacific islander students in grade i
    replace pacificgr`i' = 1 if race == 4 & gr`i' == 1
    gen byte whitegr`i' = 0 //a dummuy var for white students in grade i
    replace whitegr`i' = 1 if race == 5 & gr`i' == 1
    gen byte mixedgr`i' = 0 //dummy var for mixed (two or more) races students in grade i
    replace mixedgr`i' = 1 if race == 6 & gr`i' == 1
  }

  //collapse by sum of these dummy vars to get the number of each category of students for each school
  collapse (sum) female male gr6 gr7 gr8 gr9 gr10 gr11 gr12 grnt ///
  femalegr6 femalegr7 femalegr8 femalegr9 femalegr10 femalegr11 femalegr12 femalegrnt ///
  malegr6 malegr7 malegr8 malegr9 malegr10 malegr11 malegr12 malegrnt ///
  hispanicgr6 hispanicgr7 hispanicgr8 hispanicgr9 hispanicgr10 hispanicgr11 hispanicgr12 hispanicgrnt ///
  nativegr6 nativegr7 nativegr8 nativegr9 nativegr10 nativegr11 nativegr12 nativegrnt ///
  asiangr6 asiangr7 asiangr8 asiangr9 asiangr10 asiangr11 asiangr12 asiangrnt ///
  blackgr6 blackgr7 blackgr8 blackgr9 blackgr10 blackgr11 blackgr12 blackgrnt ///
  pacificgr6 pacificgr7 pacificgr8 pacificgr9 pacificgr10 pacificgr11 pacificgr12 pacificgrnt ///
  whitegr6 whitegr7 whitegr8 whitegr9 whitegr10 whitegr11 whitegr12 whitegrnt ///
  mixedgr6 mixedgr7 mixedgr8 mixedgr9 mixedgr10 mixedgr11 mixedgr12 mixedgrnt, by(cdscode)

  rename female svyfemale
  rename male svymale
  label var svyfemale "number of female students in the survey"
  label var svymale "number of male students in the survey"

  foreach i of local grades {
    rename gr`i' svygr`i'
    label var svygr`i' "number of students in grade `i' in survey"
    rename femalegr`i' svyfemalegr`i'
    label var svyfemalegr`i' "number of female students in grade `i' in survey"
    rename malegr`i' svymalegr`i'
    label var svymalegr`i' "number of male students in grade `i' in survey"

    rename hispanicgr`i' svyhispanicgr`i'
    label var svyhispanicgr`i' "number of Hispanic students in grade `i' in the survey"
    rename nativegr`i' svynativegr`i'
    label var svynativegr`i' "number of Native American students in grade `i' in the survey"
    rename asiangr`i' svyasiangr`i'
    label var svyasiangr`i' "number of Asian students in grade `i' in the survey"
    rename blackgr`i' svyblackgr`i'
    label var svyblackgr`i' "number of black students in grade `i' in the survey"
    rename pacificgr`i' svypacificgr`i'
    label var svypacificgr`i' "number of Pacific Islander students in grade `i' in the survey"
    rename whitegr`i' svywhitegr`i'
    label var svywhitegr`i' "number of white students in grade `i' in the survey"
    rename mixedgr`i' svymixedgr`i'
    label var svymixedgr`i' "number of mixed race students in grade `i' in the survey"
  }


  //rename the non traditional student vars
  label var svygrnt "number of non-traditional students in survey"
  label var svyfemalegrnt "number of non-traditional female students in survey"
  label var svymalegrnt "number of non-traditioanl male students in survey"

  label var svyhispanicgrnt "number of Hispanic non-traditional students in survey"
  label var svynativegrnt "number of Native American non-traditional students in survey"
  label var svyasiangrnt "number of Asian non-traditional students in survey"
  label var svyblackgrnt "number of black non-traditional students in survey"
  label var svypacificgrnt "number of Pacific Islander non-traditional students in survey"
  label var svywhitegrnt "number of white non-traditional students in survey"
  label var svymixedgrnt "number of mixed-race non-traditional students in survey"

  drop if missing(cdscode) //drop observations with missing cdscode

  merge 1:1 cdscode using $clndtadir/enrollment/schoollevel/enr`year' //merge with frequency dataset (number of surveys for each school)
  drop if _merge != 3 //drop all observations that are not matched
  drop _merge

  compress //compress dataset to save memory
  save $clndtadir/demographics/secondary/secdemo`year', replace

}
