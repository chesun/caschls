********************************************************************************
/* check which schools administer surveys semi-regularly (some every year, others every other year)
This do file supercedes sameschools.do and schooloverlap.do */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
/* to run this do file, type:
do $projdir/do/check/schoolbyyear
 */

clear all
set more off


local years 1415 1516 1617 1718 1819

********************************************************************************
/* Check secondary survey data  */
********************************************************************************
// create datasets with only cdscode, number of responses, and year for each year's survey data
foreach i of local years {
  use $clndtadir/secondary/sec`i', clear
  drop if mi(cdscode)
  //create a var for the number of responses in each school in the survey year
  bysort cdscode: gen numobs_`i'=_N
  collapse numobs_`i', by(cdscode)
  gen svy`i' = 1

  label var numobs_`i' "Number of observations in `i' survey"
  label var svy`i' "Fielded `i' Survey"

  label data "Dataset for secondary `i' survey with observation counts for each school"
  compress
  save $projdir/dta/schoolbyyear/secondary/sec`i'_count, replace

}

//merge all the observation count datasets
use $projdir/dta/schoolbyyear/secondary/sec1415_count, clear
local mergeyears 1516 1617 1718 1819
foreach i of local mergeyears {
  merge 1:1 cdscode using $projdir/dta/schoolbyyear/secondary/sec`i'_count
  drop _merge
}

//recode the missing as 0 for the observation count and svy year indicators
foreach i of local years {
  replace numobs_`i' = 0 if numobs_`i'==.
  replace svy`i' = 0 if svy`i'==.
}

//organizae the variable orders
order cdscode numobs_1415 numobs_1516 numobs_1617 numobs_1718 numobs_1819 svy1415 svy1516 svy1617 svy1718 svy1819

//generate dummies for fielding surveys regularly
gen svyallyears = 0
replace svyallyears = 1 if svy1415==1 & svy1516==1 & svy1617==1 & svy1718==1 & svy1819==1
label var svyallyears "Fielded survey every year from 1415 to 1819"

gen svy1415_1617_1819 = 0
replace svy1415_1617_1819 = 1 if svy1415==1 & svy1516==0 & svy1617==1 & svy1718==0 & svy1819==1
label var svy1415_1617_1819 "Fielded survey only in 1415, 1617, and 1819"

gen svy1516_1718 = 0
replace svy1516_1718 = 1 if svy1415==0 & svy1516==1 & svy1617==0 & svy1718==1 & svy1819==0
label var svy1516_1718 "Fielded survey only in 1516 and 1718"

//tab these survey regularity vars and output cmd window results to txt files
cls
tab svyallyears
tab svy1415_1617_1819
tab svy1516_1718
translate @Results $projdir/out/txt/schoolbyyear/sec_regularity.txt, replace


save $projdir/dta/schoolbyyear/secondary/sec_schoolbyyear_all, replace




********************************************************************************
/* Check parent survey data  */
********************************************************************************
// create datasets with only cdscode, number of responses, and year for each year's survey data
foreach i of local years {
  use $clndtadir/parent/parent`i', clear
  drop if mi(cdscode)
  //create a var for the number of responses in each school in the survey year
  bysort cdscode: gen numobs_`i'=_N
  collapse numobs_`i', by(cdscode)
  gen svy`i' = 1

  label var numobs_`i' "Number of observations in `i' survey"
  label var svy`i' "Fielded `i' Survey"

  label data "Dataset for parent `i' survey with observation counts for each school"
  compress
  save $projdir/dta/schoolbyyear/parent/parent`i'_count, replace

}

//merge all the observation count datasets
use $projdir/dta/schoolbyyear/parent/parent1415_count, clear
foreach i of local mergeyears {
  merge 1:1 cdscode using $projdir/dta/schoolbyyear/parent/parent`i'_count
  drop _merge
}

//organizae the variable orders
order cdscode numobs_1415 numobs_1516 numobs_1617 numobs_1718 numobs_1819 svy1415 svy1516 svy1617 svy1718 svy1819

