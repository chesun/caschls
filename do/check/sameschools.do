********************************************************************************
******* checking what schools are in each dataset in each year ********************
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

/* Note: install package tabout before running this do file:
ssc install tabout */

/* this do file exports the list of school cdscodes in each dataset to excel, then
using excel we can see what schools are the same/different across years */

clear
set more off
log using "$projdir/log/sameschools.smcl", replace name(sameschools) // start log file for this do file

local elemdtaname `" "elem1415" "elem1516" "elem1617" "elem1718" "elem1819" "' //local macro for elementary dataset names
foreach i of local elemdtaname {
  use $clndtadir/elementary/`i', clear
  tabout cdscode using "$projdir/out/xls/check/elementary/schools`i'.xls", replace //export the list of schools in the dataset to excel
}

local parentdtaname `" "parent1415" "parent1516" "parent1617" "parent1718" "parent1819" "' //local macro for parent dataset names
foreach i of local parentdtaname {
  use $clndtadir/parent/`i', clear
  tabout cdscode using "$projdir/out/xls/check/parent/schools`i'.xls", replace //export the list of schools in the dataset to excel
}

local secdtaname `" "sec1112" "sec1213" "sec1314" "sec1415" "sec1516" "sec1617" "sec1718" "sec1819" "' //local macro for secondary dataset names
foreach i of local secdtaname {
  use $clndtadir/secondary/`i', clear
  tabout cdscode using "$projdir/out/xls/check/secondary/schools`i'.xls", replace //export the list of schools in the dataset to excel
}

local staffdtaname `" "staff0405" "staff0506" "staff0607" "staff0708" "staff0809" "staff0910" "staff1011" "staff1112" "staff1213" "staff1314" "staff1415" "staff1516" "staff1617" "staff1718" "staff1819" "' //local macro for staff dataset names
foreach i of local staffdtaname {
  use $clndtadir/staff/`i', clear
  tabout cdscode using "$projdir/out/xls/check/staff/schools`i'.xls", replace //export the list of shcools in the dtataset to excel
}


log close sameschools //close the log file for this do file
