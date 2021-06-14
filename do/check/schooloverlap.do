********************************************************************************
**************** checking overlap of schools across years **********************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

clear
set more off

log using $projdir/log/schooloverlap, replace name(schooloverlap) // start log file for this do file


**********First, convert csv files with cdscode and frequencies into dta ********

//remember to make csv files first. Note: in excel files, convert cdscode to number format, otherwise data is lost when converting to csv

local elemcsvname `" "elem1415" "elem1516" "elem1617" "elem1718" "elem1819" "' //local macro for elementary dataset names
foreach i of local elemcsvname {
  import delimited $projdir/out/csv/schooloverlap/elementary/schools`i', clear //import the corresponding csv dataset for each year
  tostring cdscode, replace format("%15.0f") //apply a number format to enable string conversion
  replace cdscode = "0" + cdscode if inrange(length(cdscode), 13, 13) // add leading zero if cds code is 13 digits. This is because some county codes are missing leading zeros, which results in a 13 digit cdscode
  /* drop observations with incomplete cdscode to make sure cdscode is unique identifier */
  drop if missing(cdscode) //drop the observation if cdscode is missing
  drop if inrange(length(cdscode), 1, 13) //drop observations if cdscode is 1 to 13 characters long, this means at least the county code is missing, and impossible to determine which school it is
  save $projdir/dta/schooloverlap/elementary/`i', replace //save as a dta dataset
}

local parentcsvname `" "parent1415" "parent1516" "parent1617" "parent1718" "parent1819" "' //local macro for parent dataset names
foreach i of local parentcsvname {
  import delimited $projdir/out/csv/schooloverlap/parent/schools`i', clear //import the corresponding csv dataset for each year
  tostring cdscode, replace format("%15.0f")  //convert cdscode to string for consistency between datasets
  replace cdscode = "0" + cdscode if inrange(length(cdscode), 13, 13) // add leading zero if cds code is 13 digits. This is because some county codes are missing leading zeros, which results in a 13 digit cdscode
  /* drop observations with incomplete cdscode to make sure cdscode is unique identifier */
  drop if missing(cdscode) //drop the observation if cdscode is missing
  drop if inrange(length(cdscode), 1, 13) //drop observations if cdscode is 1 to 13 characters long, this means at least the county code is missing, and impossible to determine which school it is
  save $projdir/dta/schooloverlap/parent/`i', replace //save as a dta dataset
}

local seccsvname `" "sec1112" "sec1213" "sec1314" "sec1415" "sec1516" "sec1617" "sec1718" "sec1819" "' //local macro for secondary dataset names
foreach i of local seccsvname {
  import delimited $projdir/out/csv/schooloverlap/secondary/schools`i', clear //import the corresponding csv dataset for each year
  tostring cdscode, replace format("%15.0f")  //convert cdscode to string for consistency between datasets
  replace cdscode = "0" + cdscode if inrange(length(cdscode), 13, 13) // add leading zero if cds code is 13 digits. This is because some county codes are missing leading zeros, which results in a 13 digit cdscode
  /* drop observations with incomplete cdscode to make sure cdscode is unique identifier */
  drop if missing(cdscode) //drop the observation if cdscode is missing
  drop if inrange(length(cdscode), 1, 13) //drop observations if cdscode is 1 to 13 characters long, this means at least the county code is missing, and impossible to determine which school it is
  save $projdir/dta/schooloverlap/secondary/`i', replace //save as a dta dataset
}

local staffcsvname `" "staff0405" "staff0506" "staff0607" "staff0708" "staff0809" "staff0910" "staff1011" "staff1112" "staff1213" "staff1314" "staff1415" "staff1516" "staff1617" "staff1718" "staff1819" "' //local macro for staff dataset names
foreach i of local staffcsvname {
  import delimited $projdir/out/csv/schooloverlap/staff/schools`i', clear //import the corresponding csv dataset for each year
  tostring cdscode, replace format("%15.0f")  //convert cdscode to string for consistency between datasets
  replace cdscode = "0" + cdscode if inrange(length(cdscode), 13, 13) // add leading zero if cds code is 13 digits. This is because some county codes are missing leading zeros, which results in a 13 digit cdscode
  /* drop observations with incomplete cdscode to make sure cdscode is unique identifier */
  drop if missing(cdscode) //drop the observation if cdscode is missing
  drop if inrange(length(cdscode), 1, 13) //drop observations if cdscode is 1 to 13 characters long, this means at least the county code is missing, and impossible to determine which school it is
  save $projdir/dta/schooloverlap/staff/`i', replace //save as a dta dataset
}






