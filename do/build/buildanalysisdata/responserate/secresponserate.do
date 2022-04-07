********************************************************************************
/* merging trimmed secondary demographics to generate conditional response rates */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************
cap log close _all
clear all
set more off

log using $projdir/log/build/buildanalysisdata/responserate/secresponserate.smcl, replace

use $projdir/dta/buildanalysisdata/demotrim/secondary/trimsecdemo1415, replace
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/demotrim/secondary/trimsecdemo1516
/* matched: 459. not matched: 1994 (from master: 725, from using: 1269) */

drop _merge
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/demotrim/secondary/trimsecdemo1617
/* matched: 1184. not matched: 1567 (frin naster: 1269, from using: 298) */

drop _merge
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/demotrim/secondary/trimsecdemo1718
/* matched: 1635. not matched: 1297 (from master: 1116, from using: 181) */

drop _merge
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/demotrim/secondary/trimsecdemo1819
/* matched: 1461. not matched: 1590 (from master: 1471, from using: 119) */

drop _merge

local grades `" "9" "10" "11" "12" "' //local macro for grades
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
//generate total survey responses for grades 9-12
foreach year of local years {
  gen svy`year' = svygr9_`year' + svygr10_`year' + svygr11_`year' + svygr12_`year'
  label var svy`year' "total survey response grades 9-12 in year `year'"
}
//generate total enrollment for grades 9-12
foreach year of local years {
  gen enr`year' = enrgr9_`year' + enrgr10_`year' + enrgr11_`year' + enrgr12_`year'
  label var enr`year' "total enrollment in grades 9-12 in year `year'"
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
label var pooledrr "pooled response rate for grades 9-12"
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


label data "secondary survey response numbers by grade year with pooled response rates"
compress
save $projdir/dta/buildanalysisdata/responserate/secresponserate, replace


log close
translate $projdir/log/build/buildanalysisdata/responserate/secresponserate.smcl $projdir/log/build/buildanalysisdata/responserate/secresponserate.log, replace 