//generate dummies for fielding surveys regularly
gen svyallyears = 0
replace svyallyears = 1 if svy1415==1 & svy1516==1 & svy1617==1 & svy1718==1 & svy1819==1
label var svyallyears "Fielded survey every year from 1415 to 1819"

gen svy1415_1617_1819 = 0
replace svy1415_1617_1819 = 1 if svy1415==1 & svy1516==0 & svy1617==1 & svy1718==0 & svy1819==1
label var svy1415_1617_1819 "Fielded survey only in 1415, 1617, and 1819"

gen svy1516_1718 = 0
replace svy1516_1718 = 1 if svy1415==0 & svy1516==1 & svy1617==0 & svy1718==1 & svy1819==0
label var svy1516_1718 "Fielded survey only in 1516 and 1718"

//tab these survey regularity vars and output cmd window results to txt files
cls
tab svyallyears
tab svy1415_1617_1819
tab svy1516_1718
translate @Results $projdir/out/txt/schoolbyyear/parent_regularity.txt, replace

save $projdir/dta/schoolbyyear/parent/parent_schoolbyyear_all, replace



********************************************************************************
/* Check staff survey data  */
********************************************************************************
// create datasets with only cdscode, number of responses, and year for each year's survey data
foreach i of local years {
  use $clndtadir/staff/staff`i', clear
  drop if mi(cdscode)
  //create a var for the number of responses in each school in the survey year
  bysort cdscode: gen numobs_`i'=_N
  collapse numobs_`i', by(cdscode)
  gen svy`i' = 1

  label var numobs_`i' "Number of observations in `i' survey"
  label var svy`i' "Fielded `i' Survey"

  label data "Dataset for staff `i' survey with observation counts for each school"
  compress
  save $projdir/dta/schoolbyyear/staff/staff`i'_count, replace

}


//merge all the observation count datasets
use $projdir/dta/schoolbyyear/staff/staff1415_count, clear
foreach i of local mergeyears {
  merge 1:1 cdscode using $projdir/dta/schoolbyyear/staff/staff`i'_count
  drop _merge
}

//organizae the variable orders
order cdscode numobs_1415 numobs_1516 numobs_1617 numobs_1718 numobs_1819 svy1415 svy1516 svy1617 svy1718 svy1819

//generate dummies for fielding surveys regularly
gen svyallyears = 0
replace svyallyears = 1 if svy1415==1 & svy1516==1 & svy1617==1 & svy1718==1 & svy1819==1
label var svyallyears "Fielded survey every year from 1415 to 1819"

gen svy1415_1617_1819 = 0
replace svy1415_1617_1819 = 1 if svy1415==1 & svy1516==0 & svy1617==1 & svy1718==0 & svy1819==1
label var svy1415_1617_1819 "Fielded survey only in 1415, 1617, and 1819"

gen svy1516_1718 = 0
replace svy1516_1718 = 1 if svy1415==0 & svy1516==1 & svy1617==0 & svy1718==1 & svy1819==0
label var svy1516_1718 "Fielded survey only in 1516 and 1718"

//tab these survey regularity vars and output cmd window results to txt files
cls
tab svyallyears
tab svy1415_1617_1819
tab svy1516_1718
translate @Results $projdir/out/txt/schoolbyyear/staff_regularity.txt, replace

save $projdir/dta/schoolbyyear/staff/staff_schoolbyyear_all, replace






********************************************************************************
/* Check elementary survey data  */
********************************************************************************
/* local runelem = 0
if `runelem' == 1 {
  foreach i of local years {
    use $clndtadir/elementary/elem`i', clear
    drop if mi(cdscode)
    //create a var for the number of responses in each school in the survey year
    bysort cdscode: gen numobs_`i'=_N
    collapse numobs_`i', by(cdscode)
    gen svyyear = "`i'"

    label var numobs_`i' "Number of observations in `i' survey"
    label var svyyear "Survey Year"

    label data "Dataset for elementary `i' survey with observation counts for each school"
    compress
    save $projdir/dta/schoolbyyear/elementary/elem`i'_count, replace

  }

} */