********************************************************************************
********** produce elementary dataset for school by year frequencies ***********

/* merge elementary dta files with school frequencies by cdscode */
use $projdir/dta/schooloverlap/elementary/elem1415, clear

local elemmergename `" "elem1516" "elem1617" "elem1718" "elem1819" "'
foreach i of local elemmergename {
  merge 1:1 cdscode using $projdir/dta/schooloverlap/elementary/`i' // merge 1 to 1 with each successive dataset
  drop _merge // drop the _merge variable to enable merging next dataset
}

label var freq1415 "Number of Observations in 2014-2015"
label var freq1516 "Number of Observations in 2015-2016"
label var freq1617 "Number of Observations in 2016-2017"
label var freq1718 "Number of Observations in 2017-2018"
label var freq1819 "Number of Observations in 2018-2019"

local elemyears `" "1415" "1516" "1617" "1718" "1819" "' // a local macro that stores the years for elementary for the following loop
foreach i of local elemyears {
  gen has`i' = 1 // generate a variable that indicates whether the school administered each year of elementary survey by looking at whether the observations in each year is a number or missing. Missing = not in that year
  replace has`i' = 0 if missing(freq`i')
  label var has`i' "Dummy for whether the school administered elementary survey in year `i'"
}

gen hasallyears = has1415 * has1516 * has1617 * has1718 * has1819 // generate a var that is 1 if the school administered elementary survey in all years, 0 otherwise
label var hasallyears "Dummy for whether the school administered elementary survey in all 5 years"

gen numyears = has1415 + has1516 + has1617 + has1718 + has1819 //generate a var for the number of years the school administered the elementary survey, this variable makes hasallyears redundant
label var numyears "Number of years the school administered the elementary survey (1 to 5)"

/* by the same principle, we can generate variables that check overlap of schools
between any two years, for example, any two adjacent years */

gen has14151516 = has1415 * has1516 //generate a var that is a dummy for whether the school administered elementary survey in both 1415 and 1516, 1= yes, 0 = no
gen has15161617 = has1516 * has1617 //generate a var that is a dummy for whether the school administered elementary survey in both 1516 and 1617, 1= yes, 0 = no
gen has16171718 = has1617 * has1718 //generate a var that is a dummy for whether the school administered elementary survey in both 1617 and 1718, 1= yes, 0 = no
gen has17181819 = has1718 * has1819 //generate a var that is a dummy for whether the school administered elementary survey in both 1718 and 1819, 1= yes, 0 = no

label var has14151516 "Whether the school administered elementary survey in both 1415 and 1516"
label var has15161617 "Whether the school administered elementary survey in both 1516 and 1617"
label var has16171718 "Whether the school administered elementary survey in both 1617 and 1718"
label var has17181819 "Whether the school administered elementary survey in both 1718 and 1819"

label data "School frequencies each year in Elementary survey" //label the dataset
save $projdir/dta/schooloverlap/schlfreqbyyear/elementaryschlfreq, replace //save the merged elementary school frequency by year dataset





********************************************************************************
********** produce parent dataset for school by year frequencies ***************

/* merge parent dta files with school frequencies by cdscode */
use $projdir/dta/schooloverlap/parent/parent1415, clear //load the dataset to start merging with

local parentmergename `" "parent1516" "parent1617" "parent1718" "parent1819" "' //local macro for parent data names to use for merge
foreach i of local parentmergename {
  merge 1:1 cdscode using $projdir/dta/schooloverlap/parent/`i' // merge 1 to 1 with each successive dataset
  drop _merge // drop the _merge variable to enable merging next dataset
}

