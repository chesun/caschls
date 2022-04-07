********************************************************************************
/* merging trimmed parent demographics to generate conditional response rates */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************
cap log close _all
clear all
set more off

log using $projdir/log/build/buildanalysisdata/responserate/parentresponserate.smcl, replace

use $projdir/dta/buildanalysisdata/demotrim/parent/trimparentdemo1415, replace
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/demotrim/parent/trimparentdemo1516
/* matched: 346. not matched: 952 (from master: 389, from using: 363) */

drop _merge
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/demotrim/parent/trimparentdemo1617
/* matched: 559. not matched: 1278 (from master: 739, from using: 539) */

drop _merge
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/demotrim/parent/trimparentdemo1718
/* matched: 955. not matched: 1426 (from master: 882, from using: 544) */

drop _merge
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/demotrim/parent/trimparentdemo1819
/* matched: 1266. not matched: 1285 (from master: 1115, from using: 170) */

drop _merge

local grades `" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "' //local macro for grades
//recode the missing values for survey response as 0 since unmatched means there were no responses for that year
foreach i of local grades {
  replace svygr`i'_1415 = 0 if svygr`i'_1415 == .
  replace svygr`i'_1516 = 0 if svygr`i'_1516 == .
  replace svygr`i'_1617 = 0 if svygr`i'_1617 == .
  replace svygr`i'_1718 = 0 if svygr`i'_1718 == .
  replace svygr`i'_1819 = 0 if svygr`i'_1819 == .
}


/* generate indicators for which year each school had survey responses */
local years `" "1415" "1516" "1617" "1718" "1819" "' //local macro for survey years
//generate total survey responses for grades 1-12
foreach year of local years {
  gen svy`year' = svygr1_`year' + svygr2_`year' + svygr3_`year' + svygr4_`year' + svygr5_`year' + svygr6_`year' ///
  + svygr7_`year' + svygr8_`year' + svygr9_`year' + svygr10_`year' + svygr11_`year' + svygr12_`year'
  label var svy`year' "total survey response for grades 1-12 households in year `year'"
}
//generate total enrollment for grades 1-12
foreach year of local years {
  gen enr`year' = enrgr1_`year' + enrgr2_`year' + enrgr3_`year' + enrgr4_`year' + enrgr5_`year' + enrgr6_`year' ///
  + enrgr7_`year' + enrgr8_`year' + enrgr9_`year' + enrgr10_`year' + enrgr11_`year' + enrgr12_`year'
  label var enr`year' "total enrollment in grades 1-12 in year `year'"
}
//generate indicators for which years the school has survey responses
foreach year of local years {
  gen has`year' = 0
  replace has`year' = 1 if svy`year' > 0
  label var has`year' "has survey response in year `year'"
}

//generate overall response rate for each school including only years with survey responses
gen denomtemp = 0 //generate a temp var for the denominator of response rate
gen numertemp = 0 //generate a temp var for the numerator of response rate
//add up the number of survey responses and enrollment from all years with survey response
foreach year of local years {
  replace denomtemp = denomtemp + enr`year' if has`year' == 1
  replace numertemp = numertemp + svy`year' if has`year' == 1
}
//generate the pooled response rate only including years with responses
gen pooledrr = numertemp/denomtemp
label var pooledrr "pooled response rate for grades 1-12"
drop denomtemp numertemp

//generate pooled response rate for grades 9 and 11 for each school including only years with survey responses
gen denomtemp = 0 //generate a temp var for the denominator of response rate
gen numertemp = 0 //generate a temp var for the numerator of response rate
//add up the number of survey responses in grades 9 and 11 and enrollment for grades 9 and 11 from all years with survey response
foreach year of local years {
  replace denomtemp = denomtemp + enrgr9_`year' + enrgr11_`year' if has`year' == 1
  replace numertemp = numertemp + svygr9_`year' + svygr11_`year' if has`year' == 1
}
//generate the pooled response rate only including years with responses
gen pooledrr_gr9and11 = numertemp/denomtemp
label var pooledrr_gr9and11 "pooled response rate for grades 9 and 11"
drop denomtemp numertemp

label data "parent survey response numbers by grade year with pooled response rates"
compress
save $projdir/dta/buildanalysisdata/responserate/parentresponserate, replace

log close
translate $projdir/log/build/buildanalysisdata/responserate/parentresponserate.smcl $projdir/log/build/buildanalysisdata/responserate/parentresponserate.log, replace
