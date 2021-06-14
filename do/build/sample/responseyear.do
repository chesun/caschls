********************************************************************************
**************generate indicators for each year the school appears in the surveys****************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************
clear
set more off

//use the school frequency by year datasets



/* PARENT SURVEY*/

use $projdir/dta/schooloverlap/schlfreqbyyear/parentschlfreq, replace

keep cdscode has1415 has1516 has1617 has1718 has1819

label drop _all //remove all var labels to create new labels

label var has1415 "appears in 1415 parent survey"
label var has1516 "appears in 1516 parent survey"
label var has1617 "appears in 1617 parent survey"
label var has1718 "appears in 1718 parent survey"
label var has1819 "appears in 1819 parent survey"

local years `" "1415" "1516" "1617" "1718" "1819" "'
foreach i of local years {
  rename has`i' has`i'parent
}

label data "Indicators for the years each school appears in parent survey"

compress
save $projdir/dta/demographics/responseyear/parentresponseyear, replace




/* SECONDARY SURVEY */

use $projdir/dta/schooloverlap/schlfreqbyyear/secondaryschlfreq, replace

keep cdscode has1415 has1516 has1617 has1718 has1819

label drop _all //remove all var labels to create new labels

label var has1415 "appears in 1415 secondary survey"
label var has1516 "appears in 1516 secondary survey"
label var has1617 "appears in 1617 secondary survey"
label var has1718 "appears in 1718 secondary survey"
label var has1819 "appears in 1819 secondary survey"

local years `" "1415" "1516" "1617" "1718" "1819" "'
foreach i of local years {
  rename has`i' has`i'sec
}

label data "Indicators for the years each school appears in secondary survey"

compress
save $projdir/dta/demographics/responseyear/secresponseyear, replace





/* STAFF SURVEY */
use $projdir/dta/schooloverlap/schlfreqbyyear/staffschlfreq, replace

keep cdscode has1415 has1516 has1617 has1718 has1819

label drop _all //remove all var labels to create new labels

label var has1415 "appears in 1415 staff survey"
label var has1516 "appears in 1516 staff survey"
label var has1617 "appears in 1617 staff survey"
label var has1718 "appears in 1718 staff survey"
label var has1819 "appears in 1819 staff survey"

local years `" "1415" "1516" "1617" "1718" "1819" "'
foreach i of local years {
  rename has`i' has`i'staff
}

label data "Indicators for the years each school appears in staff survey"

compress
save $projdir/dta/demographics/responseyear/staffresponseyear, replace