label var freq1415 "Number of Observations in 2014-2015"
label var freq1516 "Number of Observations in 2015-2016"
label var freq1617 "Number of Observations in 2016-2017"
label var freq1718 "Number of Observations in 2017-2018"
label var freq1819 "Number of Observations in 2018-2019"

local parentyears `" "1415" "1516" "1617" "1718" "1819" "' // a local macro that stores the years for parent for the following loop
foreach i of local parentyears {
  gen has`i' = 1 // generate a variable that indicates whether the school administered each year of parent survey by looking at whether the observations in each year is a number or missing. Missing = not in that year
  replace has`i' = 0 if missing(freq`i')
  label var has`i' "Dummy for whether the school administered parent survey in year `i'"
}

gen hasallyears = has1415 * has1516 * has1617 * has1718 * has1819 // generate a var that is 1 if the school administered parent survey in all years, 0 otherwise
label var hasallyears "Dummy for whether the school administered parent survey in all 5 years"

gen numyears = has1415 + has1516 + has1617 + has1718 + has1819 //generate a var for the number of years the school administered the parent survey, this variable makes hasallyears redundant
label var numyears "Number of years the school administered the parent survey (1 to 5)"

/* by the same principle, we can generate variables that check overlap of schools
between any two years, for example, any two adjacent years */

gen has14151516 = has1415 * has1516 //generate a var that is a dummy for whether the school administered parent survey in both 1415 and 1516, 1= yes, 0 = no
gen has15161617 = has1516 * has1617 //generate a var that is a dummy for whether the school administered parent survey in both 1516 and 1617, 1= yes, 0 = no
gen has16171718 = has1617 * has1718 //generate a var that is a dummy for whether the school administered parent survey in both 1617 and 1718, 1= yes, 0 = no
gen has17181819 = has1718 * has1819 //generate a var that is a dummy for whether the school administered parent survey in both 1718 and 1819, 1= yes, 0 = no

label var has14151516 "Whether the school administered parent survey in both 1415 and 1516"
label var has15161617 "Whether the school administered parent survey in both 1516 and 1617"
label var has16171718 "Whether the school administered parent survey in both 1617 and 1718"
label var has17181819 "Whether the school administered parent survey in both 1718 and 1819"

label data "School frequencies each year in Parent survey" //label the dataset
save $projdir/dta/schooloverlap/schlfreqbyyear/parentschlfreq, replace //save the merged parent school frequency by year dataset




********************************************************************************
********** produce secondary dataset for school by year frequencies ************

/* merge secondary dta files with school frequencies by cdscode */
use $projdir/dta/schooloverlap/secondary/sec1112, clear

local secmergename `" "sec1213" "sec1314" "sec1415" "sec1516" "sec1617" "sec1718" "sec1819" "' //local macro for secondary data names to use for merge
foreach i of local secmergename {
  merge 1:1 cdscode using $projdir/dta/schooloverlap/secondary/`i' // merge 1 to 1 with each successive dataset
  drop _merge // drop the _merge variable to enable merging next dataset
}

label var freq1112 "Number of Observations in 2011-2012"
label var freq1213 "Number of Observations in 2012-2013"
label var freq1314 "Number of Observations in 2013-2014"
label var freq1415 "Number of Observations in 2014-2015"
label var freq1516 "Number of Observations in 2015-2016"
label var freq1617 "Number of Observations in 2016-2017"
label var freq1718 "Number of Observations in 2017-2018"
label var freq1819 "Number of Observations in 2018-2019"

local secyears `" "1112" "1213" "1314" "1415" "1516" "1617" "1718" "1819" "' // a local macro that stores the years for secondary for the following loop
foreach i of local secyears {
  gen has`i' = 1 // generate a variable that indicates whether the school administered each year of secondary survey by looking at whether the observations in each year is a number or missing. Missing = not in that year
  replace has`i' = 0 if missing(freq`i')
  label var has`i' "Dummy for whether the school administered secondary survey in year `i'"
}

