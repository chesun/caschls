********************************************************************************
**********split staff0414.dta into 10 dastasets, 1 for each school year*********
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************

clear
set more off

log using "$projdir/log/splitstaff0414.smcl", replace name(splitstaff0414) //start log file for the master do file and overwrite existing log file

use $clndtadir/staff/staff0414, clear

gen str tempyear = "" //generate a temp string var for ease of writing short file names
replace tempyear = "0405" if schlyear == 2004.2005
replace tempyear = "0506" if schlyear == 2005.2006
replace tempyear = "0607" if schlyear == 2006.2007
replace tempyear = "0708" if schlyear == 2007.2008
replace tempyear = "0809" if schlyear == 2008.2009
replace tempyear = "0910" if schlyear == 2009.2010
replace tempyear = "1011" if schlyear == 2010.2011
replace tempyear = "1112" if schlyear == 2011.2012
replace tempyear = "1213" if schlyear == 2012.2013
replace tempyear = "1314" if schlyear == 2013.2014

local years `" "0405" "0506" "0607" "0708" "0809" "0910" "1011" "1112" "1213" "1314" "' //a local macro for storing years

preserve //write a copy of the data in memory to disk to restore later

foreach i of local years {
  keep if tempyear == "`i'"
  save $clndtadir/staff/staff`i', replace
  restore, preserve //retore the data without erasing the backup copy on disk
}

restore

log close splitstaff0414 //close the current log file for this do file
