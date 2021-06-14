********************************************************************************
/* merge pooled analysis datasets with grade 11 enrollment for use as regression weights */
********************************************************************************
********************************************************************************
*************** written by Che Sun. Email: ucsun@ucdavis.edu *******************
********************************************************************************

clear all
set more off

/* merge gr11 enrollment with parent pooled dataset */
use $projdir/dta/buildanalysisdata/analysisready/parentanalysisready, clear
merge 1:1 cdscode using $projdir/dta/enrollment/schoollevel/poolgr11enr, keepusing(gr11enr_mean)
drop if _merge == 2 //drop unmatched observations from the enrollment dataset
drop _merge

save, replace



/* merge gr11 enrollment with secondary pooled dataset */
use $projdir/dta/buildanalysisdata/analysisready/secanalysisready, clear
merge 1:1 cdscode using $projdir/dta/enrollment/schoollevel/poolgr11enr, keepusing(gr11enr_mean)
drop if _merge == 2 //drop unmatched observations from the enrollment dataset
drop _merge

save, replace



/* merge gr11 enrollment with staff pooled dataset */
use $projdir/dta/buildanalysisdata/poolingdata/staffpooledstats, clear
merge 1:1 cdscode using $projdir/dta/enrollment/schoollevel/poolgr11enr, keepusing(gr11enr_mean)
drop if _merge == 2 //drop unmatched observations from the enrollment dataset
drop _merge

save $projdir/dta/buildanalysisdata/analysisready/staffanalysisready, replace