gen hasallyears = has1112 * has1213 * has1314 * has1415 * has1516 * has1617 * has1718 * has1819 // generate a var that is 1 if the school administered secondary survey in all years, 0 otherwise
label var hasallyears "Dummy for whether the school administered secondary survey in all 8 years"

gen numyears = has1112 + has1213 + has1314 + has1415 + has1516 + has1617 + has1718 + has1819 //generate a var for the number of years the school administered the secondary survey, this variable makes hasallyears redundant
label var numyears "Number of years the school administered the secondary survey (1 to 8)"

/* by the same principle, we can generate variables that check overlap of schools
between any two years, for example, any two adjacent years */

gen has11121213 = has1112 + has1213 //generate a var that is a dummy for whether the school administered secondary survey in both 1112 and 1213, 1= yes, 0 = no
gen has12131314 = has1213 + has1314 //generate a var that is a dummy for whether the school administered secondary survey in both 1213 and 1314, 1= yes, 0 = no
gen has13141415 = has1314 + has1415 //generate a var that is a dummy for whether the school administered secondary survey in both 1314 and 1415, 1= yes, 0 = no
gen has14151516 = has1415 * has1516 //generate a var that is a dummy for whether the school administered secondary survey in both 1415 and 1516, 1= yes, 0 = no
gen has15161617 = has1516 * has1617 //generate a var that is a dummy for whether the school administered secondary survey in both 1516 and 1617, 1= yes, 0 = no
gen has16171718 = has1617 * has1718 //generate a var that is a dummy for whether the school administered secondary survey in both 1617 and 1718, 1= yes, 0 = no
gen has17181819 = has1718 * has1819 //generate a var that is a dummy for whether the school administered secondary survey in both 1718 and 1819, 1= yes, 0 = no

label var has11121213 "Whether the school administered secondary survey in both 1112 and 1213"
label var has12131314 "Whether the school administered secondary survey in both 1213 and 1314"
label var has13141415 "Whether the school administered secondary survey in both 1314 and 1415"
label var has14151516 "Whether the school administered secondary survey in both 1415 and 1516"
label var has15161617 "Whether the school administered secondary survey in both 1516 and 1617"
label var has16171718 "Whether the school administered secondary survey in both 1617 and 1718"
label var has17181819 "Whether the school administered secondary survey in both 1718 and 1819"

label data "School frequencies each year in Secondary survey" //label the dataset
save $projdir/dta/schooloverlap/schlfreqbyyear/secondaryschlfreq, replace //save the merged secondary school frequency by year dataset






********************************************************************************
************ produce staff dataset for school by year frequencies **************

/* merge secondary dta files with school frequencies by cdscode */
use $projdir/dta/schooloverlap/staff/staff0405, clear

local staffmergename `" "staff0506" "staff0607" `'"staff0708" "staff0809" "staff0910" "staff1011" "staff1112" "staff1213" "staff1314" "staff1415" "staff1516" "staff1617" "staff1718" "staff1819" "' //local macro for secondary data names to use for merge
foreach i of local staffmergename {
  merge 1:1 cdscode using $projdir/dta/schooloverlap/staff/`i' // merge 1 to 1 with each successive dataset
  drop _merge // drop the _merge variable to enable merging next dataset
}

local staffyears `" "0405" "0506" "0607" "0708" "0809" "0910" "1011" "1112" "1213" "1314" "1415" "1516" "1617" "1718" "1819" "' // // a local macro that stores the years for staff for the following loops

foreach i of local staffyears {
  label var freq`i' "Number of Observations in year `i'"
}

foreach i of local staffyears {
  gen has`i' = 1 // generate a variable that indicates whether the school administered each year of secondary survey by looking at whether the observations in each year is a number or missing. Missing = not in that year
  replace has`i' = 0 if missing(freq`i')
  label var has`i' "Dummy for whether the school administered staff survey in year `i'"
}

gen hasallyears = has0405 * has0506 * has0607 * has0708 * has0809 * has0910 * has1011 * has1112 * has1213 * has1314 * has1415 * has1516 * has1617 * has1718 * has1819 // generate a var that is 1 if the school administered staff survey in all years, 0 otherwise
label var hasallyears "Dummy for whether the school administered staff survey in all 15 years"

