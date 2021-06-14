********************************************************************************
/* pool cleaned CDE enrollment datasets over 5 years: 1415 - 1819 */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu ********************
********************************************************************************
clear
set more off

/* first append all years to make a pnael dataset */
use $projdir/dta/enrollment/schoollevel/enr1415, clear
append using $projdir/dta/enrollment/schoollevel/enr1516
append using $projdir/dta/enrollment/schoollevel/enr1617
append using $projdir/dta/enrollment/schoollevel/enr1718
append using $projdir/dta/enrollment/schoollevel/enr1819

drop if missing(cdscode)

collapse (mean) femaleenrtotal maleenrtotal blackenrtotal whiteenrtotal hispanicenrtotal, by(cdscode)

gen enrtotal = femaleenrtotal + maleenrtotal

gen femaleenrpct = femaleenrtotal/enrtotal
gen blackenrpct = blackenrtotal/enrtotal
gen whiteenrpct = whiteenrtotal/enrtotal
gen hispanicenrpct = hispanicenrtotal/enrtotal


label var femaleenrpct "pooled average female percentage enrollment"
label var blackenrpct "pooled average black percentage enrollment"
label var whiteenrpct "pooled average white percentage enrollment"
label var hispanicenrpct "pooled average hispanic percentage enrollment"

compress
label data "Enrollment demographics pooled average over 1415 to 1819"
save $projdir/dta/enrollment/pooledavgenr, replace
