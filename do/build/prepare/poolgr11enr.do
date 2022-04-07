********************************************************************************
/* poole grade 11 enrollment over years and calculate average for use as regression weights */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************
cap log close _all
clear all
set more off

log using $projdir/log/build/prepare/poolgr11enr.smcl, replace

/* append the datasets */
use $projdir/dta/enrollment/schoollevel/enr1819, clear
append using $projdir/dta/enrollment/schoollevel/enr1718
append using $projdir/dta/enrollment/schoollevel/enr1617
append using $projdir/dta/enrollment/schoollevel/enr1516
append using $projdir/dta/enrollment/schoollevel/enr1415

/* collapse to get avg grade 11 enrollment over years */
collapse (mean) gr11enr, by(cdscode)
rename gr11enr gr11enr_mean
label var gr11enr_mean "average grade 11 enrollment over years"

save $projdir/dta/enrollment/schoollevel/poolgr11enr, replace


log close
translate $projdir/log/build/prepare/poolgr11enr.smcl $projdir/log/build/prepare/poolgr11enr.log, replace 
