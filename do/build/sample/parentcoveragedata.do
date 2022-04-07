********************************************************************************
************ generate vars that investigate parent survey coverage *************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* THis do file uses parent  demographics datasets (merged with enrollment data) to
investigate survey coverage and representativeness*/
cap log close _all
clear
set more off

log using $projdir/log/build/sample/parentcoveragedata.smcl, replace

local years `" "1415" "1516" "1617" "1718" "1819" "' //local macro for elementary dataset years

foreach year of local years {
  use $projdir/dta/demographics/parent/parentdemo`year', clear

  ******************************************************************************
  *********************generate survey response rates **************************
  ******************************************************************************

  local grades `" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "' //local macro for kids' grades in parent survey, kindergarten enrollment not included so omit
  foreach i of local grades {
    //generate a new var that calculates kids in each grade whose parents answered the survey as a percentage of total enrollment in that grade (i.e. response rate)
    gen svygr`i'resprate = .a
    label var svygr`i'resprate "response rate for households with kids in grade `i'"
    //make sure denominator is not 0 when calculating response rate
    replace svygr`i'resprate = svygr`i'/gr`i'enr if gr`i'enr != 0
    //label extended missing values for the cases where enrollment is 0
    label define svygr`i'resprate .a "grade `i' enrollment is 0"
  }

  compress //compress dataset to save memory
  label data "Parent `year' demographics data with survey coverage analysis variables"
  save $projdir/dta/demographics/analysis/parent/parentdemo`year'analysis, replace
}

log close
translate $projdir/log/build/sample/parentcoveragedata.smcl $projdir/log/build/sample/parentcoveragedata.log, replace 