gen numyears = has0405 + has0506 + has0607 + has0708 + has0809 + has0910 + has1011 + has1112 + has1213 + has1314 + has1415 + has1516 + has1617 + has1718 + has1819 //generate a var for the number of years the school administered the staff survey, this variable makes hasallyears redundant
label var numyears "Number of years the school administered the staff survey (1 to 15)"


/* by the same principle, we can generate variables that check overlap of schools
between any two years, for example, any two adjacent years */


gen has04050506 = has0405 + has0506 //generate a var that is a dummy for whether the school administered staff survey in both 1112 and 1213, 1= yes, 0 = no
gen has05060607 = has0506 + has0607 //generate a var that is a dummy for whether the school administered staff survey in both 1112 and 1213, 1= yes, 0 = no
gen has06070708 = has0607 + has0708 //generate a var that is a dummy for whether the school administered staff survey in both 1112 and 1213, 1= yes, 0 = no
gen has07080809 = has0708 + has0809 //generate a var that is a dummy for whether the school administered staff survey in both 1112 and 1213, 1= yes, 0 = no
gen has08090910 = has0809 + has0910 //generate a var that is a dummy for whether the school administered staff survey in both 1112 and 1213, 1= yes, 0 = no
gen has09101011 = has0910 + has1011 //generate a var that is a dummy for whether the school administered staff survey in both 1112 and 1213, 1= yes, 0 = no
gen has10111112 = has1011 + has1112 //generate a var that is a dummy for whether the school administered staff survey in both 1112 and 1213, 1= yes, 0 = no
gen has11121213 = has1112 + has1213 //generate a var that is a dummy for whether the school administered staff survey in both 1112 and 1213, 1= yes, 0 = no
gen has12131314 = has1213 + has1314 //generate a var that is a dummy for whether the school administered staff survey in both 1213 and 1314, 1= yes, 0 = no
gen has13141415 = has1314 + has1415 //generate a var that is a dummy for whether the school administered staff survey in both 1314 and 1415, 1= yes, 0 = no
gen has14151516 = has1415 * has1516 //generate a var that is a dummy for whether the school administered staff survey in both 1415 and 1516, 1= yes, 0 = no
gen has15161617 = has1516 * has1617 //generate a var that is a dummy for whether the school administered staff survey in both 1516 and 1617, 1= yes, 0 = no
gen has16171718 = has1617 * has1718 //generate a var that is a dummy for whether the school administered staff survey in both 1617 and 1718, 1= yes, 0 = no
gen has17181819 = has1718 * has1819 //generate a var that is a dummy for whether the school administered staff survey in both 1718 and 1819, 1= yes, 0 = no

label var has04050506 "Whether the school administered staff survey in both 0405 and 0506"
label var has05060607 "Whether the school administered staff survey in both 0506 and 0607"
label var has06070708 "Whether the school administered staff survey in both 0607 and 0708"
label var has07080809 "Whether the school administered staff survey in both 0708 and 0809"
label var has08090910 "Whether the school administered staff survey in both 0809 and 0910"
label var has09101011 "Whether the school administered staff survey in both 0910 and 1011"
label var has10111112 "Whether the school administered staff survey in both 1112 and 1213"
label var has11121213 "Whether the school administered staff survey in both 1112 and 1213"
label var has12131314 "Whether the school administered staff survey in both 1213 and 1314"
label var has13141415 "Whether the school administered staff survey in both 1314 and 1415"
label var has14151516 "Whether the school administered staff survey in both 1415 and 1516"
label var has15161617 "Whether the school administered staff survey in both 1516 and 1617"
label var has16171718 "Whether the school administered staff survey in both 1617 and 1718"
label var has17181819 "Whether the school administered staff survey in both 1718 and 1819"

label data "School frequencies each year in Staff survey" //label the dataset
save $projdir/dta/schooloverlap/schlfreqbyyear/staffschlfreq, replace //save the merged staff school frequency by year dataset




log close schooloverlap //close this log file
