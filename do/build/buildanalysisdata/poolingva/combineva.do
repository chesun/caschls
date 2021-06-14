********************************************************************************
/* combine all VA datasets into one */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

clear all
set more off

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
