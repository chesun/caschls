********************************************************************************
/* combine all VA datasets into one */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
cap log close _all
clear all
set more off

log using $projdir/log/build/buildanalysisdata/poolingva/combineva.smcl, replace

use $projdir/dta/buildanalysisdata/va/ela, clear
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/va/math
drop _merge
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/va/enr
drop _merge
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/va/2yr
drop _merge
merge 1:1 cdscode using $projdir/dta/buildanalysisdata/va/4yr
drop _merge


label data "average VA estimates pooled over years 2015, 2016, and 2017"

save $projdir/dta/buildanalysisdata/va/combinedva, replace


log close
translate $projdir/log/build/buildanalysisdata/poolingva/combineva.smcl $projdir/log/build/buildanalysisdata/poolingva/combineva.log, replace 
